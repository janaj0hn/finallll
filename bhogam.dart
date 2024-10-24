import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

// class DropdownField extends StatefulWidget {
//   final String label;
//   final List<String> items;
//   final String?
//       selectedValue; // Make this nullable to handle cases where no value is selected
//   final ValueChanged<String?>
//       onChanged; // Callback to notify parent of value changes

//   DropdownField({
//     required this.label,
//     required this.items,
//     this.selectedValue,
//     required this.onChanged,
//   });

//   @override
//   _DropdownFieldState createState() => _DropdownFieldState();
// }

// class _DropdownFieldState extends State<DropdownField> {
//   late String? _selectedValue;

//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.selectedValue;
//   }

//   @override
//   void didUpdateWidget(DropdownField oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.selectedValue != oldWidget.selectedValue) {
//       setState(() {
//         _selectedValue = widget.selectedValue;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return LayoutBuilder(
//       builder: (BuildContext context, BoxConstraints constraints) {
//         final dropdownWidth = screenWidth < 600 ? screenWidth * 0.7 : 400.0;

//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(
//               width: screenWidth < 600 ? 80.0 : 150.0,
//               child: Text(
//                 widget.label,
//                 textAlign: TextAlign.left,
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//             SizedBox(width: 10.0),
//             Container(
//               width: 240,
//               height: 35,
//               color: Colors.orange[50],
//               child: DropdownButton<String>(
//                 value: _selectedValue,
//                 items: widget.items.map((String item) {
//                   return DropdownMenuItem<String>(
//                     value: item,
//                     child: Text(item),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedValue = newValue;
//                     widget.onChanged(newValue); // Notify parent of change
//                   });
//                 },
//                 underline: SizedBox(),
//                 isExpanded: true,
//                 hint: Padding(
//                   padding: EdgeInsets.all(10.0),
//                   child: Text(
//                     _selectedValue ?? 'Select ${widget.label}',
//                     style: TextStyle(fontSize: 14.0),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class InputField extends StatelessWidget {
//   final String label;
//   final String content;
//   final TextEditingController controller;
//   final bool readOnly;

//   final FormFieldValidator<String>? validator;

//   InputField(
//       {required this.label,
//       required this.content,
//       required this.controller,
//       this.readOnly = false,
//       this.validator});

//   @override
//   Widget build(BuildContext context) {
//     // Get screen width
//     final screenWidth = MediaQuery.of(context).size.width;

//     return LayoutBuilder(
//       builder: (BuildContext context, BoxConstraints constraints) {
//         // For mobile view, adapt the width; for desktop, use fixed width
//         final inputWidth = screenWidth < 600 ? screenWidth * 0.7 : 00.0;

//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(
//               width: screenWidth < 600
//                   ? 80.0
//                   : 150.0, // Adjust label width based on screen size
//               child: Text(
//                 "$label",
//                 textAlign: TextAlign.left,
//                 style: TextStyle(color: Colors.black, fontSize: 14),
//               ),
//             ),
//             SizedBox(width: 10.0),
//             Container(
//               width: 240,
//               height: 35,
//               color: Colors.orange[50],
//               child: TextFormField(
//                 readOnly: readOnly,
//                 validator: validator,
//                 controller: controller,
//                 style: TextStyle(fontSize: 13.0),
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.all(10.0),
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.orange),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   errorStyle: const TextStyle(
//                     fontSize: 0.1,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.orange),
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   hintText: "$content",
//                   fillColor: Colors.orange[50],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

class PhoneNumberField extends StatelessWidget {
  final String label;

  final TextEditingController controller;
  PhoneNumberField(
      {super.key,
      required this.screenWidth,
      required this.label,
      required this.controller});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: screenWidth < 600
              ? 90.0
              : 160.0, // Adjust label width based on screen size
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        SizedBox(
          width: 240,
          child: IntlPhoneField(
            controller: controller,
            initialCountryCode: 'IN',
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff29BA91)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff29BA91)),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white,
            ),
            languageCode: "en",
            onChanged: (phone) {
              // This is where you can get the complete number
              final completeNumber = phone.completeNumber;
              print('Complete Number: $completeNumber');
            },
            onCountryChanged: (country) {
              print('Country changed to: ' + country.name);
            },
          ),
        ),
      ],
    );
  }
}

