// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class RegisterPage extends StatefulWidget {
//   static const String id = "create-page";

//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;

//   Future<void> register(BuildContext context) async {
//     setState(() {
//       isLoading = true; // Set loading to true
//     });

//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       String userId = userCredential.user?.uid ?? '';

//       await FirebaseFirestore.instance
//           .collection('superAdmin')
//           .doc(userId)
//           .set({
//         'email': emailController.text,
//         'role': 'Super Admin', // Default role
//       });

//       Navigator.pop(context); // Navigate back after registration
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Registration failed: ${e.toString()}")),
//       );
//     } finally {
//       setState(() {
//         isLoading = false; // Set loading to false
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blueAccent, Colors.lightBlueAccent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Container(
//               width: 400,
//               child: Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         "Register",
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       TextField(
//                         controller: emailController,
//                         decoration: InputDecoration(labelText: 'Email'),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         controller: passwordController,
//                         decoration: InputDecoration(labelText: 'Password'),
//                         obscureText: true,
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: isLoading ? null : () => register(context),
//                         child: isLoading
//                             ? CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               )
//                             : Text("Register"),
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text("Already have an account? Login"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
