import 'package:farmvision/tools/Uicomponents.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'RegisterPlace.dart';
import 'list_patients.dart'; // Import the doctor's chat page

class DoctorHomePage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  DoctorHomePage({required this.doctorId, required this.doctorName});

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome Dr. ${widget.doctorName}'),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chat Widget
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                tileColor: Colors.teal.withOpacity(0.1),
                leading: Icon(Icons.chat, color: Colors.teal, size: 40),
                title: Text(
                  'Chat with Patients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('View all messages from your patients'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientsListPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              // Appointments Section
              Text(
                'Upcoming Appointments',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('doctors')
                      .doc(widget.doctorId)
                      .collection('appointments')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error fetching appointments'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final appointments = snapshot.data!.docs;

                    if (appointments.isEmpty) {
                      return Center(child: Text('No upcoming appointments.'));
                    }

                    return ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment =
                            appointments[index].data() as Map<String, dynamic>;
                        final patientName =
                            appointment['patientName'] ?? 'Unknown';
                        final appointmentTime =
                            appointment['time'] ?? 'No time set';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.video_call, color: Colors.teal),
                            title: Text('Appointment with $patientName'),
                            subtitle: Text('Time: $appointmentTime'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServiceDetailsForm()));
            },
            backgroundColor: themeColor,
            child: Icon(
              Icons.local_hospital_sharp,
              size: 35,
            )));
  }
}
