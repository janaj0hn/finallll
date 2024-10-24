import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/Pages/editSishya.dart';
import 'package:cms/Pages/editaddress.dart';
import 'package:cms/Pages/editbhogam.dart';
import 'package:cms/login_register/login.dart';

import 'package:cms/Pages/search.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const String id = "dash-board";

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int sishyasCount = 0;
  int addressCount = 0;
  int bhogamCount = 0;

  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchSubmissionCounts();
  }

  Future<void> _fetchSubmissionCounts() async {
    try {
      final doc =
          await _firestore.collection('submissionCounts').doc('counts').get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          sishyasCount = data['sishyasCount'] ?? 0;
          addressCount = data['addressCount'] ?? 0;
          bhogamCount = data['bhogamCount'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching submission counts: $e');
    }
  }

  Widget dashboardAnalytis(
      {required String title,
      required int value,
      required VoidCallback onViewDetailsPressed,
      required Color color,
      required Color Colorv

      // Callback for viewing details
      // Callback for another action
      }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade500, blurRadius: 2),
          ],
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: color),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              color: Colorv,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 22,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

//search old
  // Future<void> _searchData(String query) async {
  //   if (query.isEmpty) {
  //     setState(() {
  //       searchResults = [];
  //     });
  //     return;
  //   }

  //   QuerySnapshot snapshot = await _firestore
  //       .collection('secondFormSubmissions')
  //       .where('Name', isEqualTo: query)
  //       .get();

  //   List<Map<String, dynamic>> results =
  //       snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

  //   setState(() {
  //     searchResults = results;
  //   });

  //   if (results.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('No results found')),
  //     );
  //   } else {
  //     // Optionally navigate to a results screen if needed
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => SearchResultsScreen(
  //           results: results,
  //         ),
  //       ),
  //     );
  //   }
  // }

  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xffFF4C2F)),
              ),
              onPressed: () async {
                // Log out the user
                await FirebaseAuth.instance.signOut();

                // Clear the login status in SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                // Navigate back to the LoginPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 40),
            child: Column(
              children: [
                Container(
                  width: 970,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search here',
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade100)),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              10), // Spacing between the text field and button
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Color(0xff286BDC),
                            ),
                            shape: WidgetStatePropertyAll(
                                BeveledRectangleBorder())),
                        onPressed: () {
                          String searchTerm = _searchController.text;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryPage(searchTerm: searchTerm),
                            ),
                          );
                        },
                        child: Text(
                          'Search',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   width: 600,
                //   child: TextField(
                //       controller: _searchController,
                //       decoration: InputDecoration(
                //           hintText: 'Search for Sishya',
                //           suffixIcon: IconButton(
                //             icon: Icon(Icons.search),
                //             onPressed: () {},
                //           ))),
                // ),
                SizedBox(
                  height: 40,
                ),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    dashboardAnalytis(
                      Colorv: Color(0xffFF4C2F),
                      color: Color(0xffFF4C2F),
                      title: 'Sishyas Master ',
                      value: sishyasCount,
                      onViewDetailsPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryPage(
                                    searchTerm: '',
                                  )), // Replace with your screen
                        );
                      },
                    ),
                    dashboardAnalytis(
                      Colorv: Color(0xff286BDC),
                      color: Color(0xff286BDC),
                      title: 'Address Master ',
                      value: addressCount,
                      onViewDetailsPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddressDataTable()), // Replace with your screen
                        );
                      },
                    ),
                    dashboardAnalytis(
                      Colorv: Color(0xff29BA91),
                      color: Color(0xff29BA91),
                      title: 'Bhogam Master ',
                      value: bhogamCount,
                      onViewDetailsPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DataTableScreen()), // Replace with your screen
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          .collection('secondFormSubmissions')
          .where('Shisya_ID', isEqualTo: subId)
          .where('Address_ID', isEqualTo: id)
          .get();

      if (documentSnapshot.docs.isNotEmpty) {
        // If the document exists, update it
        final documentId = documentSnapshot.docs.first.id;
        await _firestore
            .collection('secondFormSubmissions')
            .doc(documentId)
            .update({
          'SishyaType': sishyaType,
          'Name': name,
          'DOB': dob,
          'Samasreyanam Date': samasreyanamDate,
          'Mobileone': mobile,
          'Mobiletwo': mobile2,
          'Whatsapp': whatsapp,
          'Email': email,
          'Facebook link': facebookLink,
          'careofpart': careOfPart,
          'AliasExtra identity': aliasExtra,
          'Sishya data entered by': Sishyadataenteredby,
          "Sishyavalidindicator": Sishyavalidindicator,
          "IsSishyathefamilypointofcontact": IsSishyathefamilypointofcontact,
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




























//-----sishya history---

// class HistoryPage extends StatefulWidget {
//   @override
//   _HistoryPageState createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? _selectedDistrict;

//   // Fetch available districts
//   Future<List<String>> _fetchDistricts() async {
//     final snapshot = await _firestore.collection('firstFormSubmissions').get();
//     final districts = <String>{};

//     for (var doc in snapshot.docs) {
//       if (doc.data().containsKey('district')) {
//         districts.add(doc['district']);
//       }
//     }

//     return districts.toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('History')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FutureBuilder<List<String>>(
//               future: _fetchDistricts(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 final districts = snapshot.data!;

//                 return DropdownButton<String>(
//                   hint: Text('Select District'),
//                   value: _selectedDistrict,
//                   items: districts.map((district) {
//                     return DropdownMenuItem<String>(
//                       value: district,
//                       child: Text(district),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedDistrict = value;
//                     });
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('firstFormSubmissions')
//                     .where('district',
//                         isEqualTo: _selectedDistrict) // Filter by district
//                     .snapshots(),
//                 builder: (context, firstFormSnapshot) {
//                   if (!firstFormSnapshot.hasData) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   final firstFormEntries = firstFormSnapshot.data!.docs;

//                   return StreamBuilder<QuerySnapshot>(
//                     stream: _firestore
//                         .collection('secondFormSubmissions')
//                         .where('district',
//                             isEqualTo: _selectedDistrict) // Filter by district
//                         .snapshots(),
//                     builder: (context, secondFormSnapshot) {
//                       if (!secondFormSnapshot.hasData) {
//                         return Center(child: CircularProgressIndicator());
//                       }

//                       final secondFormEntries = secondFormSnapshot.data!.docs;

//                       // Group submissions by ID
//                       Map<String, List<Map<String, String>>>
//                           groupedSubmissions = {};

//                       for (var entry in firstFormEntries) {
//                         String id = entry['id'];
//                         groupedSubmissions[id] =
//                             []; // Initialize with an empty list for sub-entries
//                       }

//                       for (var entry in secondFormEntries) {
//                         String id = entry['id'];
//                         if (groupedSubmissions.containsKey(id)) {
//                           groupedSubmissions[id]!.add({
//                             'subId': entry['subId'],
//                             'Sishya Type': entry['Sishya Type'],
//                             'Name': entry['Name'],
//                           });
//                         }
//                       }

//                       return ListView(
//                         children: groupedSubmissions.entries.map((group) {
//                           String id = group.key;
//                           List<Map<String, String>> details = group.value;

//                           return Card(
//                             margin: EdgeInsets.symmetric(vertical: 8.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('ID: $id',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   SizedBox(height: 10),
//                                   SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: DataTable(
//                                       columnSpacing: 12,
//                                       columns: [
//                                         DataColumn(label: Text('Sub-ID')),
//                                         DataColumn(label: Text('Sishya Type')),
//                                         DataColumn(label: Text('Name')),
//                                       ],
//                                       rows: details.map((detail) {
//                                         return DataRow(
//                                           cells: [
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth:
//                                                       100, // Adjust as needed
//                                                 ),
//                                                 child: Text(
//                                                   detail['subId'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth:
//                                                       200, // Adjust as needed
//                                                 ),
//                                                 child: Text(
//                                                   detail['Sishya Type'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth:
//                                                       150, // Adjust as needed
//                                                 ),
//                                                 child: Text(
//                                                   detail['Name'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       }).toList(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//-----address history have filter by district---
// class HistoryPage extends StatefulWidget {
//   @override
//   _HistoryPageState createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? _selectedDistrict;

//   Future<List<String>> _fetchDistricts() async {
//     final snapshot = await _firestore.collection('firstFormSubmissions').get();
//     final districts = <String>{};

//     for (var doc in snapshot.docs) {
//       if (doc.data().containsKey('district')) {
//         districts.add(doc['district']);
//       }
//     }

//     return districts.toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('History')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FutureBuilder<List<String>>(
//               future: _fetchDistricts(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 final districts = snapshot.data!;

//                 return DropdownButton<String>(
//                   hint: Text('Select District'),
//                   value: _selectedDistrict,
//                   items: districts.map((district) {
//                     return DropdownMenuItem<String>(
//                       value: district,
//                       child: Text(district),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedDistrict = value;
//                     });
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('firstFormSubmissions')
//                     .where('district', isEqualTo: _selectedDistrict)
//                     .snapshots(),
//                 builder: (context, firstFormSnapshot) {
//                   if (!firstFormSnapshot.hasData) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   final firstFormEntries = firstFormSnapshot.data!.docs;

//                   return StreamBuilder<QuerySnapshot>(
//                     stream: _firestore
//                         .collection('secondFormSubmissions')
//                         .snapshots(),
//                     builder: (context, secondFormSnapshot) {
//                       if (!secondFormSnapshot.hasData) {
//                         return Center(child: CircularProgressIndicator());
//                       }

//                       final secondFormEntries = secondFormSnapshot.data!.docs;

//                       Map<String, List<Map<String, dynamic>>>
//                           groupedSubmissions = {};

//                       for (var entry in firstFormEntries) {
//                         String id = entry['id'];
//                         groupedSubmissions[id] = [];
//                       }

//                       for (var entry in secondFormEntries) {
//                         String id = entry['id']; // Use custom ID
//                         if (groupedSubmissions.containsKey(id)) {
//                           groupedSubmissions[id]!
//                               .add(entry.data() as Map<String, dynamic>);
//                         }
//                       }

//                       return ListView(
//                         children: groupedSubmissions.entries.map((group) {
//                           String id = group.key;
//                           List<Map<String, dynamic>> details = group.value;

//                           return Card(
//                             margin: EdgeInsets.symmetric(vertical: 8.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Address ID: $id',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold)),
//                                   SizedBox(height: 10),
//                                   SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: DataTable(
//                                       columnSpacing: 12,
//                                       columns: [
//                                         DataColumn(label: Text('Sishya ID')),
//                                         DataColumn(label: Text('SishyaType')),
//                                         DataColumn(label: Text('Name')),
//                                         DataColumn(label: Text('DOB')),
//                                         DataColumn(
//                                             label: Text('Samasreyanam Date')),
//                                         DataColumn(label: Text('Mobile')),
//                                         DataColumn(label: Text('Actions')),
//                                       ],
//                                       rows: details.map((detail) {
//                                         String subId = detail['subId'] ?? '';
//                                         return DataRow(
//                                           cells: [
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: 100,
//                                                 ),
//                                                 child: Text(
//                                                   subId,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: 200,
//                                                 ),
//                                                 child: Text(
//                                                   detail['SishyaType'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: 150,
//                                                 ),
//                                                 child: Text(
//                                                   detail['Name'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: 150,
//                                                 ),
//                                                 child: Text(
//                                                   detail['DOB'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: 150,
//                                                 ),
//                                                 child: Text(
//                                                   detail['Samasreyanam Date'] ??
//                                                       '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               ConstrainedBox(
//                                                 constraints: BoxConstraints(
//                                                   maxWidth: 150,
//                                                 ),
//                                                 child: Text(
//                                                   detail['Mobileone'] ?? '',
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             DataCell(
//                                               IconButton(
//                                                 icon: Icon(Icons.edit),
//                                                 onPressed: () {
//                                                   // Pass the correct ID and subId
//                                                   _showEditBottomSheet(
//                                                     id,
//                                                     subId,
//                                                     detail,
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       }).toList(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEditBottomSheet(
//       String id, String subId, Map<String, dynamic> detail) {
//     final nameController = TextEditingController(text: detail['Name']);
//     final sishyaTypeController =
//         TextEditingController(text: detail['SishyaType']);
//     final dobController = TextEditingController(text: detail['DOB']);
//     final samasreyanamDateController =
//         TextEditingController(text: detail['Samasreyanam Date']);
//     final mobileController = TextEditingController(text: detail['Mobileone']);

//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//               ),
//               TextField(
//                 controller: sishyaTypeController,
//                 decoration: InputDecoration(labelText: 'Sishya Type'),
//               ),
//               TextField(
//                 controller: dobController,
//                 decoration: InputDecoration(labelText: 'DOB'),
//               ),
//               TextField(
//                 controller: samasreyanamDateController,
//                 decoration: InputDecoration(labelText: 'Samasreyanam Date'),
//               ),
//               TextField(
//                 controller: mobileController,
//                 decoration: InputDecoration(labelText: 'Mobile'),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       _updateEntry(
//                         id,
//                         subId,
//                         nameController.text,
//                         sishyaTypeController.text,
//                         dobController.text,
//                         samasreyanamDateController.text,
//                         mobileController.text,
//                       );
//                       Navigator.pop(context);
//                     },
//                     child: Text('Save'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text('Cancel'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _updateEntry(
//     String id,
//     String subId,
//     String name,
//     String sishyaType,
//     String dob,
//     String samasreyanamDate,
//     String mobile,
//   ) {
//     // Find the document based on the custom ID and subId
//     _firestore
//         .collection('secondFormSubmissions')
//         .where('id', isEqualTo: id)
//         .where('subId', isEqualTo: subId)
//         .get()
//         .then((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         DocumentReference documentRef = snapshot.docs.first.reference;
//         return documentRef.update({
//           'Name': name,
//           'SishyaType': sishyaType,
//           'DOB': dob,
//           'Samasreyanam Date': samasreyanamDate,
//           'Mobileone': mobile,
//         }).then((_) {
//           print("Document successfully updated!");
//         }).catchError((error) {
//           print("Failed to update document: $error");
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to update document: $error")),
//           );
//         });
//       } else {
//         print("Document not found!");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Document not found!")),
//         );
//       }
//     }).catchError((error) {
//       print("Failed to retrieve document: $error");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to retrieve document: $error")),
//       );
//     });
//   }
// }

