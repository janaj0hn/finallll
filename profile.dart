import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  static const String id = "profile-page";
  final String role;

  Profile({required this.role});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<DocumentSnapshot> adminDocs = [];
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  final int limit = 10;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('admin')
        .orderBy('email')
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      adminDocs.addAll(snapshot.docs);
      lastDocument = snapshot.docs.last; // Update for next fetch
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> searchAdmins() async {
    setState(() {
      isLoading = true;
      adminDocs.clear(); // Clear previous results
    });

    Query query = FirebaseFirestore.instance
        .collection('admin')
        .where('email', isGreaterThanOrEqualTo: searchTerm)
        .where('email', isLessThanOrEqualTo: searchTerm + '\uf8ff');

    QuerySnapshot snapshot = await query.get();
    adminDocs = snapshot.docs; // Update list with search results

    setState(() {
      isLoading = false;
    });
  }

  Future<void> createAdmin(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user?.uid) // Use the new user's UID
          .set({
        'email': email,
        'role': 'Admin', // You can set additional fields as needed
      });

      // Directly update adminDocs and call setState
      adminDocs.add(await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user?.uid)
          .get());
      setState(() {});

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Admin created successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Card (showing role only, without email)
              ProfileCard(currentUser: currentUser, role: widget.role),

              SizedBox(height: 20),

              // Create Admin Button
              if (widget.role == 'Super Admin') ...[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xff29BA91)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Create Admin"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(labelText: 'Email'),
                              ),
                              TextField(
                                controller: passwordController,
                                decoration:
                                    InputDecoration(labelText: 'Password'),
                                obscureText: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                String email = emailController.text.trim();
                                String password =
                                    passwordController.text.trim();
                                if (email.isNotEmpty && password.isNotEmpty) {
                                  createAdmin(email, password);
                                  emailController.clear();
                                  passwordController.clear();
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Please fill in all fields")),
                                  );
                                }
                              },
                              child: Text("Create"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Create Admin",
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(labelText: 'Search by Email'),
                  onChanged: (value) {
                    searchTerm = value; // Update search term
                    if (value.isEmpty) {
                      fetchAdmins(); // Fetch all admins if the search term is empty
                    } else {
                      searchAdmins(); // Search for admins
                    }
                  },
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("All Admins",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: adminDocs.length,
                          itemBuilder: (context, index) {
                            final adminEmail = adminDocs[index]['email'];
                            final adminId = adminDocs[index].id;

                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(adminEmail,
                                        style: TextStyle(fontSize: 16)),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.red)),
                                          onPressed: () {
                                            // Disable admin dialog
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Disable Admin"),
                                                  content: Text(
                                                      "Are you sure you want to disable this admin?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        try {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'admin')
                                                              .doc(adminId)
                                                              .delete();
                                                          await fetchAdmins(); // Refresh the list
                                                          Navigator.pop(
                                                              context);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Admin disabled successfully")));
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Error: ${e.toString()}")));
                                                        }
                                                      },
                                                      child: Text("Yes"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text("No"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text("Disable",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.admin_panel_settings,
                                            color: Colors.blue),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchAdmins,
                  child: Text("Load More"),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "Only Super Admins can manage admin accounts.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final User? currentUser;
  final String role;

  ProfileCard({required this.currentUser, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Profile Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text(currentUser?.email ?? "No email"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Role"),
              subtitle: Text(role),
            ),
          ],
        ),
      ),
    );
  }
}
