import 'dart:convert';
import 'package:farmvision/Services/uploadPhotoPage.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatUser _currentUser;
  final ScrollController _scrollController = ScrollController();
  String userState = "Maharashtra";
  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'Gemini',
    lastName: 'AI',
  );

  List<QuickReply> _getQuickReplies(String state) {
    return [
      QuickReply(
        title: "Best crops in $state?",
        value: "What are the best crops to grow in $state?",
      ),
      QuickReply(
        title: "Soil care in $state",
        value: "How to take care of soil in $state?",
      ),
      QuickReply(
        title: "Water needs in $state",
        value: "What are the water needs for crops in $state?",
      ),
      QuickReply(
        title: "Cattle diseases in $state",
        value: "What are the common cattle diseases in $state?",
      ),
      QuickReply(
        title: "Dairy farming in $state",
        value: "How is dairy farming in $state?",
      ),
    ];
  }

  List<QuickReply> _getInitialQuickReplies(String state) {
    return [
      QuickReply(
        title: "Best crops in $state?",
        value: "What are the best crops to grow in $state?",
      ),
      QuickReply(
        title: "Soil care in $state",
        value: "How to take care of soil in $state?",
      ),
      QuickReply(
        title: "Water needs in $state",
        value: "What are the water needs for crops in $state?",
      ),
      QuickReply(
        title: "Cattle diseases in $state",
        value: "What are the common cattle diseases in $state?",
      ),
      QuickReply(
        title: "Dairy farming in $state",
        value: "How is dairy farming in $state?",
      ),
    ];
  }

  List<QuickReply> _getDairyFarmingQuickReplies(String state) {
    return [
      QuickReply(
        title: "Best breeds in $state",
        value: "What are the best dairy breeds in $state?",
      ),
      QuickReply(
        title: "Feeding tips in $state",
        value: "What are the best feeding tips for dairy farming in $state?",
      ),
      QuickReply(
        title: "Common issues in $state",
        value: "What are common issues in dairy farming in $state?",
      ),
      QuickReply(
        title: "Milk production in $state",
        value: "How to improve milk production in $state?",
      ),
      QuickReply(
        title: "Marketing in $state",
        value:
            "What are the best practices for marketing dairy products in $state?",
      ),
    ];
  }

  QuickReplyOptions _quickReplyOptions(String state) {
    return QuickReplyOptions(
      onTapQuickReply: (QuickReply reply) {
        _sendQuickReplyMessage(reply);
      },
      quickReplyStyle: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      quickReplyTextStyle: TextStyle(color: Colors.white),
      quickReplyMargin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      quickReplyPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }

  List<QuickReply> _quickReplies = [];

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
    _sendInitialMessage();
    _quickReplies = _getInitialQuickReplies("Maharashtra");
  }

  void _sendInitialMessage() {
    ChatMessage initialMessage = ChatMessage(
      user: _gptChatUser,
      createdAt: DateTime.now(),
      text: "Hello! How can I help you?",
    );

    setState(() {
      _messages.insert(0, initialMessage);
    });
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
    const baseurl = "http://192.168.177.89:3000/api/data";
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

  void _sendQuickReplyMessage(QuickReply reply) {
    ChatMessage message = ChatMessage(
      user: _currentUser,
      createdAt: DateTime.now(),
      text: reply.value.toString(),
    );

    setState(() {
      _messages.insert(0, message);
      _typingUsers.add(_gptChatUser);
      if (reply.value!.contains("How is dairy farming")) {
        _quickReplies = _getDairyFarmingQuickReplies(userState);
      } else {
        // Revert to initial quick replies or handle other cases if needed
        _quickReplies = _getInitialQuickReplies(userState);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    getAIResponse(message);
  }

  Widget _buildQuickReplies(String state) {
    // List<QuickReply> quickReplies = _getQuickReplies(state);
    List<QuickReply> quickReplies = _quickReplies.isNotEmpty
        ? _quickReplies
        : _getInitialQuickReplies(state);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickReplies.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendQuickReplyMessage(quickReplies[index]),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  quickReplies[index].title,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
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
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                      height: 60, child: _buildQuickReplies(userState))),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: DashChat(
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
              quickReplyOptions: _quickReplyOptions(userState),
              messageOptions: MessageOptions(
                currentUserContainerColor: Colors.blue,
                containerColor: Colors.green,
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Future<void> getAIResponse(ChatMessage Prompt) async {
    String question = Prompt.text +
        '\nGive exact answer in bulletin points, No extra descriptions';
    const baseurl = "http://192.168.177.89:3000/api/data";
    try {
      final url = Uri.parse(baseurl);
      final prompt = question;
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
