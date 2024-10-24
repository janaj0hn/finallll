// import 'package:cms/Pages/homepage.dart';
// import 'package:cms/login_register/register.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LoginPage extends StatelessWidget {
//   static const String id = "login-page";
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   Future<void> login(BuildContext context) async {
//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Center(child: CircularProgressIndicator()),
//     );

//     try {
//       // Check for empty fields
//       if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Please enter both email and password")),
//         );
//         return; // Exit if validation fails
//       }

//       print("Attempting to log in with email: ${emailController.text}");
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       print("Login successful: ${userCredential.user?.uid}");
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('superAdmin')
//           .doc(userCredential.user?.uid)
//           .get();

//       print("User Document Exists: ${userDoc.exists}");
//       if (userDoc.exists) {
//         String role = userDoc['role'];
//         print("User Role: $role");

//         // Close the loading dialog before navigating
//         Navigator.pop(context);

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomePage(role: role),
//           ),
//         );
//       } else {
//         print("User document does not exist");

//         Navigator.pop(context); // Close loading dialog
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("User document does not exist")));
//       }
//     } catch (e) {
//       String errorMessage;
//       if (e is FirebaseAuthException) {
//         switch (e.code) {
//           case 'user-not-found':
//             errorMessage = "No user found for that email.";
//             break;
//           case 'wrong-password':
//             errorMessage = "Wrong password provided for that user.";
//             break;
//           default:
//             errorMessage = "Login failed: ${e.message}";
//         }
//       } else {
//         errorMessage = "An unexpected error occurred.";
//       }
//       Navigator.pop(context); // Close loading dialog
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(errorMessage)));
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
//                         "Login",
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
//                         onPressed: () => login(context),
//                         child: Text("Login"),
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                       ),
//                       SizedBox(height: 10),
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

import 'package:cms/Pages/homepage.dart';
import 'package:cms/login_register/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  static const String id = "login-page";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      return; // Exit if validation fails
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Check for user in 'superAdmin' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('superAdmin')
          .doc(userCredential.user?.uid)
          .get();

      String role = '';
      if (userDoc.exists) {
        role = userDoc['role'];
      } else {
        // If not found in 'superAdmin', check in 'admin' collection
        userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(userCredential.user?.uid)
            .get();

        if (userDoc.exists) {
          role = userDoc['role'];
        }
      }

      if (role.isNotEmpty) {
        // Save login state in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', role);

        // Close the loading dialog before navigating
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(role: role),
          ),
        );
      } else {
        // Handle user document not found in both collections
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User document does not exist in both collections")));
      }
    } catch (e) {
      // Handle errors
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")));
    }
  }

  Future<void> logout(BuildContext context) async {
    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('role');

    // Log out from Firebase
    await FirebaseAuth.instance.signOut();

    // Optionally navigate back to login page
    Navigator.pushReplacementNamed(context, LoginPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: 400,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => login(context),
                        child: Text("Login"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