// class Bhogam extends StatefulWidget {
//   final String? existingId;
//   static const String id = 'bhogam-screen';

//   Bhogam({this.existingId});

//   @override
//   _BhogamState createState() => _BhogamState();
// }

// class _BhogamState extends State<Bhogam> {
//   final BhogamIdCon = TextEditingController();
//   final BhogamstartdateCon = TextEditingController();
//   final EnglishCalenderDateCon = TextEditingController();
//   final bhogamnameCon = TextEditingController();
//   final bhogamMonthCon = TextEditingController();
//   final BhogamthithinakshatramCon = TextEditingController();
//   final bhogamAmountCon = TextEditingController();
//   final EmailCon = TextEditingController();
//   final phoneCon = TextEditingController();
//   final BhogamdataenteredbyCon = TextEditingController();

//   String? selectedId;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   DateTime? selectEnglishCalenderDate;
//   DateTime? selectBhogamstartdate;

//   void _selectDate(String dateType) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (picked != null) {
//       setState(() {
//         if (dateType == 'EnglishCalenderDate') {
//           selectEnglishCalenderDate = picked;
//           EnglishCalenderDateCon.text = _formatDate(picked);
//         } else if (dateType == 'Bhogamstartdate') {
//           selectBhogamstartdate = picked;
//           BhogamstartdateCon.text = _formatDate(picked);
//         }
//       });
//     }
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('M/dd/yyyy').format(date);
//   }

//   String _dropdownValue4 = 'No';
//   String _dropdownValue5 = 'No';
//   String _dropdownValue6 = 'Birthday';

//   TextEditingController searchController = TextEditingController();
//   List<String> SishyaIds = [];
//   List<String> filteredSishyaIds = [];

//   @override
//   void initState() {
//     super.initState();
//     selectedId = widget.existingId;
//     searchController.addListener(_filterSishyaIds);
//     _fetchSishyaIds();
//     _loadBhogamId();
//   }

//   void _filterSishyaIds() {
//     setState(() {
//       filteredSishyaIds = SishyaIds.where((subId) =>
//               subId.toLowerCase().contains(searchController.text.toLowerCase()))
//           .toList();
//     });
//   }

//   Future<void> _fetchSishyaIds() async {
//     try {
//       final snapshot =
//           await _firestore.collection('secondFormSubmissions').get();
//       final ids = snapshot.docs.map((doc) => doc['subId'] as String).toList();
//       setState(() {
//         SishyaIds = ids;
//         filteredSishyaIds = ids;
//       });
//     } catch (e) {
//       print('Error fetching address IDs: $e');
//     }
//   }

//   void _showSearchableDropdown() async {
//     final selected = await showModalBottomSheet<String>(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       labelText: 'Search Address ID',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _filterSishyaIds();
//                       });
//                     },
//                   ),
//                   SizedBox(height: 10),
//                   Expanded(
//                     child: ListView(
//                       children: filteredSishyaIds.map((subId) {
//                         return ListTile(
//                           title: Text(subId),
//                           onTap: () {
//                             Navigator.pop(context, subId);
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );

//     if (selected != null) {
//       setState(() {
//         selectedId = selected;
//       });
//     }
//   }

//   String generateShortId(int length) {
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     Random rand = Random();
//     return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
//         .join();
//   }

//   void _submitForm() async {
//     if (BhogamIdCon.text.isEmpty) {
//       final String BsubId = generateShortId(10);
//       BhogamIdCon.text = BsubId; // Assign the generated ID to the controller
//       await _saveBhogamId(BsubId);
//     }
//     if (selectedId != null) {
//       String BhogamIdConText = BhogamIdCon.text;

//       try {
//         await _firestore.collection('thirdFormSubmissions').add({
//           'subId': selectedId,
//           'BsubId': BhogamIdConText,
//           'Bhogam purpose': _dropdownValue6,
//           'bhogamName': bhogamnameCon.text,
//           'bhogamMonth': bhogamMonthCon.text,
//           'Bhogamstartdate': selectBhogamstartdate != null
//               ? _formatDate(selectBhogamstartdate!)
//               : null,
//           'EnglishCalenderDate': selectEnglishCalenderDate != null
//               ? _formatDate(selectEnglishCalenderDate!)
//               : null,
//           'bhogamAmount': bhogamAmountCon.text,
//           'Bhogamthithinakshatram': BhogamthithinakshatramCon.text,
//           'email': EmailCon.text,
//           'phone': phoneCon.text,
//           'AreyouaSishya': _dropdownValue5,
//           'bhogamvalidindicator': _dropdownValue4,
//           'Bhogamdataenteredby': BhogamdataenteredbyCon.text
//         });
//         await _updateSubmissionCounts('bhogamCount');

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Form submitted successfully!')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select an ID to associate the details with.'),
//         ),
//       );
//     }
//   }

