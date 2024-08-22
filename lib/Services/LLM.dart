import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String recommendation = "";
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatUser _currentUser;
  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'Gemini',
    lastName: 'AI',
  );

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
  }

  void _initializeCurrentUser() {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _currentUser = ChatUser(
        id: firebaseUser.uid,
        firstName: firebaseUser.displayName ?? 'Anonymous',
        lastName: firebaseUser.email,
      );
    } else {
      _currentUser = ChatUser(
        id: '0',
        firstName: 'Guest',
      );
    }
  }

  void _sendRecommendationRequest({required int value}) {
    String sensorDataMessage = ''' ''';

    switch (value) {
      case 0:
        sensorDataMessage = '''
What kind of recommendations can be given to the user who is in a room with sensor data as below:
Temperature: 38°C
Humidity: 40%
Dust: 20
Gas levels: CO2 - 10%, O2 - 70%, LPG - 20%
Occupancy count: 40 out of 45
Lights: ON
Ambient Lights value: 70 out of 100
Soil moisture value (for indoor plants in the room): 50
Ammonia/Urea sensor in bathroom: 40

Give it as short & direct bulletin points.
''';
        break;
      case 1:
        sensorDataMessage = '''
what kind of health recommendations can be given to the user whose health metrics is as below:
Height : 160cm
Weight: 50kg
Age: 20yrs
Gender : Female
BMI: 20
Water Intake (per day in liters): 2L
Sleep Duration (average hours of sleep per night) - 7hrs
Sleep Quality (e.g., Good, Poor, Disturbed) - Poor

And the sensor data of the building that the person stays is given below:
Temperature: 38°C
Humidity: 40%
Dust: 20
Gas levels: CO2 - 10%, O2 - 70%, LPG - 20%
Occupancy count: 40 out of 45
Lights: ON
Ambient Lights value: 70 out of 100
Soil moisture value (for indoor plants in the room): 50
Ammonia/Urea sensor in bathroom: 40

Give them as short direct bulletin points on immediate concerns what the user should do in the room concerning their health
''';
    }
    ChatMessage sensorMessage = ChatMessage(
      user: _currentUser,
      createdAt: DateTime.now(),
      text: sensorDataMessage,
    );
    getAIResponse(sensorMessage);

    ChatMessage recommendationmessage = ChatMessage(
        user: _currentUser,
        createdAt: DateTime.now(),
        text: value == 0
            ? "Give some recommendations for my room"
            : "Give some recommendations for my health");

    setState(() {
      _messages.insert(0, recommendationmessage);
      _typingUsers.add(_gptChatUser);
    });
  }

  void sendPromptToNode(String Prompt) async {
    const baseurl = "http://192.168.238.89:3000/api/data";
    try {
      final url = Uri.parse(baseurl);
      final response = await http.post(url,
          body: jsonEncode({'prompt': Prompt}), //User sending to server
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body.toString().replaceAll("**", " ").trim());
        print(data['message']);
      }
    } catch (e) {
      print('ERROR : While sending to Node : $e');
    }
  }

  void _onSelected(BuildContext context, int item) {
    _sendRecommendationRequest(value: item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generative AI Chat'),
        actions: [
          // ElevatedButton(
          //     onPressed: _sendRecommendationRequest,
          //     child: Text('Recommendations')),
          PopupMenuButton<int>(
            color: Colors.white,
            onSelected: (item) => _onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                  value: 0, child: Text('Building Recommendation')),
              PopupMenuItem<int>(
                  value: 1, child: Text('Health Recommendation')),
            ],
          ),
        ],
      ),
      body: DashChat(
        currentUser: _currentUser,
        onSend: (ChatMessage message) {
          setState(() {
            _messages.insert(0, message);
            _typingUsers.add(_gptChatUser);
          });
          getAIResponse(message);
        },
        messages: _messages,
        typingUsers: _typingUsers,
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.blue,
          containerColor: Colors.green,
          textColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Future<void> getAIResponse(ChatMessage Prompt) async {
    const baseurl = "http://192.168.238.89:3000/api/data";
    try {
      final url = Uri.parse(baseurl);
      final prompt = Prompt.text;
      final content = [Content.text(prompt)];
      final String generatedText = 'No Response Generated';
      final response = await http.post(url,
          body: jsonEncode({'prompt': prompt}), //User sending to server
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body.toString().replaceAll("**", "").trim());
        final generatedText = data['message'] ?? 'No Response Generated';
        print(data['message']);
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _gptChatUser,
              createdAt: DateTime.now(),
              text: generatedText,
            ),
          );
          _typingUsers.remove(_gptChatUser);
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _gptChatUser,
            createdAt: DateTime.now(),
            text: 'Error: Unable to generate response.',
          ),
        );
        _typingUsers.remove(_gptChatUser);
      });
    }
  }
}
