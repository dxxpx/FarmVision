import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

import '../../tools/Uicomponents.dart';

class Diseasedetailpage extends StatefulWidget {
  final String diseaseName;
  List<dynamic> symptoms = [];
  List<dynamic> precautions = [];
  List<dynamic> treatments = [];
  List<dynamic> causes = [];
  List<dynamic> medicines = [];
  List<dynamic> pesticides = [];

  Diseasedetailpage({
    super.key,
    required this.diseaseName,
    required this.symptoms,
    required this.precautions,
    required this.treatments,
    required this.causes,
    required this.medicines,
    required this.pesticides,
  });

  @override
  State<Diseasedetailpage> createState() => _DiseasedetailpageState();
}

class _DiseasedetailpageState extends State<Diseasedetailpage> {
  FlutterTts _flutterTts = new FlutterTts();

  Future<void> checkSupportedLanguages() async {
    var supportedLanguages = await _flutterTts.getLanguages;
    print("Supported Languages: $supportedLanguages");
  }

  final GoogleTranslator _translator = GoogleTranslator();
  String _selectedLanguage = 'English';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSupportedLanguages();
  }

  // List of languages for the dropdown
  final Map<String, String> _languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Malayalam': 'ml',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diseaseName, style: appTstyle),
        backgroundColor: themeColor,
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
            items:
                _languages.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyDetailsCard(
                  title: 'Symptoms',
                  details: widget.symptoms,
                  lang: _languages[_selectedLanguage] ?? 'en'),
              MyDetailsCard(
                  title: 'Precautions',
                  details: widget.precautions,
                  lang: _languages[_selectedLanguage] ?? 'en'),
              MyDetailsCard(
                  title: 'Treatments',
                  details: widget.treatments,
                  lang: _languages[_selectedLanguage] ?? 'en'),
              MyDetailsCard(
                  title: 'Causes',
                  details: widget.causes,
                  lang: _languages[_selectedLanguage] ?? 'en'),
              MyDetailsCard(
                  title: 'Medicines',
                  details: widget.medicines,
                  lang: _languages[_selectedLanguage] ?? 'en'),
              MyDetailsCard(
                  title: 'Pesticides',
                  details: widget.pesticides,
                  lang: _languages[_selectedLanguage] ?? 'en'),
            ],
          ),
        ),
      ),
    );
  }

  // Widget buildDetailsCard(String title, List<dynamic> details, String lang) {
  //   Future<List<String>> _translateDetails(
  //       List<dynamic> details, String langCode) async {
  //     final GoogleTranslator translator = GoogleTranslator();
  //     List<String> translatedDetails = [];
  //
  //     for (var detail in details) {
  //       List<String> lines = detail.split(',');
  //       for (var line in lines) {
  //         var translation =
  //             await translator.translate(line.trim(), to: langCode);
  //         translatedDetails.add(translation.text);
  //       }
  //     }
  //     return translatedDetails;
  //   }
  //
  //   return Card(
  //       margin: const EdgeInsets.symmetric(vertical: 8.0),
  //       child: Stack(children: [
  //         Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.all(12.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               ...details.expand((detail) {
  //                 return detail
  //                     .split(',')
  //                     .map((line) => Text('• ${line.trim()}'))
  //                     .toList();
  //               }).toList(),
  //             ],
  //           ),
  //         ),
  //         Positioned(
  //           top: 0,
  //           right: 0,
  //           child: IconButton(
  //             icon: const Icon(Icons.volume_up),
  //             onPressed: () {
  //               _speak(details.toString());
  //               print("Volume icon pressed");
  //             },
  //             padding:
  //                 const EdgeInsets.all(8.0), // Adjust icon padding if needed
  //             constraints:
  //                 const BoxConstraints(), // Remove extra space around icon
  //           ),
  //         ),
  //       ]));
  // }
}

class MyDetailsCard extends StatelessWidget {
  final FlutterTts _flutterTts = FlutterTts();
  final String title;
  final List<dynamic> details;
  final String lang;
  List<String> translatedDetails = [];
  MyDetailsCard(
      {required this.title, required this.details, required this.lang});

  Future<List<String>> _translateDetails(
      List<dynamic> details, String langCode) async {
    final GoogleTranslator translator = GoogleTranslator();

    print(langCode);

    for (var detail in details) {
      // Split and translate each detail
      List<String> lines = detail.split(',');
      for (var line in lines) {
        var translation = await translator.translate(line.trim(), to: langCode);
        translatedDetails.add(translation.text);
      }
    }
    return translatedDetails;
  }

  Future<void> _speak(String detail, String lang) async {
    print("Inside -speak");
    final Map<String, String> langCodeMap = {
      'en': 'en-US',
      'hi': 'hi-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'ml': 'ml-IN',
    };
    print(langCodeMap[lang]);
    if (detail.isNotEmpty) {
      print("Inside IF ");
      try {
        print("Inside TRY ");
        await _flutterTts.setLanguage(langCodeMap[lang] ?? 'en-US');
        await _flutterTts.setPitch(1.0);
        await _flutterTts.speak(detail);
      } catch (e) {
        print("SPEAK MOTHERFUCKER : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<String>>(
                  future: _translateDetails(
                      details, lang), // Fetch translated details
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while translating
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Handle any errors
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Not Applicable.'); // Handle no data
                    }

                    // Display translated details
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: snapshot.data!
                          .map((line) => Text('• $line'))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () async {
                await _speak(translatedDetails.toString(), lang);
                print("Volume icon pressed");
              },
              padding: const EdgeInsets.all(8.0),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