//   Future<void> _updateSubmissionCounts(String countType) async {
//     try {
//       final docRef = _firestore.collection('submissionCounts').doc('counts');
//       final doc = await docRef.get();

//       if (doc.exists) {
//         final data = doc.data() as Map<String, dynamic>;
//         int currentCount = data[countType] ?? 0;

//         await docRef.update({
//           countType: currentCount + 1,
//         });
//       } else {
//         await docRef.set({
//           countType: 1,
//         });
//       }
//     } catch (e) {
//       print('Error updating submission counts: $e');
//     }
//   }

//   void _loadBhogamId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedId = prefs.getString('bhogam_id');
//     if (savedId != null) {
//       setState(() {
//         BhogamIdCon.text = savedId;
//       });
//     }
//   }

//   Future<void> _saveBhogamId(String BsubId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('bhogam_id', BsubId);
//   }

//   Future<void> _clearBhogamId() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('bhogam_id');
//     setState(() {
//       BhogamIdCon.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Bhogam')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding:
//               EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 40),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: _showSearchableDropdown,
//                 child: AbsorbPointer(
//                   child: InputField(
//                     label: 'Sishya ID',
//                     content: selectedId ?? 'Select Sishya ID',
//                     controller: TextEditingController(
//                         text: selectedId), // Dummy controller
//                   ),
//                 ),
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 label: 'Bhogam ID',
//                 content: 'Generated Bhogam ID will appear here',
//                 readOnly: true,
//                 controller: BhogamIdCon,
//               ),
//               SizedBox(height: 25),
//               ElevatedButton(
//                 onPressed: _clearBhogamId,
//                 child: Text('Clear Address ID'),
//               ),
//               SizedBox(height: 25),
//               DropdownField(
//                 label: 'Bhogam purpose*',
//                 items: [
//                   'Birthday',
//                   'Marriage Anniversary',
//                   'Thithi',
//                 ],
//                 selectedValue: _dropdownValue6,
//                 onChanged: (value) {
//                   setState(() {
//                     _dropdownValue6 = value!;
//                   });
//                 },
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 label: 'Bhogam for Name*',
//                 content: '',
//                 controller: bhogamnameCon,
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 label: 'Bhogam month*',
//                 content: '',
//                 controller: bhogamMonthCon,
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 label: 'Bhogam thithi / nakshatram*',
//                 content: '',
//                 controller: BhogamthithinakshatramCon,
//               ),
//               SizedBox(height: 25),
//               GestureDetector(
//                 onTap: () => _selectDate('EnglishCalenderDate'),
//                 child: AbsorbPointer(
//                   child: InputField(
//                     controller: EnglishCalenderDateCon,
//                     label: 'English Calender Date',
//                     content: selectEnglishCalenderDate != null
//                         ? _formatDate(selectEnglishCalenderDate!)
//                         : 'Choose a date',
//                   ),
//                 ),
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 label: 'Amount',
//                 content: '₹ ₹ ₹',
//                 controller: bhogamAmountCon,
//               ),
//               SizedBox(height: 25),
//               GestureDetector(
//                 onTap: () => _selectDate('Bhogamstartdate'),
//                 child: AbsorbPointer(
//                   child: InputField(
//                     controller: BhogamstartdateCon,
//                     label: 'Bhogam start date',
//                     content: selectBhogamstartdate != null
//                         ? _formatDate(selectBhogamstartdate!)
//                         : 'Choose a date',
//                   ),
//                 ),
//               ),
//               SizedBox(height: 25),
//               DropdownField(
//                 label: 'Bhogam valid indicator?*',
//                 items: ['Yes', 'No'],
//                 selectedValue: _dropdownValue4,
//                 onChanged: (value) {
//                   setState(() {
//                     _dropdownValue4 = value!;
//                   });
//                 },
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 label: 'Bhogam data entered by',
//                 content: '',
//                 controller: BhogamdataenteredbyCon,
//               ),
//               SizedBox(height: 25),
//               DropdownField(
//                 label: 'Are you a Sishya?*',
//                 items: ['Yes', 'No'],
//                 selectedValue: _dropdownValue5,
//                 onChanged: (value) {
//                   setState(() {
//                     _dropdownValue5 = value!;
//                   });
//                 },
//               ),
//               SizedBox(height: 25),
//               PhoneNumberField(
//                 controller: phoneCon,
//                 screenWidth: screenWidth,
//                 label: 'Phone',
//               ),
//               SizedBox(height: 25),
//               InputField(
//                 controller: EmailCon,
//                 label: 'Email',
//                 content: '',
//               ),
//               SizedBox(height: 25),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Define other custom widgets like InputField, DropdownField, PhoneNumberField here

