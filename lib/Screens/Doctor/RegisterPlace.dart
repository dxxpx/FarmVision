import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Services/ChooseLocationMapScreen.dart';

class ServiceDetailsForm extends StatefulWidget {
  @override
  _ServiceDetailsFormState createState() => _ServiceDetailsFormState();
}

class _ServiceDetailsFormState extends State<ServiceDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController additionalController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  late GoogleMapController mapController;
  LatLng? _pickedLocation;

  String? serviceType;

  bool isHospital() => serviceType == 'Hospital';

  Future<void> _chooseLocation(BuildContext context) async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (selectedLocation != null) {
      setState(() {
        _pickedLocation = selectedLocation;
        locationController.text =
            'Lat: ${selectedLocation.latitude}, Long: ${selectedLocation.longitude}';
      });
    }
  }

  void saveDataToFirebase() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      print("Entered Savetofirebase");

      String documentPath = isHospital() ? 'Hospitals' : 'Pharmacy';
      print("Document path is found : $documentPath");

      await firestore
          .collection('Places')
          .doc(documentPath)
          .collection('Details')
          .doc(nameController.text.trim())
          .set({
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'contactNumber': phoneController.text.trim(),
        'location': locationController.text.trim(),
        if (isHospital()) 'speciality': specialityController.text.trim(),
        if (!isHospital()) 'additional': additionalController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Firestore add is crossed");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Details added to Firebase successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      clearAll();
      print("ShowDialog is crossed");
    } catch (error) {
      print("MOTHERFUCKING ERROR : $error");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to add details: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void clearAll() {
    nameController.clear();
    addressController.clear();
    phoneController.clear();
    specialityController.clear();
    addressController.clear();
    locationController.clear();
    additionalController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    specialityController.dispose();
    additionalController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hospital/Pharmacy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Service Type:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: serviceType,
                  items: ['Hospital', 'Pharmacy']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      serviceType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a service type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name of Hospital/Pharmacy',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an address' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a contact number' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Choose the Location' : null,
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                        onPressed: () => _chooseLocation(context),
                        child: Text("Choose"))
                  ],
                ),
                const SizedBox(height: 16),
                if (isHospital()) ...[
                  TextFormField(
                    controller: specialityController,
                    decoration: const InputDecoration(
                      labelText: 'Speciality',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter the hospital\'s speciality'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                if (!isHospital()) ...[
                  TextFormField(
                    controller: additionalController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Details',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter Any Additional Details'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveDataToFirebase();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
