import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName = "";
  String? userEmail = "";

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  // Fetch user details from Firebase Authentication
  Future<void> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userName = user.displayName ??
            "Deepika"; // Use a fallback if displayName is null
        userEmail = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
        name: userName ?? "User", email: userEmail ?? "user@example.com");
  }
}

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;

  const ProfilePage({Key? key, required this.name, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Light green background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle Avatar for Profile Picture
              const CircleAvatar(
                radius: 60.0,
                backgroundColor: Colors.greenAccent,
                child: Icon(
                  CupertinoIcons.profile_circled,
                  size: 100,
                ),
              ),
              const SizedBox(height: 20),

              // Name Text
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),

              // Email Text
              Text(
                email,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.green[700], // Darker green for email
                ),
              ),
              const SizedBox(height: 40),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  // Edit Profile functionality
                },
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16.0),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Rounded button shape
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
