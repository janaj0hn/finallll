import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

class PhoneNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double screenWidth;

  PhoneNumberField({
    super.key,
    required this.screenWidth,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: screenWidth < 600 ? 90.0 : 160.0,
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
                  print(phone
                      .completeNumber); // This will log the complete number
                },
                onCountryChanged: (country) {
                  print('Country changed to: ' + country.name);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SishyasScreen extends StatefulWidget {
  final String? existingId;
  static const String id = "Sishyas-Screen";

  SishyasScreen({this.existingId});

  @override
  _SishyasScreenState createState() => _SishyasScreenState();
}

class _SishyasScreenState extends State<SishyasScreen> {
  String _dropdownValue1 = 'No';
  String _dropdownValue2 = 'No';

  final SishyaTypeCon = TextEditingController();
  final NameCon = TextEditingController();
  final careofpartCon = TextEditingController();
  final AliasExtraidentityCon = TextEditingController();
  final EmailCon = TextEditingController();
  final facebooklinkCon = TextEditingController();
  final SishyadataenteredbyCon = TextEditingController();
  final SamasreyanamController = TextEditingController();
  final dobController = TextEditingController(); // Dummy controller for DOB

  final mobileoneCon = TextEditingController();
  final mobiletwoCon = TextEditingController();
  final whatasappCon = TextEditingController();

  final SishyaIdCon = TextEditingController();

  DateTime? selectedDOB; // Date of Birth
  DateTime? selectedSamasreyanamDate; // Samasreyanam Date
  String? selectedId;
  String?
      isFamilyPointOfContact; // Dropdown value for Is Sishya the family point of contact
  String? sishyaValidIndicator; // Dropdown value for Sishya valid indicator
  String? setId; // Dropdown value for Set ID

  final uuid = Uuid();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List<String> addressIds = [];
  List<String> filteredAddressIds = [];

  @override
  void initState() {
    super.initState();
    selectedId = widget.existingId;
    searchController.addListener(_filterAddressIds);
    _fetchAddressIds();
    _loadSishyaId();
  }

  void _filterAddressIds() {
    setState(() {
      filteredAddressIds = addressIds
          .where((id) =>
              id.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchAddressIds() async {
    try {
      final snapshot = await _firestore.collection('AddressDetails').get();
      final ids =
          snapshot.docs.map((doc) => doc['Address_ID'] as String).toList();
      setState(() {
        addressIds = ids;
        filteredAddressIds = ids;
      });
    } catch (e) {
      // Handle errors here
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
                        _filterAddressIds();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: filteredAddressIds.map((id) {
                        return ListTile(
                          title: Text(id),
                          onTap: () {
                            Navigator.pop(context, id);
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

  // Generate a short random alphanumeric string
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

  void _submitForm() async {
    final String enteredMobileNumberOne = mobileoneCon.text.trim();
    final String enteredMobileNumberTwo = mobiletwoCon.text.trim();

    // Check if Name and SishyaType are provided
    if (NameCon.text.isEmpty || SishyaTypeCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both Name and Sishya Type.')),
      );
      return; // Exit early if validation fails
    }

    // Check if an address ID is selected
    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please select an ID to associate the details with.')),
      );
      return; // Exit early if no ID is selected
    }

    // Generate a new subId if not already set
    String subId;
    if (SishyaIdCon.text.isEmpty) {
      subId = await generateShortId();
      SishyaIdCon.text = subId;
      await _saveSishyaId(subId);
    } else {
      subId = SishyaIdCon.text;
    }

    String completePhoneNumber = mobiletwoCon.text;

    // Query Firestore for existing Sishya details
    final querySnapshot = await _firestore
        .collection('SishyaDetails')
        .where('Mobile 1', isEqualTo: enteredMobileNumberOne)
        .where('Mobile 2', isEqualTo: enteredMobileNumberTwo)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final document = querySnapshot.docs.first;
      await _firestore.collection('SishyaDetails').doc(document.id).update({
        'count': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This phone number is already entered.')),
      );

      // Optionally navigate to the EditAddress screen
    } else {
      try {
        await _firestore.collection('SishyaDetails').add({
          'Address_ID': selectedId!,
          'Shisya_ID': subId, // Use the generated or retrieved subId
          'Sishya Type': SishyaTypeCon.text,
          'Name': NameCon.text,
          'Care or of part': careofpartCon.text,
          'Alias or Extra identity': AliasExtraidentityCon.text,
          'Date of Birth': selectedDOB != null
              ? DateFormat('MM/dd/yyyy').format(selectedDOB!)
              : null,
          'Samasreyanam Date': selectedSamasreyanamDate != null
              ? DateFormat('MM/dd/yyyy').format(selectedSamasreyanamDate!)
              : null,
          'Mobile 1': mobileoneCon.text,
          'Mobile 2': completePhoneNumber,
          'WhatsApp': whatasappCon.text,
          'Facebook': facebooklinkCon.text,
          'Email': EmailCon.text,
          'Sishya data entered by': SishyadataenteredbyCon.text,
          'Is Sishya the family point of contact': _dropdownValue1,
          'Sishya valid indicator': _dropdownValue2,
        });

        // Update counts
        await _updateSubmissionCounts('sishyasCount');

        // Clear the controllers and reset the dropdown selections
        SishyaTypeCon.clear();
        NameCon.clear();
        selectedDOB = null; // Clear the selected DOB
        selectedSamasreyanamDate = null; // Clear the selected Samasreyanam Date
        isFamilyPointOfContact = null;
        sishyaValidIndicator = null;

        // Optionally navigate to another screen or update UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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

  void _selectDate(String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (dateType == 'Date of Birth') {
          selectedDOB = picked;
        } else if (dateType == 'Samasreyanam Date') {
          selectedSamasreyanamDate = picked;
        }
      });
    }
  }

  void _loadSishyaId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('sishya_id');
    if (savedId != null) {
      setState(() {
        SishyaIdCon.text = savedId;
      });
    }
  }

  // Save the Address ID to SharedPreferences
  Future<void> _saveSishyaId(String subId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sishya_id', subId);
  }

  // Clear the Address ID from SharedPreferences
  Future<void> _clearSishyaId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sishya_id');
    setState(() {
      SishyaIdCon.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Sishya',
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
              InputField(
                label: 'Sishya ID',
                content: 'Generated Address ID will appear here',
                controller: SishyaIdCon,
                readOnly: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)),
                onPressed: _clearSishyaId,
                child: Text(
                  'Clear Sishya ID',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: _showSearchableDropdown,
                child: AbsorbPointer(
                  child: InputField(
                    label: 'Address ID',
                    content: selectedId ?? 'Select Address ID',
                    controller: TextEditingController(
                        text: selectedId), // Dummy controller
                  ),
                ),
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Sishya Type',
                content: '',
                controller: SishyaTypeCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Name*',
                content: '',
                controller: NameCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Care/of part',
                content: '',
                controller: careofpartCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Alias / Extra identity',
                content: '',
                controller: AliasExtraidentityCon,
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () => _selectDate('Date of Birth'),
                child: AbsorbPointer(
                  child: InputField(
                    label: 'Date of Birth',
                    content: selectedDOB != null
                        ? DateFormat.yMd().format(selectedDOB!)
                        : 'Choose a date',
                    controller: dobController, // Dummy controller
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () => _selectDate('Samasreyanam Date'),
                child: AbsorbPointer(
                  child: InputField(
                    label: 'Samasreyanam Date',
                    content: selectedSamasreyanamDate != null
                        ? DateFormat.yMd().format(selectedSamasreyanamDate!)
                        : 'Choose a date',
                    controller: SamasreyanamController, // Dummy controller
                  ),
                ),
              ),
              SizedBox(height: 25),
              PhoneNumberField(
                screenWidth: screenWidth,
                label: 'Mobile 1',
                controller: mobileoneCon,
              ),
              SizedBox(height: 25),
              PhoneNumberField(
                screenWidth: screenWidth,
                label: 'Mobile 2',
                controller: mobiletwoCon,
              ),
              SizedBox(height: 25),
              PhoneNumberField(
                screenWidth: screenWidth,
                label: 'WhatsApp',
                controller: whatasappCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Email',
                content: '',
                controller: EmailCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Facebook link',
                content: '',
                controller: facebooklinkCon,
              ),
              SizedBox(height: 25),
              DropdownField(
                label: 'Sishya valid indicator?*',
                items: ['Yes', 'No'],
                selectedValue: _dropdownValue1,
                onChanged: (value) {
                  setState(() {
                    _dropdownValue1 = value!;
                  });
                },
              ),
              SizedBox(height: 25),
              DropdownField(
                label: 'Is Sishya the family point of contact*',
                items: ['Yes', 'No'],
                selectedValue: _dropdownValue2,
                onChanged: (value) {
                  setState(() {
                    _dropdownValue2 = value!;
                  });
                },
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Sishya data entered by*',
                content: '',
                controller: SishyadataenteredbyCon,
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
