import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'docters_chat_page.dart'; // This is your ChatPage file
import 'package:firebase_auth/firebase_auth.dart';

class PatientsListPage extends StatefulWidget {
  @override
  _PatientsListPageState createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients List'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(currentUser!.uid)
            .collection('patients')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching patients.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No patients found.'));
          }

          final patients = snapshot.data!.docs;

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patientDoc = patients[index];
              final patientId = patientDoc.id; // Patient UID

              // Assuming each patient's document contains at least a name and optionally a lastMessage
              final patientData = patientDoc.data() as Map<String, dynamic>;
              final patientName = patientData['name'] ?? 'Unknown Patient';
              final lastMessage = patientData['lastMessage'] ?? 'No message';

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person, color: Colors.white),
                  backgroundColor: Colors.teal,
                ),
                title: Text(patientName),
                subtitle: Text('Last message: $lastMessage'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        doctorId: currentUser!.uid,
                        doctorName: currentUser!.displayName ?? 'Doctor',
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
