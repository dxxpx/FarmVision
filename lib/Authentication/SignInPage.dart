import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Screens/HomePage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController usernameController =
      TextEditingController(text: "Deepika");
  final TextEditingController emailController =
      TextEditingController(text: "deepika@gmail.com");
  final TextEditingController passwordController =
      TextEditingController(text: "123456");

  Future<void> _signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navigate to the category screen after successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const homePage()),
      );
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(10),
            color: Colors.purple.shade100,
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                        labelText: "Enter UserName: ",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                        filled: true,
                        fillColor: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: "Enter your Email : ",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                        filled: true,
                        fillColor: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Enter your Password : ",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                        filled: true,
                        fillColor: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: _signIn,
                          child: const Text('Login',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => adminHomePage()));
                          },
                          child: const Text('Admin Login',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => registerScreen()));
                          },
                          child: const Text('Register')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
