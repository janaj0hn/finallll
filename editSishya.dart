import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  static const String id = 'sishya=edit';
  final String searchTerm;
  HistoryPage({required this.searchTerm});
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<void> _exportToCsv() async {
    try {
      final snapshot = await _firestore.collection('SishyaDetails').get();
      final Map<String, List<Map<String, dynamic>>> groupedData = {};

      // Grouping the data by id
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final idKey =
            data['Address_ID'] ?? 'Unknown'; // Use the ID for grouping

        if (!groupedData.containsKey(idKey)) {
          groupedData[idKey] = [];
        }
        groupedData[idKey]!.add(data);
      }

      final rows = <List<String>>[];
      // Header row
      rows.add([
        'Address_ID',
        'Shisya_ID',
        'Name',
        'Mobile 1',
        'Mobile 2',
        'Sishya Type',
        'Date of Birth',
        'Samasreyanam Date',
        'Whatsapp',
        'Email',
        'Facebook',
        'Care or of part',
        'Alias or Extra identity',
        'Sishya data entered by',
        'Sishya valid indicator',
        'Is Sishya the family point of contact',
      ]);

      // Data rows
      for (var entry in groupedData.entries) {
        final id = entry.key;
        final details = entry.value;

        // Add the first detail with the ID
        if (details.isNotEmpty) {
          final firstDetail = details[0];

          rows.add([
            id, // Show ID once
            firstDetail['Shisya_ID'] ?? '',
            firstDetail['Name'] ?? '',
            firstDetail['Mobile 1'] ?? '',
            firstDetail['Mobile 2'] ?? '',
            firstDetail['Sishya Type'] ?? '',
            firstDetail['Date of Birth'] ?? '',
            firstDetail['Samasreyanam Date'] ?? '',
            firstDetail['Whatsapp'] ?? '',
            firstDetail['Email'] ?? '',
            firstDetail['Facebook'] ?? '',
            firstDetail['Care or of part'] ?? '',
            firstDetail['Alias or Extra identity'] ?? '',
            firstDetail['Sishya data entered by'] ?? '',
            firstDetail['Sishya valid indicator'] ?? '',
            firstDetail['Is Sishya the family point of contact'] ?? '',
          ]);

          // For subsequent details, add rows without the ID
          for (var i = 1; i < details.length; i++) {
            final detail = details[i];

            rows.add([
              '', // Leave ID empty for subsequent entries
              detail['Shisya_ID'] ?? '',
              detail['Name'] ?? '',
              detail['Mobile 1'] ?? '',
              detail['Mobile 2'] ?? '',
              detail['Sishya Type'] ?? '',
              detail['Date of Birth'] ?? '',
              detail['Samasreyanam Date'] ?? '',
              detail['Whatsapp'] ?? '',
              detail['Email'] ?? '',
              detail['Facebook'] ?? '',
              detail['Care or of part'] ?? '',
              detail['Alias or Extra identity'] ?? '',
              detail['Sishya data entered by'] ?? '',
              detail['Sishya valid indicator'] ?? '',
              detail['Is Sishya the family point of contact'] ?? '',
            ]);
          }
        }
      }

      // Convert to CSV format
      String csvData = const ListToCsvConverter().convert(rows);
      final blob =
          html.Blob([Uint8List.fromList(utf8.encode(csvData))], 'text/csv');
      final url = html.Url.createObjectUrl(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'sishya_data.csv')
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error exporting to CSV: $e');
    }
  }

  Future<void> _importFromCsv() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) {
        print('No file selected');
        return;
      }

      final file = files[0];
      final reader = html.FileReader();

      reader.readAsText(file);

      reader.onLoadEnd.listen((e) async {
        final content = reader.result as String;
        final csvConverter = CsvToListConverter();
        final rows = csvConverter.convert(content);

        if (rows.isEmpty) {
          print('No data found in CSV');
          return;
        }

        // Assuming the first row contains headers
        final headers = rows.first
            .map((header) => _sanitizeFieldName(header.toString()))
            .toList();
        final dataRows = rows.sublist(1);

        int rowCount = 0;

        for (var row in dataRows) {
          if (row.isEmpty) {
            print('Empty row found');
            continue;
          }

          final data = <String, dynamic>{};
          for (var i = 0; i < row.length; i++) {
            if (i < headers.length) {
              data[headers[i]] = row[i]?.toString() ?? '';
            }
          }

          // Generate a unique ID for each record
          final String subId =
              await generateShortId(); // Adjust length as needed
          data['Shisya_ID'] = subId; // Include the generated ID in the data

          print('Data to upload: $data');

          try {
            await FirebaseFirestore.instance
                .collection('SishyaDetails')
                .doc(subId)
                .set(data, SetOptions(merge: true));
            rowCount++;
          } catch (e) {
            print('Error uploading data to Firestore: $e');
          }
        }

        if (rowCount > 0) {
          await _updateSubmissionCounts('sishyasCount', rowCount);
        }
      });
    });

    uploadInput.click();
  }

  String _sanitizeFieldName(String fieldName) {
    return fieldName.replaceAll(RegExp(r'^__|__$'), '');
  }

  Future<String> generateShortId() async {
    const String prefix = 'SH';
    final int idLength =
        6; // Length of the numeric part (total length - prefix length)

    // Reference to the Firestore document that holds the last used number
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('customIdsSishya')
        .doc('lastIdSH');

    // Fetch the last used number
    DocumentSnapshot doc = await docRef.get();
    int lastNumber = 0;

    if (doc.exists) {
      lastNumber = (doc.data() as Map<String, dynamic>)['lastNumber'] ?? 0;
    }

    // Increment the last number for the new ID
    lastNumber++;
    String newId = '$prefix${lastNumber.toString().padLeft(idLength, '0')}';

    // Update Firestore with the new last number
    await docRef.set({'lastNumber': lastNumber}, SetOptions(merge: true));

    return newId;
  }

  Future<void> _updateSubmissionCounts(
      String countType, int countIncrement) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('submissionCounts')
          .doc('counts');
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        int currentCount = data[countType] ?? 0;

        await docRef.update({
          countType: currentCount + countIncrement,
        });
      } else {
        await docRef.set({
          countType: countIncrement,
        });
      }
    } catch (e) {
      print('Error updating submission counts: $e');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedDistrict;

  Future<List<String>> _fetchDistricts() async {
    final snapshot = await _firestore.collection('AddressDetails').get();
    final districts = <String>{};

    for (var doc in snapshot.docs) {
      if (doc.data().containsKey('District')) {
        // Normalize to lower case before adding
        districts.add(doc['District'].toLowerCase());
      }
    }

    return districts.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Sishyas Masters'),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xff286BDC))),
            onPressed: _importFromCsv,
            child: Text(
              'Import',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xff29BA91))),
            onPressed: _exportToCsv,
            child: Text(
              'Export',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
              future: _fetchDistricts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final districts = snapshot.data!;

                return DropdownButton<String>(
                  hint: Text('Select District'),
                  value: _selectedDistrict,
                  items: districts.map((district) {
                    // Convert to proper case for display
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(
                          district[0].toUpperCase() + district.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('AddressDetails')
                    .where('District',
                        isEqualTo: _selectedDistrict
                            ?.toLowerCase()) // Normalize here as well
                    .snapshots(),
                builder: (context, firstFormSnapshot) {
                  if (!firstFormSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final firstFormEntries = firstFormSnapshot.data!.docs;

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('SishyaDetails').snapshots(),
                    builder: (context, secondFormSnapshot) {
                      if (!secondFormSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final secondFormEntries = secondFormSnapshot.data!.docs;

                      Map<String, List<Map<String, dynamic>>>
                          groupedSubmissions = {};

                      for (var entry in firstFormEntries) {
                        String id = entry['Address_ID'];
                        groupedSubmissions[id] = [];
                      }

                      for (var entry in secondFormEntries) {
                        String id = entry['Address_ID'];
                        if (groupedSubmissions.containsKey(id)) {
                          groupedSubmissions[id]!
                              .add(entry.data() as Map<String, dynamic>);
                        }
                      }

                      //search
                      if (widget.searchTerm.isNotEmpty) {
                        groupedSubmissions.removeWhere((key, value) {
                          return !value.any((detail) => detail['Mobile 1']
                              .toLowerCase()
                              .contains(widget.searchTerm.toLowerCase()));
                        });
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            // Mobile view
                            return ListView(
                              children: groupedSubmissions.entries.map((group) {
                                String id = group.key;
                                List<Map<String, dynamic>> details =
                                    group.value;

                                return Column(
                                  children: details.map((detail) {
                                    String subId = detail['Shisya_ID'] ?? '';

                                    return Card(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        title: Text('Sishya ID: $subId'),
                                        subtitle:
                                            Text(detail['Name'] ?? 'No Name'),
                                        onTap: () {
                                          _showDetailsBottomSheet(
                                            id,
                                            subId,
                                            detail,
                                          );
                                        },
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Color(0xff29BA91),
                                          ),
                                          onPressed: () {
                                            _showEditBottomSheet(
                                              id,
                                              subId,
                                              detail,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            );
                          } else {
                            // Desktop view
                            return ListView(
                              children: groupedSubmissions.entries.map((group) {
                                String id = group.key;
                                List<Map<String, dynamic>> details =
                                    group.value;

                                return Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Address ID: $id',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columnSpacing: 12,
                                            columns: [
                                              DataColumn(
                                                  label: Text('Sishya ID')),
                                              DataColumn(
                                                  label: Text('Sishya Type')),
                                              DataColumn(label: Text('Name')),
                                              DataColumn(
                                                  label: Text('Date of Birth')),
                                              DataColumn(
                                                  label: Text(
                                                      'Samasreyanam Date')),
                                              DataColumn(
                                                  label: Text('Mobile 1')),
                                              DataColumn(
                                                  label: Text('Actions')),
                                            ],
                                            rows: details.map((detail) {
                                              String subId =
                                                  detail['Shisya_ID'] ?? '';
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: 100,
                                                      ),
                                                      child: Text(
                                                        subId,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: 200,
                                                      ),
                                                      child: Text(
                                                        detail['Sishya Type'] ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: 150,
                                                      ),
                                                      child: Text(
                                                        detail['Name'] ?? '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: 150,
                                                      ),
                                                      child: Text(
                                                        detail['Date of Birth'] ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: 150,
                                                      ),
                                                      child: Text(
                                                        detail['Samasreyanam Date'] ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: 150,
                                                      ),
                                                      child: Text(
                                                        detail['Mobile 1'] ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons.edit,
                                                              color: Color(
                                                                  0xff286BDC)),
                                                          onPressed: () {
                                                            _showEditBottomSheet(
                                                              id,
                                                              subId,
                                                              detail,
                                                            );
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.visibility,
                                                            color: Color(
                                                                0xff29BA91),
                                                          ),
                                                          onPressed: () {
                                                            _showDetailsBottomSheet(
                                                              id,
                                                              subId,
                                                              detail,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(
      String id, String subId, Map<String, dynamic> detail) async {
    final predefinedSishyavalidindicator = ['YES', 'NO'];
    final predefinedIsSishyathefamilypointofcontact = ['YES', 'NO'];

    // Ensure a valid default value for the dropdown

    String selectedSishyavalidindicator = detail['Sishya valid indicator'] ??
        predefinedSishyavalidindicator.first;
    String selectedIsSishyathefamilypointofcontact =
        detail['Is Sishya the Family Point of Contact'] ??
            predefinedIsSishyathefamilypointofcontact.first;

    final nameController = TextEditingController(text: detail['Name']);
    final sishyaTypeController =
        TextEditingController(text: detail['Sishya Type']);
    final dobController = TextEditingController(text: detail['Date of Birth']);
    final samasreyanamDateController =
        TextEditingController(text: detail['Samasreyanam Date']);
    final mobileController = TextEditingController(text: detail['Mobile 1']);
    final mobile2Controller = TextEditingController(text: detail['Mobile 2']);
    final whatsappController = TextEditingController(text: detail['Whatsapp']);
    final emailController = TextEditingController(text: detail['Email']);
    final facebookLinkController =
        TextEditingController(text: detail['Facebook']);
    final careOfPartController =
        TextEditingController(text: detail['Care or of part']);
    final aliasExtraController =
        TextEditingController(text: detail['Alias or Extra identity']);
    final SishyadataenteredbyController =
        TextEditingController(text: detail['Sishya data entered by']);

    // Method to show date picker
    Future<void> _selectDate(
        BuildContext context, TextEditingController controller) async {
      DateTime? selectedDate = DateTime.tryParse(controller.text);
      selectedDate = selectedDate ?? DateTime.now();

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

      if (picked != null && picked != selectedDate) {
        controller.text =
            DateFormat('MM/dd/yyyy').format(picked); // Format to MM/dd/yyyy
        // Format to YYYY-MM-DD
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 600,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: sishyaTypeController,
                    decoration: InputDecoration(labelText: 'Sishya Type'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(labelText: 'Date of Birth'),
                    readOnly: true,
                    onTap: () => _selectDate(context, dobController),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: samasreyanamDateController,
                    decoration: InputDecoration(labelText: 'Samasreyanam Date'),
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, samasreyanamDateController),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: careOfPartController,
                    decoration: InputDecoration(labelText: 'Care or of Part'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: aliasExtraController,
                    decoration:
                        InputDecoration(labelText: 'Alias or Extra identity'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(labelText: 'Mobile 1'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: mobile2Controller,
                    decoration: InputDecoration(labelText: 'Mobile 2'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: whatsappController,
                    decoration: InputDecoration(labelText: 'WhatsApp'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: facebookLinkController,
                    decoration: InputDecoration(labelText: 'Facebook'),
                  ),
                  // DropdownButton for SetID
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: predefinedIsSishyathefamilypointofcontact
                            .contains(selectedIsSishyathefamilypointofcontact)
                        ? selectedIsSishyathefamilypointofcontact
                        : predefinedIsSishyathefamilypointofcontact.first,
                    items:
                        predefinedIsSishyathefamilypointofcontact.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedIsSishyathefamilypointofcontact = value!;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'Is Sishya the Family Point of Contact'),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: predefinedSishyavalidindicator
                            .contains(selectedSishyavalidindicator)
                        ? selectedSishyavalidindicator
                        : predefinedSishyavalidindicator.first,
                    items: predefinedSishyavalidindicator.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSishyavalidindicator = value!;
                      });
                    },
                    decoration:
                        InputDecoration(labelText: 'Sishya valid indicator?'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: SishyadataenteredbyController,
                    decoration:
                        InputDecoration(labelText: 'Sishya data entered by'),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateEntry(
                            id,
                            subId,
                            nameController.text,
                            sishyaTypeController.text,
                            dobController.text,
                            samasreyanamDateController.text,
                            mobileController.text,
                            mobile2Controller.text,
                            whatsappController.text,
                            emailController.text,
                            facebookLinkController.text,
                            careOfPartController.text,
                            aliasExtraController.text,
                            SishyadataenteredbyController.text,
                            selectedSishyavalidindicator,
                            selectedIsSishyathefamilypointofcontact,
                          );
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetailsBottomSheet(
      String id, String subId, Map<String, dynamic> detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 600,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sishya ID: $subId',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow('Sishya Type', detail['Sishya Type']),
                      _buildDetailRow('Name', detail['Name']),
                      _buildDetailRow(
                          'Care or of Part', detail['Care or of part']),
                      _buildDetailRow('Alias or Extra identity',
                          detail['Alias or Extra identity']),
                      _buildDetailRow('Date of Birth', detail['Date of Birth']),
                      _buildDetailRow(
                          'Samasreyanam Date', detail['Samasreyanam Date']),
                      _buildDetailRow('Mobile 1', detail['Mobile 1']),
                      _buildDetailRow('Mobile 2', detail['Mobile 2']),
                      _buildDetailRow('WhatsApp', detail['Whatsapp']),
                      _buildDetailRow('Email', detail['Email']),
                      _buildDetailRow('Facebook', detail['Facebook']),
                      _buildDetailRow('Is Sishya the Family Point of Contact',
                          detail['Is Sishya the Family Point of Contact']),
                      _buildDetailRow('Sishya valid indicator',
                          detail['Sishya valid indicator']),
                      _buildDetailRow('Sishya data entered by',
                          detail['Sishya data entered by']),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Helper method to build rows for details
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEntry(
    String id,
    String subId,
    String name,
    String sishyaType,
    String dob,
    String samasreyanamDate,
    String mobile,
    String mobile2,
    String whatsapp,
    String email,
    String facebookLink,
    String careOfPart,
    String aliasExtra,
    String Sishyadataenteredby,
    String Sishyavalidindicator,
    String IsSishyathefamilypointofcontact,
  ) async {
    try {
      // Ensure you are targeting the correct document
      final documentSnapshot = await _firestore
          .collection('SishyaDetails')
          .where('Shisya_ID', isEqualTo: subId)
          .where('Address_ID', isEqualTo: id)
          .get();

      if (documentSnapshot.docs.isNotEmpty) {
        // If the document exists, update it
        final documentId = documentSnapshot.docs.first.id;
        await _firestore.collection('SishyaDetails').doc(documentId).update({
          'Sishya Type': sishyaType,
          'Name': name,
          'Date of Birth': dob,
          'Samasreyanam Date': samasreyanamDate,
          'Mobile 1': mobile,
          'Mobile 2': mobile2,
          'Whatsapp': whatsapp,
          'Email': email,
          'Facebook': facebookLink,
          'Care or of part': careOfPart,
          'Alias or Extra identity': aliasExtra,
          'Sishya data entered by': Sishyadataenteredby,
          "Sishya valid indicator": Sishyavalidindicator,
          "Is Sishya the Family Point of Contact":
              IsSishyathefamilypointofcontact,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry updated successfully')),
        );
      } else {
        // Document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No document found to update')),
        );
      }
    } catch (error) {
      // Log detailed error information
      print('Failed to update entry: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update entry: $error')),
      );
    }
  }
}
