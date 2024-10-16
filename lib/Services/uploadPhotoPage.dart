import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../Screens/Farmer/DiseaseDetailPage.dart';
import '../tools/Uicomponents.dart';

class CameraPage extends StatefulWidget {
  bool iscattle;
  CameraPage({super.key, required this.iscattle});

  @override
  State<CameraPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CameraPage> {
  File? _selectedImage;
  String diseaseName = '';
  String diseasePrecautions = '';
  bool detecting = false;
  bool precautionLoading = false;
  late bool isitcattle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeIsCattle();
  }

  List<dynamic> symptoms = [];
  List<dynamic> precautions = [];
  List<dynamic> treatments = [];
  List<dynamic> causes = [];
  List<dynamic> medicines = [];
  List<dynamic> pesticides = [];
  List<dynamic> vaccinations = [];

  void initializeIsCattle() {
    isitcattle = widget.iscattle;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      File image = File(pickedFile.path);
      print('Image file : $image \n');
    }
  }

  Future<void> sendImageWithPromptToGeminiAI(
      File? image, String userprompt) async {
    const baseurl = "${baseUrl}api/data";
    if (image == null) return;
    try {
      final url = Uri.parse(baseurl);
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['prompt'] = userprompt;
      print("Request Field is : ${request.fields}");
      print("Request File is : ${request.files}");
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      final data = jsonDecode(responseData.body);
      print(data);

      if (response.statusCode == 200) {
        setState(() {
          diseaseName = data['name'];
          symptoms = [data['symptoms']];
          precautions = [data['precautions']];
          treatments = [data['treatments']];
          causes = [data['causes']];
          medicines = [data['medicines']];
          pesticides:
          isitcattle ? [] : [data['pesticides']];
        });
        print(responseData.body);
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
      _showErrorSnackBar("Please select an image first.");
      return;
    }
    setState(() {
      detecting = true;
    });

    try {
      String prompt = isitcattle
          ? "GIVE THE NAME, 5 SYMPTOMS, 5 PRECAUTIONS, BEST TREATMENTS, 5 REASONS OF CAUSE, MEDICINE OF THE ANIMAL DISEASE, AVAILABLE VACCINES FOR THIS ANIMAL DISEASE IN THIS IMAGE IN JSON FORMAT. NO EXTRA WORDS. ONLY THE JSON ALONE, NO HEADINGS, NO EXPLANATIONS NEEDED. Let field names be - name, symptoms, precautions, treatments, causes, medicines."
          : "GIVE THE NAME, 5 SYMPTOMS, 5 PRECAUTIONS, BEST TREATMENTS, 5 REASONS OF CAUSE, MEDICINE/PESTICIDE OF THE PLANT/CROP DISEASE IN THIS IMAGE IN JSON FORMAT. NO EXTRA WORDS. ONLY THE JSON ALONE, NO HEADINGS , NO EXPLANATIONS NEEDED\nLet Field names be - name, symptoms, precautions, treatments, causes, medicines, pesticides.";
      await sendImageWithPromptToGeminiAI(_selectedImage!, prompt);

      setState(() {
        detecting = false;
      });

      if (diseaseName.isNotEmpty) {
        _showSuccessDialog("Disease Detected", diseaseName);
      } else {
        _showErrorSnackBar("Failed to detect the disease.");
      }
    } catch (e) {
      setState(() {
        detecting = false;
      });
      _showErrorSnackBar("Error detecting disease: $e");
    }
  }

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
      btnOkColor: isitcattle ? cattleColor : themeColor,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isitcattle ? "Capture Your Cattle" : "Capture Your Crop",
          style: appTstyle,
        ),
        backgroundColor: isitcattle ? cattleColor : themeColor,
      ),
      body: Column(
        children: <Widget>[
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
                  color: isitcattle ? cattleColor : themeColor,
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
                        backgroundColor: isitcattle ? cattleColor : themeColor,
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
                        backgroundColor: isitcattle ? cattleColor : themeColor,
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
                  child: isitcattle
                      ? Image.asset('assets/images/capturecattle.png')
                      : Image.asset('assets/images/uploadpic.png'),
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
                    color: isitcattle ? cattleColor : themeColor,
                    size: 30,
                  )
                : Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isitcattle ? cattleColor : themeColor,
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
          if (diseaseName.isNotEmpty)
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
                        child: Text(
                          'Detected disease is ${diseaseName.trim()}',
                          softWrap: true,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                          backgroundColor:
                              isitcattle ? cattleColor : themeColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Diseasedetailpage(
                                        diseaseName: diseaseName,
                                        symptoms: symptoms,
                                        precautions: precautions,
                                        treatments: treatments,
                                        causes: causes,
                                        medicines: medicines,
                                        pesticides:
                                            isitcattle ? [] : pesticides,
                                      )));
                        },
                        child: Text(
                          'DETAILS',
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
