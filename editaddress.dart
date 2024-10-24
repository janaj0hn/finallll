// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'dart:html' as html;

// class AddressDataTable extends StatelessWidget {
//   static const String id = 'address=edit';
//   // Define the custom order for fields and the fields to display in the DataTable
//   final List<String> _fieldOrder = [
//     'id',
//     'address line 1',
//     'address line 2',
//     'address line 3',
//     'city',
//     'taluk',
//     'district',
//     'state',
//     'country',
//     'Pincode',
//     'Landmark',
//     'LandlinenumberCountry',
//     'Landlinenumber',
//     'address valid indicator',
//     'Addressdataentered',
//   ];

//   final List<String> _visibleFields = [
//     'id',
//     'address line 1',
//     'address line 2',
//     'address line 3',
//     'city',
//     'taluk',
//   ];
//   // Future<void> _generateAndDownloadPDF(Map<String, dynamic> fields) async {
//   //   final pdf = pw.Document();

//   //   pdf.addPage(
//   //     pw.Page(
//   //       build: (pw.Context context) {
//   //         return pw.Column(
//   //           crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //           children: fields.entries.map((entry) {
//   //             return pw.Row(
//   //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//   //               children: [
//   //                 pw.Text(
//   //                   entry.key,
//   //                   style: pw.TextStyle(
//   //                     fontWeight: pw.FontWeight.bold,
//   //                   ),
//   //                 ),
//   //                 pw.Text(entry.value.toString()),
//   //               ],
//   //             );
//   //           }).toList(),
//   //         );
//   //       },
//   //     ),
//   //   );

//   //   final Uint8List pdfInBytes = await pdf.save();

//   //   final blob = html.Blob([pdfInBytes]);
//   //   final url = html.Url.createObjectUrlFromBlob(blob);

//   //   final anchor = html.AnchorElement(href: url)
//   //     ..setAttribute('download', 'document.pdf')
//   //     ..click();

//   //   html.Url.revokeObjectUrl(url);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('All Address Masters')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('firstFormSubmissions')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final data = snapshot.data?.docs ?? [];

//           // Grouping data by district
//           Map<String, List<Map<String, dynamic>>> groupedData = {};
//           for (var doc in data) {
//             final fields = doc.data() as Map<String, dynamic>;
//             final district = fields['district'] ?? 'Unknown';
//             if (!groupedData.containsKey(district)) {
//               groupedData[district] = [];
//             }
//             groupedData[district]!.add(fields);
//           }

//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               columns: _buildColumns(),
//               rows: groupedData.entries.expand((entry) {
//                 String district = entry.key;
//                 List<Map<String, dynamic>> addresses = entry.value;

//                 // Create a header row for the district
//                 List<DataRow> rows = [
//                   DataRow(cells: [
//                     DataCell(Text(district,
//                         style: TextStyle(fontWeight: FontWeight.bold))),
//                     ...List.generate(_visibleFields.length - 1,
//                         (_) => DataCell(Text(''))), // Empty cells
//                     DataCell(Text('Actions')),
//                   ])
//                 ];

//                 // Add each address as a row under the district
//                 for (var fields in addresses) {
//                   rows.add(DataRow(
//                       cells: _buildCells(fields, context, fields['id'])));
//                 }

