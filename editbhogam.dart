import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class DataTableScreen extends StatefulWidget {
  static const String id = "bhogam-edit";

  const DataTableScreen({Key? key}) : super(key: key);

  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _exportToPdf(BuildContext context) async {
    try {
      // Fetch SishyaDetails and create a map
      final sishyaDetailsSnapshot =
          await FirebaseFirestore.instance.collection('SishyaDetails').get();
      final Map<String, Map<String, dynamic>> sishyaDetailsMap = {};

      for (var doc in sishyaDetailsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final subId = data['Shisya_ID'] as String?;
        if (subId != null) {
          sishyaDetailsMap[subId] = data; // Store data with subId as key
        }
      }

      // Fetch AddressDetails and create a map
      final addressDetailsSnapshot =
          await FirebaseFirestore.instance.collection('AddressDetails').get();
      final Map<String, Map<String, dynamic>> addressDetailsMap = {};

      for (var doc in addressDetailsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final id = data['Address_ID'] as String?;
        if (id != null) {
          addressDetailsMap[id] = data; // Store data with id as key
        }
      }

      // Fetch BhogamDetails within the selected date range
      final bhogamSnapshot = await FirebaseFirestore.instance
          .collection('BhogamDetails')
          .where('Bhogam start date',
              isGreaterThanOrEqualTo:
                  _startDate != null ? Timestamp.fromDate(_startDate!) : null)
          .where('Bhogam start date',
              isLessThanOrEqualTo:
                  _endDate != null ? Timestamp.fromDate(_endDate!) : null)
          .get();

      final List<Map<String, dynamic>> bhogamDetailsList = [];

      for (var doc in bhogamSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bhogamDetailsList.add(data);
      }

      // Check if there are any records to export
      if (bhogamDetailsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No records found for the selected date range.')),
        );
        return; // Exit if there are no records
      }

      // Split data into pages of 9
      final int chunkSize = 9;
      final List<List<Map<String, dynamic>>> pages = [];

      for (int i = 0; i < bhogamDetailsList.length; i += chunkSize) {
        pages.add(bhogamDetailsList.sublist(
            i,
            (i + chunkSize) > bhogamDetailsList.length
                ? bhogamDetailsList.length
                : (i + chunkSize)));
      }

      int currentPage = 0;

      // Function to build the PDF for the current page
      // Function to build the PDF for the current page
      Future<Uint8List> buildPdf(int pageIndex) {
        final pdf = pw.Document();

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bhogam Report',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.ListView.builder(
                    itemCount: (pages[pageIndex].length / 2).ceil(),
                    itemBuilder: (context, rowIndex) {
                      List<pw.Widget> rowWidgets = [];
                      for (int j = 0; j < 3; j++) {
                        int index = rowIndex * 3 + j;
                        if (index < pages[pageIndex].length) {
                          final bhogamData = pages[pageIndex]
                              [index]; // Get the current bhogam data

                          String addressLine1 = addressDetailsMap[
                                  sishyaDetailsMap[bhogamData['Shisya_ID']]
                                      ?['Address_ID']]?['Address Line 1'] ??
                              '';
                          String addressLine2 = addressDetailsMap[
                                  sishyaDetailsMap[bhogamData['Shisya_ID']]
                                      ?['Address_ID']]?['Address Line 2'] ??
                              '';
                          String addressLine3 = addressDetailsMap[
                                  sishyaDetailsMap[bhogamData['Shisya_ID']]
                                      ?['Address_ID']]?['Address Line 3'] ??
                              '';

                          // Get address from bhogamData if available
                          String bhogamAddress = bhogamData['Baddress'] ??
                              ''; // Adjust this key as needed

                          // Combine all address lines into a full address
                          String fullAddress = [
                            addressLine1,
                            addressLine2,
                            addressLine3,
                            bhogamAddress
                          ].where((line) => line.isNotEmpty).join(', ');

                          // Access the phone number
                          String phone = bhogamData['Phone'] ??
                              'N/A'; // Default to 'N/A' if not found

                          rowWidgets.add(
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1,
                                ),
                              ),
                              width: 180,
                              height: 150,
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(
                                      'Name: ${bhogamData['Bhogam for Name'] ?? ''}'),
                                  pw.Text(
                                      'Address: $fullAddress'), // Display combined address
                                  pw.Text(
                                      'Phone: $phone'), // Display phone number
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      // Align based on the number of items in the row
                      if (rowWidgets.length == 1 || rowWidgets.length == 2) {
                        return pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: rowWidgets,
                        );
                      } else {
                        return pw.Center(
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: rowWidgets,
                          ),
                        );
                      }
                    },
                  ),
                  pw.SizedBox(height: 10),
                ],
              );
            },
          ),
        );

        return pdf.save();
      }

      // Show PDF preview with pagination
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                    'PDF Preview - Page ${currentPage + 1} of ${pages.length}'),
                content: Container(
                  width: double.maxFinite,
                  height: 600,
                  child: PdfPreview(
                    build: (format) => buildPdf(currentPage),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (currentPage > 0) {
                        setState(() {
                          currentPage--;
                        });
                      }
                    },
                    child: Text('Previous'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (currentPage < pages.length - 1) {
                        setState(() {
                          currentPage++;
                        });
                      }
                    },
                    child: Text('Next'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final blob = html.Blob(
                          [await buildPdf(currentPage)], 'application/pdf');
                      final url = html.Url.createObjectUrl(blob);
                      final anchor = html.AnchorElement(href: url)
                        ..setAttribute('download', 'bhogam_data.pdf')
                        ..click();
                      html.Url.revokeObjectUrl(url);
                      Navigator.of(context).pop();
                    },
                    child: Text('Download'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error exporting to PDF: $e');
    }
  }

  Future<void> _exportToCsv() async {
    try {
      // Step 1: Fetch SishyaDetails and create a map
      final sishyaDetailsSnapshot =
          await _firestore.collection('SishyaDetails').get();
      final Map<String, Map<String, dynamic>> sishyaDetailsMap = {};

      for (var doc in sishyaDetailsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final subId = data['Shisya_ID'] as String?;
        if (subId != null) {
          sishyaDetailsMap[subId] = data; // Store data with subId as key
        }
      }

      // Step 2: Fetch AddressDetails and create a map
      final addressDetailsSnapshot =
          await _firestore.collection('AddressDetails').get();
      final Map<String, Map<String, dynamic>> addressDetailsMap = {};

      for (var doc in addressDetailsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final id = data['Address_ID'] as String?;
        if (id != null) {
          addressDetailsMap[id] = data; // Store data with id as key
        }
      }

      // Step 3: Fetch BhogamDetails
      final bhogamSnapshot = await _firestore.collection('BhogamDetails').get();
      final Map<String, List<Map<String, dynamic>>> groupedData = {};

      // Grouping the data by subId
      for (var doc in bhogamSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final idKey = data['Shisya_ID'] ?? 'bhogam only';

        if (!groupedData.containsKey(idKey)) {
          groupedData[idKey] = [];
        }
        groupedData[idKey]!.add(data);
      }

      // Prepare CSV headers
      const headers = [
        'Shisya_ID',
        'Bhogam_ID',
        'Bhogam for Name',
        'Bhogam purpose',
        'Bhogam month',
        'Bhogam start date',
        'English Calender Date',
        'Bhogam thithi or nakshatram',
        'Bhogam Amount',
        'Bhogam valid indicator',
        'Email',
        'Phone',
        'Bhogam data entered by',
        'Are you a Sishya',
        'Name',
        'Email',
        'Address_ID', // From AddressDetails
        'Address Line 1',
        'Address Line 2',
        'Address Line 3',
        'Baddress' // Example additional address field
      ];

      final rows = <List<String>>[headers];

      // Function to add data rows
      void addDataRow(
        String subId,
        Map<String, dynamic> details,
        Map<String, dynamic> sishyaDetails,
        String addressId,
        String addressLine1,
        String addressLine2,
        String addressLine3,
      ) {
        rows.add([
          subId,
          details['Bhogam_ID'] ?? '',
          details['Bhogam for Name'] ?? '',
          details['Bhogam purpose'] ?? '',
          details['Bhogam month'] ?? '',
          details['Bhogam start date'] != null
              ? (details['Bhogam start date'] as Timestamp).toDate().toString()
              : '',
          details['English Calender Date'] != null
              ? (details['English Calender Date'] as Timestamp)
                  .toDate()
                  .toString()
              : '',
          details['Bhogam thithi or nakshatram'] ?? '',
          details['Bhogam Amount'] ?? '',
          details['Bhogam valid indicator'] ?? '',
          details['Email'] ?? '',
          details['Phone'] ?? '',
          details['Bhogam data entered by'] ?? '',
          details['Are you a Sishya'] ?? '',
          sishyaDetails['Name'] ?? '',
          sishyaDetails['Email'] ?? '',
          addressId, // Include address ID
          addressLine1, // Address Line 1
          addressLine2, // Address Line 2
          addressLine3, // Address Line 3
          details['Baddress'] ?? 'null',
        ]);
      }

      // Data rows
      for (var entry in groupedData.entries) {
        final subId = entry.key; // Keep subId as it is
        final detailsList = entry.value;

        // Initialize address variables
        String addressId = '';
        String addressLine1 = '';
        String addressLine2 = '';
        String addressLine3 = '';

        if (subId.isNotEmpty) {
          final sishyaDetails = sishyaDetailsMap[subId] ?? {};

          // Check for address details only if there's a valid subId
          final addressDetails =
              addressDetailsMap[sishyaDetails['Address_ID']] ?? {};
          if (addressDetails.isNotEmpty) {
            addressId = addressDetails['Address_ID'] ?? '';
            addressLine1 = addressDetails['Address Line 1'] ?? '';
            addressLine2 = addressDetails['Address Line 2'] ?? '';
            addressLine3 = addressDetails['Address Line 3'] ?? '';
          }

          // Add data rows for entries with subId
          if (detailsList.isNotEmpty) {
            addDataRow(subId, detailsList[0], sishyaDetails, addressId,
                addressLine1, addressLine2, addressLine3); // First entry

            // For subsequent entries, leave subId empty
            for (var i = 1; i < detailsList.length; i++) {
              addDataRow('', detailsList[i], sishyaDetails, addressId,
                  addressLine1, addressLine2, addressLine3);
            }
          }
        }
      }

      // Handle entries without subId
      for (var entry in groupedData.entries) {
        final subId = entry.key; // This might be 'Unknown' or an empty string
        if (subId.isEmpty || subId == 'No selected') {
          final detailsList = entry.value;

          // Add rows without address details for entries without subId
          for (var details in detailsList) {
            addDataRow('no selected', details, {}, '', '', '',
                ''); // Add row with empty address details
          }
        }
      }

      // Convert to CSV format
      String csvData = const ListToCsvConverter().convert(rows);
      final blob =
          html.Blob([Uint8List.fromList(utf8.encode(csvData))], 'text/csv');
      final url = html.Url.createObjectUrl(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'bhogam_data.csv')
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error exporting to CSV: $e');
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _showDetailsBottomSheet(
      BuildContext context, String documentId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('BhogamDetails')
        .doc(documentId)
        .get();

    final fields = docSnapshot.data() as Map<String, dynamic>;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double maxHeight = MediaQuery.of(context).size.height * 0.8;
            double maxWidth = constraints.maxWidth * 0.9;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                maxWidth: maxWidth,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 16.0,
                            columns: const [
                              DataColumn(label: Text('Field')),
                              DataColumn(label: Text('Value')),
                            ],
                            rows: fields.entries.map((entry) {
                              String valueString;
                              if (entry.value is Timestamp) {
                                valueString = DateFormat.yMd().format(
                                    (entry.value as Timestamp).toDate());
                              } else {
                                valueString = entry.value.toString();
                              }
                              return DataRow(cells: [
                                DataCell(
                                  SizedBox(
                                    width: maxWidth * 0.4,
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: maxWidth * 0.5,
                                    child: Text(
                                      valueString,
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditBottomSheet(BuildContext context, String documentId,
      Map<String, dynamic> initialData) async {
    final TextEditingController subIdController =
        TextEditingController(text: initialData['Shisya_ID']);
    final TextEditingController bsubIdController =
        TextEditingController(text: initialData['Bhogam_ID']);

    final TextEditingController nameController =
        TextEditingController(text: initialData['Bhogam for Name']);
    final TextEditingController amountController =
        TextEditingController(text: initialData['Bhogam Amount']);
    final TextEditingController thithiController =
        TextEditingController(text: initialData['Bhogam thithi or nakshatram']);
    final TextEditingController emailController =
        TextEditingController(text: initialData['Email']);
    final TextEditingController phoneController =
        TextEditingController(text: initialData['Phone']);
    final TextEditingController enteredByController =
        TextEditingController(text: initialData['Bhogam data entered by']);
    final TextEditingController startDateController = TextEditingController(
        text: initialData['Bhogam start date'] is Timestamp
            ? DateFormat.yMd().format(
                (initialData['Bhogam start date'] as Timestamp).toDate())
            : initialData['Bhogam start date'] ?? '');
    final TextEditingController englishDateController = TextEditingController(
        text: initialData['English Calender Date'] is Timestamp
            ? DateFormat.yMd().format(
                (initialData['English Calender Date'] as Timestamp).toDate())
            : initialData['English Calender Date'] ?? '');

    DateTime? startDate = initialData['Bhogam start date'] is Timestamp
        ? (initialData['Bhogam start date'] as Timestamp).toDate()
        : null;
    DateTime? englishDate = initialData['English Calender Date'] is Timestamp
        ? (initialData['English Calender Date'] as Timestamp).toDate()
        : null;

    List<String> purposes = ['Birthday', 'Marriage Anniversary', 'Thithi'];
    List<String> sishyaOptions = ['Yes', 'No'];
    List<String> validOptions = ['Yes', 'No'];

    String selectedPurpose = purposes.contains(initialData['Bhogam purpose'])
        ? initialData['Bhogam purpose']
        : purposes.first;
    String selectedSishya =
        sishyaOptions.contains(initialData['Are you a Sishya'])
            ? initialData['Are you a Sishya']
            : sishyaOptions.first;
    String selectedValid =
        validOptions.contains(initialData['Bhogam valid indicator'])
            ? initialData['Bhogam valid indicator']
            : validOptions.first;

    Future<void> _selectDate(BuildContext context,
        TextEditingController controller, DateTime? initialDate) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null && pickedDate != initialDate) {
        controller.text = DateFormat.yMd().format(pickedDate);
      }
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                      controller: subIdController, label: 'Sishya ID'),
                  _buildTextField(
                      controller: bsubIdController, label: 'Bhogam ID'),
                  _buildDropdown<String>(
                    value: selectedPurpose,
                    label: 'Bhogam purpose',
                    items: purposes,
                    onChanged: (value) =>
                        setState(() => selectedPurpose = value!),
                  ),
                  _buildTextField(
                      controller: nameController, label: 'Bhogam for Name'),
                  _buildTextField(
                      controller: TextEditingController(
                          text: initialData['Bhogam month']),
                      label: 'Bhogam month'),
                  _buildDateField(
                    controller: startDateController,
                    label: 'Bhogam start Date',
                    onPressed: () =>
                        _selectDate(context, startDateController, startDate),
                  ),
                  _buildDateField(
                    controller: englishDateController,
                    label: 'English Calender Date',
                    onPressed: () => _selectDate(
                        context, englishDateController, englishDate),
                  ),
                  _buildTextField(
                      controller: amountController, label: 'Bhogam Amount'),
                  _buildTextField(
                      controller: thithiController,
                      label: 'Bhogam thithi or nakshatram'),
                  _buildTextField(controller: emailController, label: 'Email'),
                  _buildTextField(controller: phoneController, label: 'Phone'),
                  _buildTextField(
                      controller: enteredByController,
                      label: 'Bhogam data entered by'),
                  _buildDropdown<String>(
                    value: selectedSishya,
                    label: 'Are you a Sishya?',
                    items: sishyaOptions,
                    onChanged: (value) =>
                        setState(() => selectedSishya = value!),
                  ),
                  _buildDropdown<String>(
                    value: selectedValid,
                    label: 'Bhogam valid indicator?',
                    items: validOptions,
                    onChanged: (value) =>
                        setState(() => selectedValid = value!),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('BhogamDetails')
                          .doc(documentId)
                          .update({
                        'Shisya_ID': subIdController.text,
                        'Bhogam_ID': bsubIdController.text,
                        'Bhogam purpose': selectedPurpose,
                        'Bhogam for Name': nameController.text,
                        'Bhogam month': initialData['Bhogam month'],
                        'Bhogam start date': startDateController.text.isNotEmpty
                            ? Timestamp.fromDate(DateFormat.yMd()
                                .parse(startDateController.text))
                            : FieldValue.delete(),
                        'English Calender Date':
                            englishDateController.text.isNotEmpty
                                ? Timestamp.fromDate(DateFormat.yMd()
                                    .parse(englishDateController.text))
                                : FieldValue.delete(),
                        'Bhogam Amount': amountController.text,
                        'Bhogam thithi or nakshatram': thithiController.text,
                        'Email': emailController.text,
                        'Phone': phoneController.text,
                        'Bhogam data entered by': enteredByController.text,
                        'Are you a Sishya': selectedSishya,
                        'Bhogam valid indicator': selectedValid,
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Update Data'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: onPressed,
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null &&
        picked !=
            DateTimeRange(
                start: _startDate ?? DateTime.now(),
                end: _endDate ?? DateTime.now())) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Bhogam Masters'),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xff29BA91))),
            onPressed: _exportToCsv,
            child: Text(
              'Export',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff29BA91)),
            ),
            onPressed: () => _exportToPdf(context), // Pass the context here
            child: Text(
              'PDF',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: Color(0xff29BA91),
            ),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('BhogamDetails')
            .where('Bhogam start date',
                isGreaterThanOrEqualTo:
                    _startDate != null ? Timestamp.fromDate(_startDate!) : null)
            .where('Bhogam start date',
                isLessThanOrEqualTo:
                    _endDate != null ? Timestamp.fromDate(_endDate!) : null)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.docs ?? [];

          if (isMobile) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final doc = data[index];
                final fields = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(fields['Bhogam for Name'] ?? 'No Name'),
                    subtitle: Text(fields['Bhogam purpose'] ?? 'No Purpose'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: Color(0xff29BA91),
                          ),
                          onPressed: () {
                            _showDetailsBottomSheet(context, doc.id);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Color(0xff29BA91),
                          ),
                          onPressed: () {
                            _showEditBottomSheet(context, doc.id, fields);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Bhogam ID')),
                  DataColumn(label: Text('Bhogam purpose')),
                  DataColumn(label: Text('Bhogam for Name')),
                  DataColumn(label: Text('Bhogam month')),
                  DataColumn(label: Text('Bhogam start date')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: data.map((doc) {
                  final fields = doc.data() as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(fields['Bhogam_ID'] ?? '')),
                    DataCell(Text(fields['Bhogam purpose'] ?? '')),
                    DataCell(Text(fields['Bhogam for Name'] ?? '')),
                    DataCell(Text(fields['Bhogam month'] ?? '')),
                    DataCell(Text(fields['Bhogam start date'] is Timestamp
                        ? DateFormat.yMd().format(
                            (fields['Bhogam start date'] as Timestamp).toDate())
                        : fields['Bhogam start date'] ?? '')),
                    DataCell(Text(fields['Phone'] ?? '')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility,
                                color: Color(0xff29BA91)),
                            onPressed: () {
                              _showDetailsBottomSheet(context, doc.id);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Color(0xff286BDC),
                            ),
                            onPressed: () {
                              _showEditBottomSheet(context, doc.id, fields);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

// // import 'dart:typed_data';
// // import 'dart:html' as html;
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;

// // class DataTableScreen extends StatefulWidget {
// //   static const String id = "bhogam-edit";

// //   const DataTableScreen({Key? key}) : super(key: key);

// //   @override
// //   _DataTableScreenState createState() => _DataTableScreenState();
// // }

// // class _DataTableScreenState extends State<DataTableScreen> {
// //   DateTime? _startDate;
// //   DateTime? _endDate;

// //   Future<void> _generateAndDownloadPDF(Map<String, dynamic> fields) async {
// //     final pdf = pw.Document();

// //     pdf.addPage(
// //       pw.Page(
// //         build: (pw.Context context) {
// //           return pw.Column(
// //             crossAxisAlignment: pw.CrossAxisAlignment.start,
// //             children: fields.entries.map((entry) {
// //               return pw.Row(
// //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   pw.Text(
// //                     entry.key,
// //                     style: pw.TextStyle(
// //                       fontWeight: pw.FontWeight.bold,
// //                     ),
// //                   ),
// //                   pw.Text(entry.value.toString()),
// //                 ],
// //               );
// //             }).toList(),
// //           );
// //         },
// //       ),
// //     );

// //     final Uint8List pdfInBytes = await pdf.save();

// //     final blob = html.Blob([pdfInBytes]);
// //     final url = html.Url.createObjectUrlFromBlob(blob);

// //     final anchor = html.AnchorElement(href: url)
// //       ..setAttribute('download', 'document.pdf')
// //       ..click();

// //     html.Url.revokeObjectUrl(url);
// //   }

// //   Future<void> _showDetailsBottomSheet(
// //       BuildContext context, String documentId) async {
// //     final docSnapshot = await FirebaseFirestore.instance
// //         .collection('thirdFormSubmissions')
// //         .doc(documentId)
// //         .get();

// //     final fields = docSnapshot.data() as Map<String, dynamic>;

// //     return showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       builder: (context) {
// //         return LayoutBuilder(
// //           builder: (context, constraints) {
// //             double maxHeight = MediaQuery.of(context).size.height * 0.8;
// //             double maxWidth = constraints.maxWidth * 0.9;

// //             return ConstrainedBox(
// //               constraints: BoxConstraints(
// //                 maxHeight: maxHeight,
// //                 maxWidth: maxWidth,
// //               ),
// //               child: SingleChildScrollView(
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       SizedBox(
// //                         width: double.infinity,
// //                         child: SingleChildScrollView(
// //                           scrollDirection: Axis.horizontal,
// //                           child: DataTable(
// //                             columnSpacing: 16.0,
// //                             columns: const [
// //                               DataColumn(label: Text('Field')),
// //                               DataColumn(label: Text('Value')),
// //                             ],
// //                             rows: fields.entries.map((entry) {
// //                               return DataRow(cells: [
// //                                 DataCell(
// //                                   SizedBox(
// //                                     width: maxWidth * 0.4,
// //                                     child: Text(
// //                                       entry.key,
// //                                       style: TextStyle(
// //                                         fontSize: 16,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                       overflow: TextOverflow.ellipsis,
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 DataCell(
// //                                   SizedBox(
// //                                     width: maxWidth * 0.5,
// //                                     child: Text(
// //                                       entry.value.toString(),
// //                                       style: TextStyle(fontSize: 16),
// //                                       overflow: TextOverflow.ellipsis,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ]);
// //                             }).toList(),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(height: 20),
// //                       ElevatedButton(
// //                         onPressed: () => _generateAndDownloadPDF(fields),
// //                         child: Text('Download as PDF'),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _showEditBottomSheet(BuildContext context, String documentId,
// //       Map<String, dynamic> initialData) async {
// //     final TextEditingController subIdController =
// //         TextEditingController(text: initialData['subId']);
// //     final TextEditingController bsubIdController =
// //         TextEditingController(text: initialData['BsubId']);
// //     final TextEditingController nameController =
// //         TextEditingController(text: initialData['bhogamName']);
// //     final TextEditingController amountController =
// //         TextEditingController(text: initialData['bhogamAmount']);
// //     final TextEditingController thithiController =
// //         TextEditingController(text: initialData['Bhogamthithinakshatram']);
// //     final TextEditingController emailController =
// //         TextEditingController(text: initialData['email']);
// //     final TextEditingController phoneController =
// //         TextEditingController(text: initialData['phone']);
// //     final TextEditingController enteredByController =
// //         TextEditingController(text: initialData['Bhogamdataenteredby']);
// //     final TextEditingController startDateController =
// //         TextEditingController(text: initialData['Bhogamstartdate']);
// //     final TextEditingController englishDateController =
// //         TextEditingController(text: initialData['EnglishCalenderDate']);

// //     DateTime? startDate = initialData['Bhogamstartdate'] != null
// //         ? DateFormat.yMd().parse(initialData['Bhogamstartdate'])
// //         : null;
// //     DateTime? englishDate = initialData['EnglishCalenderDate'] != null
// //         ? DateFormat.yMd().parse(initialData['EnglishCalenderDate'])
// //         : null;

// //     List<String> purposes = ['Birthday', 'Marriage Anniversary', 'Thithi'];
// //     List<String> sishyaOptions = ['Yes', 'No'];
// //     List<String> validOptions = ['Yes', 'No'];

// //     String selectedPurpose = purposes.contains(initialData['Bhogam purpose'])
// //         ? initialData['Bhogam purpose']
// //         : purposes.first;
// //     String selectedSishya = sishyaOptions.contains(initialData['AreyouaSishya'])
// //         ? initialData['AreyouaSishya']
// //         : sishyaOptions.first;
// //     String selectedValid =
// //         validOptions.contains(initialData['bhogamvalidindicator'])
// //             ? initialData['bhogamvalidindicator']
// //             : validOptions.first;

// //     Future<void> _selectDate(BuildContext context,
// //         TextEditingController controller, DateTime? initialDate) async {
// //       final DateTime? pickedDate = await showDatePicker(
// //         context: context,
// //         initialDate: initialDate ?? DateTime.now(),
// //         firstDate: DateTime(2000),
// //         lastDate: DateTime(2101),
// //       );
// //       if (pickedDate != null && pickedDate != initialDate) {
// //         controller.text = DateFormat.yMd().format(pickedDate);
// //       }
// //     }

// //     return showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       builder: (context) {
// //         return ConstrainedBox(
// //           constraints: BoxConstraints(
// //             maxHeight: MediaQuery.of(context).size.height * 0.8,
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   _buildTextField(
// //                       controller: subIdController, label: 'Sishya ID'),
// //                   _buildTextField(
// //                       controller: bsubIdController, label: 'Bhogam ID'),
// //                   _buildDropdown<String>(
// //                     value: selectedPurpose,
// //                     label: 'Purpose',
// //                     items: purposes,
// //                     onChanged: (value) =>
// //                         setState(() => selectedPurpose = value!),
// //                   ),
// //                   _buildTextField(controller: nameController, label: 'Name'),
// //                   _buildTextField(
// //                       controller: TextEditingController(
// //                           text: initialData['bhogamMonth']),
// //                       label: 'Month'),
// //                   _buildDateField(
// //                     controller: startDateController,
// //                     label: 'Start Date',
// //                     onPressed: () =>
// //                         _selectDate(context, startDateController, startDate),
// //                   ),
// //                   _buildDateField(
// //                     controller: englishDateController,
// //                     label: 'English Date',
// //                     onPressed: () => _selectDate(
// //                         context, englishDateController, englishDate),
// //                   ),
// //                   _buildTextField(
// //                       controller: amountController, label: 'Amount'),
// //                   _buildTextField(
// //                       controller: thithiController, label: 'Thithi/Nakshatram'),
// //                   _buildTextField(controller: emailController, label: 'Email'),
// //                   _buildTextField(controller: phoneController, label: 'Phone'),
// //                   _buildTextField(
// //                       controller: enteredByController, label: 'Entered By'),
// //                   _buildDropdown<String>(
// //                     value: selectedSishya,
// //                     label: 'Sishya?',
// //                     items: sishyaOptions,
// //                     onChanged: (value) =>
// //                         setState(() => selectedSishya = value!),
// //                   ),
// //                   _buildDropdown<String>(
// //                     value: selectedValid,
// //                     label: 'Valid?',
// //                     items: validOptions,
// //                     onChanged: (value) =>
// //                         setState(() => selectedValid = value!),
// //                   ),
// //                   SizedBox(height: 20),
// //                   ElevatedButton(
// //                     onPressed: () async {
// //                       await FirebaseFirestore.instance
// //                           .collection('thirdFormSubmissions')
// //                           .doc(documentId)
// //                           .update({
// //                         'subId': subIdController.text,
// //                         'BsubId': bsubIdController.text,
// //                         'Bhogam purpose': selectedPurpose,
// //                         'bhogamName': nameController.text,
// //                         'bhogamAmount': amountController.text,
// //                         'Bhogamthithinakshatram': thithiController.text,
// //                         'email': emailController.text,
// //                         'phone': phoneController.text,
// //                         'Bhogamstartdate': startDateController.text,
// //                         'EnglishCalenderDate': englishDateController.text,
// //                         'Bhogamdataenteredby': enteredByController.text,
// //                         'AreyouaSishya': selectedSishya,
// //                         'bhogamvalidindicator': selectedValid,
// //                       });
// //                       Navigator.pop(context);
// //                     },
// //                     child: Text('Update'),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildTextField({
// //     required TextEditingController controller,
// //     required String label,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: TextField(
// //         controller: controller,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           border: OutlineInputBorder(),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDropdown<T>({
// //     required T value,
// //     required String label,
// //     required List<T> items,
// //     required ValueChanged<T?> onChanged,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: DropdownButtonFormField<T>(
// //         value: value,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           border: OutlineInputBorder(),
// //         ),
// //         items: items.map((T item) {
// //           return DropdownMenuItem<T>(
// //             value: item,
// //             child: Text(item.toString()),
// //           );
// //         }).toList(),
// //         onChanged: onChanged,
// //       ),
// //     );
// //   }

// //   Widget _buildDateField({
// //     required TextEditingController controller,
// //     required String label,
// //     required VoidCallback onPressed,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextField(
// //               controller: controller,
// //               decoration: InputDecoration(
// //                 labelText: label,
// //                 border: OutlineInputBorder(),
// //               ),
// //               readOnly: true,
// //             ),
// //           ),
// //           IconButton(
// //             icon: Icon(Icons.calendar_today),
// //             onPressed: onPressed,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Data Table'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             // Here you would fetch and display your data, possibly in a DataTable
// //             // For example purposes, assuming you have a list of document IDs:
// //             Expanded(
// //               child: FutureBuilder<QuerySnapshot>(
// //                 future: FirebaseFirestore.instance
// //                     .collection('thirdFormSubmissions')
// //                     .get(),
// //                 builder: (context, snapshot) {
// //                   if (snapshot.connectionState == ConnectionState.waiting) {
// //                     return Center(child: CircularProgressIndicator());
// //                   }

// //                   if (snapshot.hasError) {
// //                     return Center(child: Text('Error: ${snapshot.error}'));
// //                   }

// //                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                     return Center(child: Text('No data found.'));
// //                   }

// //                   final documents = snapshot.data!.docs;

// //                   return ListView.builder(
// //                     itemCount: documents.length,
// //                     itemBuilder: (context, index) {
// //                       final doc = documents[index];
// //                       final data = doc.data() as Map<String, dynamic>;

// //                       return ListTile(
// //                         title: Text(data['bhogamName'] ?? 'No Name'),
// //                         subtitle: Text(data['subId'] ?? 'No ID'),
// //                         trailing: IconButton(
// //                           icon: Icon(Icons.edit),
// //                           onPressed: () =>
// //                               _showEditBottomSheet(context, doc.id, data),
// //                         ),
// //                         onTap: () => _showDetailsBottomSheet(context, doc.id),
// //                       );
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:cms/Pages/bhogamm.dart';
// import 'package:cms/api%20service/api.dart';
// import 'package:cms/api%20service/bhogammodel.dart';
// import 'package:flutter/material.dart';

// class DisplayData extends StatefulWidget {
//   static const String id = "bhogam-edit";
//   const DisplayData({super.key, this.data});

//   final Bhogam? data;

//   @override
//   State<DisplayData> createState() => _DisplayDataState();
// }

// class _DisplayDataState extends State<DisplayData> {
//   final bhogamnameCon = TextEditingController();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('display'),
//       ),
//       body: FutureBuilder(
//         future: Api.viewBhogam(),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.hasData) {
//             List<Bhogam> bdata = snapshot.data;
//             return ListView.builder(
//               itemCount: bdata.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                     title: Text("Bhogam Name: ${bdata[index].bhogamname}"),
//                     subtitle:
//                         Text("Bhogam date: ${bdata[index].Bbhogamstartdate}"),
//                     trailing: IconButton(
//                         onPressed: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (_) => Bhogamedit(data: bdata[index])));
//                         },
//                         icon: Icon(Icons.edit)));
//               },
//             );
//           } else {
//             return Center(
//               child: Text('no data found'),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:cms/api%20service/bhogamm.dart';
// import 'package:cms/api%20service/api.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Import the intl package

// class DisplayData extends StatefulWidget {
//   static const String id = 'DisplayData-id';
//   const DisplayData({super.key});

//   @override
//   _DisplayDataState createState() => _DisplayDataState();
// }

// class _DisplayDataState extends State<DisplayData> {
//   final ApiService _apiService = ApiService();
//   List<dynamic> _users = [];
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     try {
//       final users = await _apiService.getUsers();
//       setState(() {
//         _users = users;
//         _isLoading = false;
//       });
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'Failed to load users';
//         _isLoading = false;
//       });
//     }
//   }

//   void _navigateToEditUserPage(
//     String id,
//     String bhogamName,
//     String bhogamEmail,
//   ) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => Bhogamedit(
//               bhogamEmail: bhogamEmail, bhogamName: bhogamName, id: id)),
//     ).then((_) => _fetchUsers()); // Refresh the list after editing
//   }

//   String _formatDate(String date) {
//     try {
//       final DateTime parsedDate = DateTime.parse(date);
//       final DateFormat formatter = DateFormat('dd/MM/yyyy');
//       return formatter.format(parsedDate);
//     } catch (e) {
//       // Handle the case where the date is invalid or cannot be parsed
//       return 'Invalid date';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User List'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.pushNamed(context, '/add')
//                   .then((_) => _fetchUsers()); // Refresh the list after adding
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//               ? Center(child: Text(_errorMessage))
//               : ListView.builder(
//                   itemCount: _users.length,
//                   itemBuilder: (context, index) {
//                     final user = _users[index];
//                     final date = user['date'] ??
//                         'No date'; // Default value if date is not available
//                     final formattedDate = _formatDate(date);
//                     final under18 = user['under18'] ??
//                         'No'; // Default value if under18 is not available

//                     return ListTile(
//                       title: Text(user['name']),
//                       subtitle: Text(
//                           '${user['email']} \nDate: $formattedDate \nUnder 18: $under18'),
//                       trailing: IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () {
//                           _navigateToEditUserPage(
//                             user['id'].toString(),
//                             user['name'],
//                             user['email'],
//                             // Pass under18 to the edit page
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
