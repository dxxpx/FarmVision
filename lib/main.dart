import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Center(
          child: Container(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
