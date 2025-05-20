import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'models/userAskQuestion.dart';
import 'package:http/http.dart' as http;

class AdminQuestionView extends StatefulWidget {
  const AdminQuestionView({super.key});

  @override
  _AdminQuestionView createState() => _AdminQuestionView();
}

class _AdminQuestionView extends State<AdminQuestionView> {
  Query dbRef = FirebaseDatabase.instance.ref().child('PG_helper/tblUserQuestions');
  late String data;
  final key = 'username';
  late String userKey;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> sendNotificationToUser({
    required String token,
    required String title,
    required String body,
  }) async {
    const String serverKey = 'YOUR_SERVER_KEY_HERE'; // 🔒 Replace with your actual FCM server key
    final Uri fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

    try {
      final response = await http.post(
        fcmUrl,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('FCM Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('FCM Exception: $e');
    }
  }

  Future<void> _loadUserData() async {
    String? userkey = await getKey();
    String? userData = await getData(key);
    if (mounted) {
      setState(() {
        data = userData!;
        userKey = userkey!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6f7),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f6f7),
        title: const Text('Admin Question View', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xff12d3c6)),
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map;
            List<MapEntry<String, UserAskQuestionModel>> questionList = [];

            map.forEach((key, value) {
              final model = UserAskQuestionModel.fromJson(Map<String, dynamic>.from(value));
              if (model.Status != 'Completed') {
                questionList.add(MapEntry(key, model));
              }
            });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questionList.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(questionList[index]);
              },
            );
          } else {
            return const Center(child: Text('No questions available'));
          }
        },
      ),
    );
  }

  Widget _buildQuestionCard(MapEntry<String, UserAskQuestionModel> entry) {
    final questionKey = entry.key;
    final questionModel = entry.value;
    final TextEditingController answerController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.question_answer, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      questionModel.Question ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Answer:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal.shade100),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Answer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff12d3c6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    String answer = answerController.text.trim();
                    if (answer.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an answer')),
                      );
                      return;
                    }

                    try {
                      DatabaseReference userRef = FirebaseDatabase.instance
                          .ref()
                          .child('PG_helper/tblUser/${questionModel.UserId}');
                      DatabaseEvent event = await userRef.once();
                      Map userData = event.snapshot.value as Map;
                      String fcmToken = userData['FCMToken'] ?? '';

                      await FirebaseDatabase.instance
                          .ref()
                          .child('PG_helper/tblUserQuestions/$questionKey')
                          .update({
                        'Answer': answer,
                        'Status': 'Completed',
                      });

                      if (fcmToken.isNotEmpty) {
                        await sendNotificationToUser(
                          token: fcmToken,
                          title: 'Your question has been answered!',
                          body: answer,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Answer submitted successfully')),
                      );

                      answerController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