//                 return rows;
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   List<DataColumn> _buildColumns() {
//     // Build columns based on the visible fields
//     return _visibleFields.map((field) {
//       return DataColumn(label: Text(field.replaceAll('_', ' ')));
//     }).toList()
//       ..add(DataColumn(label: Text('Actions')));
//   }

//   List<DataCell> _buildCells(
//       Map<String, dynamic> fields, BuildContext context, String docId) {
//     // Build cells based on the visible fields
//     return _visibleFields.map((field) {
//       return DataCell(Text(fields[field] ?? ''));
//     }).toList()
//       ..add(DataCell(Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           IconButton(
//             icon: Icon(Icons.visibility),
//             onPressed: () => _showDetailsBottomSheet(context, docId, fields),
//           ),
//           IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: () => _showEditBottomSheet(context, docId, fields),
//           ),
//         ],
//       )));
//   }

//   void _showEditBottomSheet(
//       BuildContext context, String docId, Map<String, dynamic> fields) {
//     final _formKey = GlobalKey<FormState>();
//     final Map<String, TextEditingController> _controllers = {};
//     final List<String> validIndicators = [
//       'Yes',
//       'No'
//     ]; // Options for the dropdown

//     // Initialize controllers based on the custom order
//     for (var field in _fieldOrder) {
//       _controllers[field] =
//           TextEditingController(text: fields[field]?.toString());
//     }

//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: _fieldOrder.map((field) {
//                       if (field == 'address valid indicator') {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: DropdownButtonFormField<String>(
//                             value: _controllers[field]?.text,
//                             decoration: InputDecoration(
//                                 labelText: field.replaceAll('_', ' ')),
//                             items: validIndicators.map((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             }).toList(),
//                             onChanged: (String? newValue) {
//                               if (newValue != null) {
//                                 _controllers[field]?.text = newValue;
//                               }
//                             },
//                           ),
//                         );
//                       } else {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: TextFormField(
//                             controller: _controllers[field],
//                             decoration: InputDecoration(
//                                 labelText: field.replaceAll('_', ' ')),
//                             validator: (value) => value == null || value.isEmpty
//                                 ? 'Please enter a value'
//                                 : null,
//                           ),
//                         );
//                       }
//                     }).toList(),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState?.validate() ?? false) {
//                       final updatedData = _controllers.map(
//                           (key, controller) => MapEntry(key, controller.text));
//                       await FirebaseFirestore.instance
//                           .collection('firstFormSubmissions')
//                           .doc(docId)
//                           .update(updatedData);
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('Save Changes'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showDetailsBottomSheet(
//       BuildContext context, String docId, Map<String, dynamic> fields) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: _fieldOrder.map((field) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 field.replaceAll('_', ' '),
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 3,
//                               child: Text(fields[field]?.toString() ?? ''),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close the bottom sheet
//                   },
//                   child: Text('Close'),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;

class AddressDataTable extends StatelessWidget {
  static const String id = 'address-edit';

  final List<String> _fieldOrder = [
    'Address_ID',
    'Address Line 1',
    'Address Line 2',
    'Address Line 3',
    'City or Town',
    'Taluk',
    'District',
    'State',
    'Country',
    'Pincode or Zipcode',
    'Landmark',
    'Landline number Country or STD code',
    'Landline Number',
    'Address valid indicator',
    'Address data entered by',
  ];

  final List<String> _visibleFields = [
    'Address_ID',
    'Address Line 1',
    'Address Line 2',
    'Address Line 3',
    'City or Town',
    'Taluk',
  ];
// Add this method to export data

  // Cleanup
  Future<void> _exportToCsv() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('AddressDetails').get();

    List<List<dynamic>> csvData = [];
    Map<String, List<Map<String, dynamic>>> districtMap = {};

    // Add headers
    csvData.add(_fieldOrder);

    for (var doc in snapshot.docs) {
      final fields = doc.data() as Map<String, dynamic>;
      // Normalize district name to lowercase
      final district =
          (fields['District'] ?? 'Unknown').toString().toLowerCase();

      // Add the fields to the corresponding district in the map
      if (!districtMap.containsKey(district)) {
        districtMap[district] = [];
      }
      districtMap[district]!.add(fields);
    }

    // Now create the CSV data from the districtMap
    for (var district in districtMap.keys) {
      // Add district name in original case as header
      final originalDistrictName = districtMap.keys.firstWhere(
        (key) => key.toLowerCase() == district,
        orElse: () => district,
      );

      csvData.add([originalDistrictName]); // Add district as a new row

      for (var fields in districtMap[district]!) {
        // Create a row with other fields
        final row = _fieldOrder.map((field) => fields[field] ?? '').toList();
        csvData.add(row);
      }
    }

    String csvString = const ListToCsvConverter().convert(csvData);

    final bytes = utf8.encode(csvString);
    final blob = html.Blob([Uint8List.fromList(bytes)], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'address_data.csv')
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> _importFromCsv() async {
    const int expectedFieldCount =
        8; // Adjust this number based on your CSV structure

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

        if (rows.isEmpty || rows.length < 2) {
          print('No data found in CSV or insufficient data');
          return;
        }

        final headers = rows.first
            .map((header) => _sanitizeFieldName(header.toString()))
            .toList();
        final dataRows = rows.sublist(1);

        int rowCount = 0;
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var row in dataRows) {
          if (row.isEmpty || row.length < expectedFieldCount) {
            print('Empty or insufficient row found: $row');
            continue;
          }

          final data = <String, dynamic>{};
          for (var i = 0; i < headers.length; i++) {
            if (i < row.length) {
              data[headers[i]] = row[i]?.toString() ?? '';
            }
          }

          // Check for required fields
          if (data['District'] == null || data['District'].isEmpty) {
            print('Missing required field for district: $data');
            continue; // Skip this row
          }

          final String id = await generateShortId();
          data['Address_ID'] = id;

          DocumentReference docRef =
              FirebaseFirestore.instance.collection('AddressDetails').doc(id);
          batch.set(docRef, data, SetOptions(merge: true));

          rowCount++;

          if (rowCount % 500 == 0) {
            await batch.commit();
            batch = FirebaseFirestore.instance.batch();
          }
        }

        await batch.commit();

        if (rowCount > 0) {
          await _updateSubmissionCounts('addressCount', rowCount);
          print('Successfully imported $rowCount rows');
        }
      });
    });

    uploadInput.click();
  }

  String _sanitizeFieldName(String fieldName) {
    return fieldName.replaceAll(RegExp(r'^__|__$'), '');
  }

  Future<String> generateShortId() async {
    const String prefix = 'AD';
    final int idLength =
        6; // Length of the numeric part (total length - prefix length)

    // Reference to the Firestore document that holds the last used number
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('AddressIds').doc('lastId');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Address Masters'),
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
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('AddressDetails')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final Map<String, List<Map<String, dynamic>>> groupedData = {};
            final data = snapshot.data?.docs ?? [];

            // Group data by normalized district names

            for (var doc in data) {
              final fields = doc.data() as Map<String, dynamic>;
              final district = (fields['District'] ?? 'Unknown').toLowerCase();
              final displayDistrict = _capitalizeWords(district);

              // Store the Firestore document ID in a separate field
              final firestoreId = doc.id; // This is the Firestore ID

              if (!groupedData.containsKey(displayDistrict)) {
                groupedData[displayDistrict] = [];
              }

              // Ensure custom ID is preserved for display
              fields['custom_id'] = fields['Address_ID']; // Your custom ID
              fields['firestore_id'] = firestoreId; // Firestore document ID

              groupedData[displayDistrict]!.add(fields);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: groupedData.entries.map((entry) {
                      final district = entry.key;
                      final addresses = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.grey[200],
                            child: Text('District: $district',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ...addresses.map((fields) {
                            final customId = fields['custom_id'] ??
                                'Unknown ID'; // Display custom ID
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(fields['Address Line 1'] ?? ''),
                                subtitle: Text(fields['City or Town'] ?? ''),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.visibility),
                                      onPressed: () => _showDetailsBottomSheet(
                                          context,
                                          customId,
                                          fields), // Use custom ID
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showEditBottomSheet(
                                          context,
                                          fields['firestore_id'],
                                          fields), // Use Firestore ID for editing
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: _buildColumns(),
                          rows: groupedData.entries.expand((entry) {
                            final district = entry.key;
                            final addresses = entry.value;

                            // District header row
                            final districtHeaderRow = DataRow(
                              cells: [
                                DataCell(Text(
                                  'District: $district',
                                  style: TextStyle(
                                      backgroundColor: Color(0xff29BA91),
                                      color: Colors.white),
                                )),
                                ...List.generate(_visibleFields.length - 1,
                                    (index) => DataCell(Text(''))),
                                DataCell(Text('')),
                              ],
                            );

                            // Address rows
                            final addressRows = addresses.map((fields) {
                              final customId = fields['custom_id'] ??
                                  'Unknown ID'; // Display custom ID
                              return DataRow(
                                cells: _buildCells(
                                    fields,
                                    context,
                                    fields[
                                        'firestore_id']), // Use Firestore ID for cells
                              );
                            }).toList();

                            return [districtHeaderRow, ...addressRows];
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return _visibleFields.map((field) {
      return DataColumn(label: Text(field.replaceAll('_', ' ')));
    }).toList()
      ..add(DataColumn(label: Text('Actions')));
  }

  List<DataCell> _buildCells(
      Map<String, dynamic> fields, BuildContext context, String docId) {
    return _visibleFields.map((field) {
      return DataCell(Text(fields[field] ?? ''));
    }).toList()
      ..add(DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.visibility,
              color: Color(0xff29BA91),
            ),
            onPressed: () => _showDetailsBottomSheet(context, docId, fields),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Color(0xff286BDC),
            ),
            onPressed: () => _showEditBottomSheet(context, docId, fields),
          ),
        ],
      )));
  }

  void _showEditBottomSheet(
      BuildContext context, String docId, Map<String, dynamic> fields) {
    final _formKey = GlobalKey<FormState>();
    final Map<String, TextEditingController> _controllers = {};
    final List<String> validIndicators = [
      'Yes',
      'No'
    ]; // Options for the dropdown

    // Initialize controllers based on the custom order
    for (var field in _fieldOrder) {
      _controllers[field] =
          TextEditingController(text: fields[field]?.toString());
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: _fieldOrder.map((field) {
                        if (field == 'Address valid indicator') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: DropdownButtonFormField<String>(
                              value: _controllers[field]?.text,
                              decoration: InputDecoration(
                                  labelText: field.replaceAll('_', ' ')),
                              items: validIndicators.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _controllers[field]?.text = newValue;
                                }
                              },
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextFormField(
                              controller: _controllers[field],
                              decoration: InputDecoration(
                                  labelText: field.replaceAll('_', ' ')),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter a value'
                                      : null,
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final updatedData = _controllers.map(
                            (key, controller) =>
                                MapEntry(key, controller.text));
                        await FirebaseFirestore.instance
                            .collection('AddressDetails')
                            .doc(docId)
                            .update(updatedData);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save Changes'),
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
      BuildContext context, String docId, Map<String, dynamic> fields) {
    print('Updating document with ID: $docId');

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _fieldOrder.map((field) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                field.replaceAll('_', ' '),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(fields[field]?.toString() ?? ''),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
