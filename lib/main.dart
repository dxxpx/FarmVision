import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/HomePage.dart';
import 'Services/LLM.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBKzrYcx1M85pejshl1OVqeC0MXKzZ8ykU",
        appId: "1:714769860123:android:8408dcc89f64bfc69f1abe",
        messagingSenderId: "714769860123",
        projectId: "farmvision-86826",
        storageBucket: "farmvision-86826.appspot.com"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Material App', home: homePage());
  }
}
