import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddress extends StatefulWidget {
  static const String id = 'address-screen';

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final addressline1Con = TextEditingController();
  final addressline2Con = TextEditingController();
  final addressline3Con = TextEditingController();
  final cityCon = TextEditingController();
  final TalukCon = TextEditingController();
  final DistrictCon = TextEditingController();
  final StateCon = TextEditingController();
  final CountryCon = TextEditingController();
  final PincodeCon = TextEditingController();
  final LandmarkCon = TextEditingController();
  final LandlinenumberCountryCon = TextEditingController();
  final LandlinenumberCon = TextEditingController();
  final AddressdataenteredCon = TextEditingController();
  final addressIdCon = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _dropdownValue = 'No';

  @override
  void initState() {
    super.initState();
    _loadAddressId();
  }

  // Generate a random 10-character alphanumeric string
  Future<String> generateShortId() async {
    const String prefix = 'AD';
    final int idLength =
        6; // Length of the numeric part (total length - prefix length)

    // Reference to the Firestore document that holds the last used number
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('customIds').doc('lastId');

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

  // Load the Address ID from SharedPreferences
  void _loadAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('address_id');
    if (savedId != null) {
      setState(() {
        addressIdCon.text = savedId;
      });
    }
  }

  // Save the Address ID to SharedPreferences
  Future<void> _saveAddressId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('address_id', id);
  }

  // Clear the Address ID from SharedPreferences
  Future<void> _clearAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('address_id');
    setState(() {
      addressIdCon.clear();
    });
  }

  void _checkAndSubmitForm() async {
    final String enteredAddress1 = addressline1Con.text.trim();
    final String enteredAddress2 = addressline2Con.text.trim();
    final String enteredAddress3 = addressline3Con.text.trim();

    // Check if the address fields are empty
    if (enteredAddress1.isEmpty &&
        enteredAddress2.isEmpty &&
        enteredAddress3.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least one address field.')),
      );
      return; // Exit the method early if no address is provided
    }

    // Check if the address ID field is empty
    if (addressIdCon.text.isEmpty) {
      final String id = await generateShortId(); // Call the async function
      addressIdCon.text = id; // Set the generated ID to the controller
      await _saveAddressId(id); // Save the address ID
    }

    // Query Firestore for existing addresses
    final querySnapshot = await _firestore
        .collection('AddressDetails')
        .where('Address Line 1', isEqualTo: enteredAddress1)
        .where('Address Line 2', isEqualTo: enteredAddress2)
        .where('Address Line 3',
            isEqualTo: enteredAddress3) // Fixed the field name
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final document = querySnapshot.docs.first;
      await _firestore.collection('AddressDetails').doc(document.id).update({
        'count': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This Address is already entered.')),
      );

      // Optionally navigate to the EditAddress screen here
    } else {
      await _firestore.collection('AddressDetails').add({
        'Address_ID': addressIdCon.text,
        'Address Line 1': enteredAddress1,
        'Address Line 2': enteredAddress2,
        'Address Line 3': enteredAddress3,
        'Taluk': TalukCon.text,
        'City or Town': cityCon.text,
        'District': DistrictCon.text,
        'State': StateCon.text,
        'Country': CountryCon.text,
        'Pincode or Zipcode': PincodeCon.text,
        'Landmark': LandmarkCon.text,
        'Landline number Country or STD code': LandlinenumberCountryCon.text,
        'Landline Number': LandlinenumberCon.text,
        'Address valid indicator': _dropdownValue,
        'Address data entered by': AddressdataenteredCon.text,
        'count': 1,
      });

      await _updateAddressCount();

      // Clear the address fields after submission
      addressline1Con.clear();
      addressline2Con.clear();
      addressline3Con.clear();
    }
  }

  Future<void> _updateAddressCount() async {
    try {
      final docRef = _firestore.collection('submissionCounts').doc('counts');
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        int currentCount = data['addressCount'] ?? 0;

        await docRef.update({
          'addressCount': currentCount + 1,
        });
      } else {
        await docRef.set({
          'addressCount': 1,
        });
      }
    } catch (e) {
      print('Error updating address count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Address'),
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
                label: 'Address ID',
                content: 'Generated Address ID will appear here',
                controller: addressIdCon,
                readOnly: true, // Make the Address ID field read-only
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)),
                onPressed: _clearAddressId,
                child: Text(
                  'Clear Address ID',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Address line 1*',
                content: '',
                controller: addressline1Con,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Address Line 2',
                content: '',
                controller: addressline2Con,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Address Line 3',
                content: '',
                controller: addressline3Con,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'City/Town*',
                content: '',
                controller: cityCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Taluk',
                content: '',
                controller: TalukCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'District',
                content: '',
                controller: DistrictCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'State*',
                content: '',
                controller: StateCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Country*',
                content: '',
                controller: CountryCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Pincode/Zipcode*',
                content: '',
                controller: PincodeCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Landmark',
                content: '',
                controller: LandmarkCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Landline number Country',
                content: '',
                controller: LandlinenumberCountryCon,
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Landline Number',
                content: '',
                controller: LandlinenumberCon,
              ),
              SizedBox(height: 25),
              DropdownField(
                label: 'Address valid indicator*',
                items: ['Yes', 'No'],
                selectedValue: _dropdownValue,
                onChanged: (value) {
                  setState(() {
                    _dropdownValue = value!;
                  });
                },
              ),
              SizedBox(height: 25),
              InputField(
                label: 'Address data entered by*',
                content: '',
                controller: AddressdataenteredCon,
              ),
              SizedBox(height: 35),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xff29BA91))),
                onPressed: _checkAndSubmitForm,
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

class InputField extends StatelessWidget {
  final String label;
  final String content;
  final TextEditingController controller;
  final bool readOnly;
  final FormFieldValidator<String>? validator;

  InputField({
    required this.label,
    required this.content,
    required this.controller,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final inputWidth = screenWidth < 600 ? screenWidth * 0.7 : 400.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: screenWidth < 600 ? 80.0 : 150.0,
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
                  fillColor: Color(0xff29BA91),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  DropdownField({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width < 600 ? 80.0 : 150.0,
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
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff29BA91)),
                borderRadius: BorderRadius.circular(5.0),
              ),
              hoverColor: Color(0xff29BA91),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