//       //  Padding(
//       //   padding: EdgeInsets.all(16.0),
//       //   child: Column(
//       //     children: [
//       //       StreamBuilder<QuerySnapshot>(
//       //         stream:
//       //             _firestore.collection('secondFormSubmissions').snapshots(),
//       //         builder: (context, snapshot) {
//       //           if (!snapshot.hasData) {
//       //             return CircularProgressIndicator();
//       //           }

//       //           final items = snapshot.data!.docs.map((doc) {
//       //             return DropdownMenuItem<String>(
//       //               value: doc['subId'],
//       //               child: Text(doc['subId']),
//       //             );
//       //           }).toList();

//       //           return DropdownButton<String>(
//       //             value: selectedSubId,
//       //             hint: Text('Select Sub ID'),
//       //             items: items,
//       //             onChanged: (value) {
//       //               setState(() {
//       //                 selectedSubId = value;
//       //               });
//       //             },
//       //           );
//       //         },
//       //       ),

class DropdownField extends StatefulWidget {
  final String label;
  final List<String> items;
  final String?
      selectedValue; // Make this nullable to handle cases where no value is selected
  final ValueChanged<String?>
      onChanged; // Callback to notify parent of value changes

  DropdownField({
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(DropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final dropdownWidth = screenWidth < 600 ? screenWidth * 0.7 : 400.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: screenWidth < 600 ? 80.0 : 150.0,
              child: Text(
                widget.label,
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 10.0),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xff29BA91),
                  ),
                  borderRadius: BorderRadius.circular(6)),
              width: 240,
              height: 35,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: DropdownButton<String>(
                  value: _selectedValue,
                  items: widget.items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue;
                      widget.onChanged(newValue); // Notify parent of change
                    });
                  },
                  underline: SizedBox(),
                  isExpanded: true,
                  hint: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      _selectedValue ?? 'Select ${widget.label}',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final String content;
  final TextEditingController controller;
  final bool readOnly;

  final FormFieldValidator<String>? validator;

  InputField(
      {required this.label,
      required this.content,
      required this.controller,
      this.readOnly = false,
      this.validator});

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // For mobile view, adapt the width; for desktop, use fixed width
        final inputWidth = screenWidth < 600 ? screenWidth * 0.7 : 00.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: screenWidth < 600
                  ? 80.0
                  : 150.0, // Adjust label width based on screen size
              child: Text(
                "$label",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            SizedBox(width: 10.0),
            Container(
              width: 240,
              height: 35,
              color: Colors.white,
              child: TextFormField(
                readOnly: readOnly,
                validator: validator,
                controller: controller,
                style: TextStyle(fontSize: 13.0),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff29BA91)),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 0.1,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff29BA91)),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "$content",
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Bhogam extends StatefulWidget {
  final String? existingId;
  static const String id = 'bhogam-screen';

  Bhogam({this.existingId});

  @override
  _BhogamState createState() => _BhogamState();
}

class _BhogamState extends State<Bhogam> {
  final BaddressCon = TextEditingController();

  final BhogamIdCon = TextEditingController();
  final BhogamstartdateCon = TextEditingController();
  final EnglishCalenderDateCon = TextEditingController();
  final bhogamnameCon = TextEditingController();
  final bhogamMonthCon = TextEditingController();
  final BhogamthithinakshatramCon = TextEditingController();
  final bhogamAmountCon = TextEditingController();
  final EmailCon = TextEditingController();
  final phoneCon = TextEditingController();
  final countryCodeCon = TextEditingController();
  final BhogamdataenteredbyCon = TextEditingController();

