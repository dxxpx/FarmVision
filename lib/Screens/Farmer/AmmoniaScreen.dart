import 'package:flutter/material.dart';

class ammoniaScreen extends StatefulWidget {
  const ammoniaScreen({super.key});

  @override
  State<ammoniaScreen> createState() => _ammoniaScreenState();
}

class _ammoniaScreenState extends State<ammoniaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ammonia Levels"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade100),
                      child: Column(
                        children: [
                          Text(
                            "Chicken Farm 1 \n Area: ABC",
                            textAlign: TextAlign.center,
                          ),
                          Text("30",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade100),
                      child: Column(
                        children: [
                          Text(
                            "Chicken Farm 2 \n Area: ABC",
                            textAlign: TextAlign.center,
                          ),
                          Text("40",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade100),
                      child: Column(
                        children: [
                          Text(
                            "Dairy Farm 1 \n Area: North",
                            textAlign: TextAlign.center,
                          ),
                          Text("30",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade100),
                      child: Column(
                        children: [
                          Text(
                            "Dairy Farm 2 \n Area: ABC",
                            textAlign: TextAlign.center,
                          ),
                          Text("40",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
