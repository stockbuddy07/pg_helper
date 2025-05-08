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
    const String serverKey = 'YOUR_SERVER_KEY_HERE'; // 🔒 Keep this secret
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question: ${questionModel.Question}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff12d3c6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      String email = userData['Email'];
                      String fcmToken = userData['FCMToken'] ?? ''; // You must store this token in tblUser

                      String answer = answerController.text.trim();

                      // Update the answer and status
                      await FirebaseDatabase.instance
                          .ref()
                          .child('PG_helper/tblUserQuestions/$questionKey')
                          .update({
                        'Answer': answer,
                        'Status': 'Completed',
                      });

                      // Send notification
                      if (fcmToken.isNotEmpty) {
                        await sendNotificationToUser(
                          token: fcmToken,
                          title: 'Your question has been answered!',
                          body: answer,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Answer sent and question marked as completed')),
                      );

                      answerController.clear();

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }

                  },
                  child: const Text('Submit Answer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
