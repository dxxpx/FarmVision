import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DoctorRegister extends StatefulWidget {
  @override
  _DoctorRegisterState createState() => _DoctorRegisterState();
}

class _DoctorRegisterState extends State<DoctorRegister> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String specialty = '';
  bool isLoading = false;

  // Location variables
  Position? userPosition;
  String location = '';

  @override
  void initState() {
    super.initState();
  }

  // Function to get current location and save it to state variables
  Future<void> getCurrentLocationAndSave() async {
    print("Current Location loading...");
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Location services are disabled. Please enable them.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permissions are denied'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userPosition = position;
      location = '${position.latitude}, ${position.longitude}';
      print('Current Location: $location');
      setState(() {});
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
        ),
      );
    }
  }

  // Registration function
  void registerDoctor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await getCurrentLocationAndSave();

      if (userPosition == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to fetch location. Please try again.'),
          ),
        );
        return;
      }

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': name.trim(),
          'email': email.trim(),
          'specialty': specialty.trim(),
          'location': {
            'latitude': userPosition!.latitude,
            'longitude': userPosition!.longitude,
          },
          'timestamp': FieldValue.serverTimestamp(),
        });
      } on FirebaseAuthException catch (e) {
        String errorMessage = '';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else {
          errorMessage = 'Registration failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Doctor Registration'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            // Add the image at the top
                            Image.asset(
                              'assets/images/img.png',
                              height: 150, // Adjust height as needed
                            ),
                            SizedBox(height: 20), // Add space after image
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (val) => name = val,
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter your name' : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) => email = val,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Enter your email';
                                }
                                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(val)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              onChanged: (val) => password = val,
                              validator: (val) => val!.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Specialty',
                                prefixIcon: Icon(Icons.medical_services),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (val) => specialty = val,
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter your specialty' : null,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: getCurrentLocationAndSave,
                              icon: Icon(Icons.my_location),
                              label: Text('Get Location'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            SizedBox(height: 10),
                            userPosition != null
                                ? Text(
                                    'Location: (${userPosition!.latitude.toStringAsFixed(4)}, ${userPosition!.longitude.toStringAsFixed(4)})',
                                    style: TextStyle(fontSize: 14),
                                  )
                                : Text(
                                    'Location not set. Click the button above to fetch your current location.',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: registerDoctor,
                              child: Text('Register'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ));
  }
}
