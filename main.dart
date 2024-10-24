// import 'package:cms/Pages/address.dart';
// import 'package:cms/Pages/bhogam.dart';
// import 'package:cms/Pages/dashboard.dart';
// import 'package:cms/Pages/homepage.dart';
// import 'package:cms/Pages/login.dart';
// import 'package:cms/Pages/sishyas.dart';

// import 'package:cms/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: HomePage.id,
//       routes: {
//         Dashboard.id: (context) => Dashboard(),
//         AddAddress.id: (context) => AddAddress(),
//         SishyasScreen.id: (context) => SishyasScreen(),
//         Bhogam.id: (context) => Bhogam(),
//       },
//       home: LoginPage(),
//     );\

//   }
// }

// import 'package:cms/Pages/homepage.dart';
// import 'package:cms/login_register/login.dart';
// import 'package:cms/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   String role = prefs.getString('role') ?? ''; // Retrieve the user role

//   runApp(MyApp(isLoggedIn: isLoggedIn, role: role)); // Pass the role to MyApp
// }

// class MyApp extends StatelessWidget {
//   final bool isLoggedIn;
//   final String role; // Add the role field

//   const MyApp(
//       {super.key,
//       required this.isLoggedIn,
//       required this.role}); // Update constructor

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       routes: {
//         HomePage.id: (context) => HomePage(role: role), // Pass role to HomePage
//         LoginPage.id: (context) => LoginPage(),

//         // Add other routes here
//       },
//       home: isLoggedIn
//           ? HomePage(role: role)
//           : LoginPage(), // Pass role to HomePage
//     );
//   }
// }

import 'package:cms/Pages/homepage.dart';
import 'package:cms/login_register/login.dart';
import 'package:cms/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String role = prefs.getString('role') ?? '';

  runApp(MyApp(isLoggedIn: isLoggedIn, role: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String role;

  const MyApp({super.key, required this.isLoggedIn, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.id: (context) => HomePage(role: role), // Pass role to HomePage
        LoginPage.id: (context) => LoginPage(),
        // Add other routes here
      },
      home: isLoggedIn ? HomePage(role: role) : LoginPage(),
    );
  }
}
