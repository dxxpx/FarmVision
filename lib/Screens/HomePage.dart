import 'package:farmvision/Screens/query_pages/query_page.dart';
import 'package:flutter/material.dart';
import '../tools/Uicomponents.dart';
import 'Farmer/AppointmentSection.dart';
import 'Farmer/CaptureScreen.dart';
import 'Farmer/ProfilePage.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});
  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return Capturescreen();
      case 1:
        return QueryListPage();
      case 2:
        return Appointmentsection();
      case 3:
        return ProfileScreen();
      default:
        return Capturescreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farm Vision"),
        backgroundColor: themeColor,
      ),
      body: _getSelectedScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Current selected index
        onTap: onTabTapped,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green, // Customize selected color
        unselectedItemColor: Colors.grey, // Customize unselected color
      ),
    );
  }
}
//Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Container(
//                   height: 150,
//                   width: 150,
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(color: Colors.green.shade100),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ChatPage()));
//                       },
//                       child: Text("LLM")),
//                 ),
//                 SizedBox(width: 10),
//                 Container(
//                   height: 150,
//                   width: 150,
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(color: Colors.green.shade100),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => QueryListPage()));
//                       },
//                       child: Text(
//                         "Community Page",
//                         textAlign: TextAlign.center,
//                       )),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 150,
//                   width: 150,
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(color: Colors.green.shade100),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ammoniaScreen()));
//                       },
//                       child: Text(
//                         "Ammonia Levels",
//                         textAlign: TextAlign.center,
//                       )),
//                 ),
//                 Container(
//                   height: 150,
//                   width: 150,
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(color: Colors.green.shade100),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ServiceDetailsForm()));
//                       },
//                       child: Text(
//                         "Register Place",
//                         textAlign: TextAlign.center,
//                       )),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