  String? selectedId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? selectEnglishCalenderDate;
  DateTime? selectBhogamstartdate;

  void _selectDate(String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (dateType == 'English Calender Date') {
          selectEnglishCalenderDate = picked;
          EnglishCalenderDateCon.text = _formatDate(picked);
        } else if (dateType == 'Bhogam start date') {
          selectBhogamstartdate = picked;
          BhogamstartdateCon.text = _formatDate(picked);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('M/dd/yyyy').format(date);
  }

  String _dropdownValue4 = 'No';
  String _dropdownValue5 = 'No';
  String _dropdownValue6 = 'Birthday';

  TextEditingController searchController = TextEditingController();
  List<String> SishyaIds = [];
  List<String> filteredSishyaIds = [];

  @override
  void initState() {
    super.initState();
    selectedId = widget.existingId;
    searchController.addListener(_filterSishyaIds);
    _fetchSishyaIds();
    _loadBhogamId();
  }

  void _filterSishyaIds() {
    setState(() {
      filteredSishyaIds = SishyaIds.where((subId) =>
              subId.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchSishyaIds() async {
    try {
      final snapshot = await _firestore.collection('SishyaDetails').get();
      final ids =
          snapshot.docs.map((doc) => doc['Shisya_ID'] as String).toList();
      setState(() {
        SishyaIds = ids;
        filteredSishyaIds = ids;
      });
    } catch (e) {
      print('Error fetching address IDs: $e');
    }
  }

  void _showSearchableDropdown() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Address ID',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filterSishyaIds();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: filteredSishyaIds.map((subId) {
                        return ListTile(
                          title: Text(subId),
                          onTap: () {
                            Navigator.pop(context, subId);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedId = selected;
      });
    }
  }

  Future<String> generateShortId() async {
    const String prefix = 'BH';
    final int idLength =
        6; // Length of the numeric part (total length - prefix length)

    // Reference to the Firestore document that holds the last used number
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('customIdsBhogam')
        .doc('lastIdBH');

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

  Future<void> _updateSubmissionCounts(String countType) async {
    try {
      final docRef = _firestore.collection('submissionCounts').doc('counts');
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        int currentCount = data[countType] ?? 0;

        await docRef.update({
          countType: currentCount + 1,
        });
      } else {
        await docRef.set({
          countType: 1,
        });
      }
    } catch (e) {
      print('Error updating submission counts: $e');
    }
  }

  void _loadBhogamId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('bhogam_id');
    if (savedId != null) {
      setState(() {
        BhogamIdCon.text = savedId;
      });
    }
  }

  Future<void> _saveBhogamId(String BsubId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bhogam_id', BsubId);
  }

  Future<void> _clearBhogamId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bhogam_id');
    setState(() {
      BhogamIdCon.clear();
    });
  }

  Future<void> _submitForm() async {
    // Validate that bhogamName and bhogamAmount are provided
    if (bhogamnameCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the Bhogam Name.')),
      );
      return; // Exit early if bhogamName is empty
    }

    if (bhogamAmountCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the Bhogam Amount.')),
      );
      return; // Exit early if bhogamAmount is empty
    }

    // Ensure a Sishya ID is selected
    // if (selectedId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content:
    //             Text('Please select an ID to associate the details with.')),
    //   );
    //   return; // Exit early if no ID is selected
    // }

    // Generate a new Bhogam ID if not already set
    if (BhogamIdCon.text.isEmpty || bhogamnameCon.text.isEmpty) {
      final String BsubId = await generateShortId();
      BhogamIdCon.text = BsubId; // Assign the generated ID to the controller
      await _saveBhogamId(BsubId);
    }

    String BhogamIdConText = BhogamIdCon.text;
    final completeNumber = countryCodeCon.text + phoneCon.text;

