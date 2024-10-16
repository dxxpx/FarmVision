import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  AppointmentPage({required this.doctorId, required this.doctorName});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _makeAppointment() async {
    if (selectedDate != null && selectedTime != null) {
      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      String formattedDate =
          DateFormat('yyyy-MM-dd – kk:mm').format(appointmentDateTime);

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('appointments')
          .add({
        'patientName': 'John Doe', // Replace with authenticated user name
        'time': formattedDate,
        'timestamp': Timestamp.fromDate(appointmentDateTime),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment made successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select date and time')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment with ${widget.doctorName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              onTap: _selectDate,
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(selectedTime == null
                  ? 'Select Time'
                  : selectedTime!.format(context)),
              onTap: _selectTime,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeAppointment,
              child: Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
