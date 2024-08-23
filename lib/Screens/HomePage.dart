import 'package:farmvision/Screens/query_pages/query_page.dart';
import 'package:flutter/material.dart';

import '../Services/LLM.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatPage()));
              },
              child: Text("LLM")),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QueryListPage()));
              },
              child: Text("Community Page"))
        ],
      ),
    );
  }
}