    try {
      await _firestore.collection('BhogamDetails').add({
        'Baddress': BaddressCon.text,
        'Shisya_ID': selectedId,
        'Bhogam_ID': BhogamIdConText,
        'Bhogam purpose': _dropdownValue6,
        'Bhogam for Name': bhogamnameCon.text,
        'Bhogam month': bhogamMonthCon.text,
        'Bhogam start date': selectBhogamstartdate != null
            ? Timestamp.fromDate(selectBhogamstartdate!)
            : null,
        'English Calender Date': selectEnglishCalenderDate != null
            ? Timestamp.fromDate(selectEnglishCalenderDate!)
            : null,
        'Bhogam Amount': bhogamAmountCon.text,
        'Bhogam thithi or nakshatram': BhogamthithinakshatramCon.text,
        'Email': EmailCon.text,
        'Phone': completeNumber,
        'Are you a Sishya': _dropdownValue5,
        'Bhogam valid indicator': _dropdownValue4,
        'Bhogam data entered by': BhogamdataenteredbyCon.text,
      });
      await _updateSubmissionCounts('bhogamCount');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Bhogam',
        ),
        backgroundColor: Colors.grey[150],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showSearchableDropdown,
                child: AbsorbPointer(
                  child: InputField(
                    label: 'Sishya ID',
                    content: selectedId ?? 'Select Sishya ID',
                    controller: TextEditingController(
                        text: selectedId), // Dummy controller
                  ),
                ),
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Bhogam ID',
                content: 'Generated Bhogam ID will appear here',
                readOnly: true,
                controller: BhogamIdCon,
              ),
              SizedBox(height: 25),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)),
                onPressed: _clearBhogamId,
                child: Text(
                  'Clear Bhogam ID',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 25),
              DropdownField(
                label: 'Bhogam purpose*',
                items: [
                  'Birthday',
                  'Marriage Anniversary',
                  'Thithi',
                ],
                selectedValue: _dropdownValue6,
                onChanged: (value) {
                  setState(() {
                    _dropdownValue6 = value!;
                  });
                },
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Bhogam for Name*',
                content: '',
                controller: bhogamnameCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Bhogam month*',
                content: '',
                controller: bhogamMonthCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Bhogam thithi / nakshatram*',
                content: '',
                controller: BhogamthithinakshatramCon,
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () => _selectDate('English Calender Date'),
                child: AbsorbPointer(
                  child: InputField(
                    controller: EnglishCalenderDateCon,
                    label: 'English Calender Date',
                    content: selectEnglishCalenderDate != null
                        ? _formatDate(selectEnglishCalenderDate!)
                        : 'Choose a date',
                  ),
                ),
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Amount',
                content: '₹ ₹ ₹',
                controller: bhogamAmountCon,
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () => _selectDate('Bhogam start date'),
                child: AbsorbPointer(
                  child: InputField(
                    controller: BhogamstartdateCon,
                    label: 'Bhogam start date',
                    content: selectBhogamstartdate != null
                        ? _formatDate(selectBhogamstartdate!)
                        : 'Choose a date',
                  ),
                ),
              ),
              SizedBox(height: 25),
              DropdownField(
                label: 'Bhogam valid indicator?*',
                items: ['Yes', 'No'],
                selectedValue: _dropdownValue4,
                onChanged: (value) {
                  setState(() {
                    _dropdownValue4 = value!;
                  });
                },
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Bhogam data entered by',
                content: '',
                controller: BhogamdataenteredbyCon,
              ),
              SizedBox(height: 25),
              DropdownField(
                label: 'Are you a Sishya?*',
                items: ['Yes', 'No'],
                selectedValue: _dropdownValue5,
                onChanged: (value) {
                  setState(() {
                    _dropdownValue5 = value!;
                  });
                },
              ),
              SizedBox(height: 25),
              if (_dropdownValue5 == 'No') ...[
                InputField(
                  label: 'Address*',
                  content: '',
                  controller: BaddressCon,
                ),
              ],
              SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth < 600
                        ? 90.0
                        : 160.0, // Adjust label width based on screen size
                    child: Text(
                      'Phone',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  Container(
                    width: 60, // Adjust width as needed
                    child: TextField(
                      maxLength: 4,
                      controller: countryCodeCon,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff29BA91)),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        errorStyle: const TextStyle(
                          fontSize: 0.1,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff29BA91)),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "Code",
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 10), // Add some space between the fields
                  Container(
                    width: 170,
                    child: Expanded(
                      child: TextField(
                        maxLength: 15,
                        controller: phoneCon,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff29BA91)),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 0.1,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff29BA91)),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: "Phone Number",
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              InputField(
                controller: EmailCon,
                label: 'Email',
                content: '',
              ),
              SizedBox(height: 35),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xff29BA91))),
                onPressed: _submitForm,
                child: Text(
                  'SUBMIT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
