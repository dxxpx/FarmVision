import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../tools/Uicomponents.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CameraPage> {
  File? _selectedImage;
  String diseaseName = '';
  String diseasePrecautions = '';
  bool detecting = false;
  bool precautionLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      File image = File(pickedFile.path);
      print('Image file : $image \n');
      // String prompt =
      //     "Exactly give what the disease in the given image is, No extra words, only the disease name alone!!";
      // await sendImageWithPromptToGeminiAI(image, prompt);
    }
  }

  Future<void> sendImageWithPromptToGeminiAI(
      File? image, String userprompt) async {
    const baseurl = "http://192.168.177.89:3000/api/data";
    if (image == null) return;
    try {
      final url = Uri.parse(baseurl);
      final bytes = image.readAsBytesSync();
      final base64Image = base64Encode(bytes);
      final prompt =
          "Accurately Identify the plant disease(its tomato) in this photo? Give only the disease name, NO extra words, No descriptions.\n Its descriptions given by user is $userprompt";

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image": {
            "inlineData": {
              "data": base64Image,
              "mimeType": "image/jpeg",
            }
          },
          "prompt": prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['message'] ?? 'No Response Generated';

        setState(() {
          diseaseName = generatedText;
        });
      } else {
        setState(() {
          diseaseName = 'Unable to Generate Response';
        });
      }
    } catch (e) {
      print('Error on sending image to server : $e');
      diseaseName = 'Unable to send Image & prompt to server';
    }
  }

  detectDisease() async {
    if (_selectedImage == null) {
      // Show an error if no image is selected
      _showErrorSnackBar("Please select an image first.");
      return;
    }
    setState(() {
      detecting = true; // Start the detection process
    });

    try {
      String prompt =
          "Exactly give what the disease in the given image is, No extra words, only the disease name alone!!";
      await sendImageWithPromptToGeminiAI(_selectedImage!, prompt);

      setState(() {
        detecting = false; // Stop the detection process
      });

      if (diseaseName.isNotEmpty) {
        _showSuccessDialog("Disease Detected", diseaseName);
      } else {
        _showErrorSnackBar("Failed to detect the disease.");
      }
    } catch (e) {
      setState(() {
        detecting = false; // Stop the detection process in case of error
      });
      _showErrorSnackBar("Error detecting disease: $e");
    }
  }

  showPrecautions() {}

  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessDialog(String title, String content) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: title,
      desc: content,
      btnOkText: 'Got it',
      btnOkColor: themeColor,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.23,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    // Top right corner
                    bottomLeft: Radius.circular(50.0), // Bottom right corner
                  ),
                  color: themeColor,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    // Top right corner
                    bottomLeft: Radius.circular(50.0), // Bottom right corner
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      // Shadow color with some transparency
                      spreadRadius: 1,
                      // Extend the shadow to all sides equally
                      blurRadius: 5,
                      // Soften the shadow
                      offset: const Offset(2, 2), // Position of the shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OPEN GALLERY',
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.image,
                            color: textColor,
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('START CAMERA',
                              style: TextStyle(color: textColor)),
                          const SizedBox(width: 10),
                          Icon(Icons.camera_alt, color: textColor)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _selectedImage == null
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Image.asset('assets/images/uploadpic.png'),
                )
              : Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
          if (_selectedImage != null)
            detecting
                ? SpinKitWave(
                    color: themeColor,
                    size: 30,
                  )
                : Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        // Set some horizontal and vertical padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                        ),
                      ),
                      onPressed: () {
                        detectDisease();
                      },
                      child: const Text(
                        'DETECT',
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                          fontSize: 16, // Set the font size
                          fontWeight:
                              FontWeight.bold, // Set the font weight to bold
                        ),
                      ),
                    ),
                  ),
          if (diseaseName != '')
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultTextStyle(
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                        child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            repeatForever: false,
                            displayFullTextOnTap: true,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                diseaseName.trim(),
                              ),
                            ]),
                      )
                    ],
                  ),
                ),
                precautionLoading
                    ? const SpinKitWave(
                        color: Colors.blue,
                        size: 30,
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          showPrecautions();
                        },
                        child: Text(
                          'PRECAUTION',
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ),
              ],
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
