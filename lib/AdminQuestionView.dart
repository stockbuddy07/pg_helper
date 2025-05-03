import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pg_helper/saveSharePreferences.dart';
import 'models/userAskQuestion.dart';

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

  Future<void> _loadUserData() async {
    String? userkey = await getKey();
    String? userData = await getData(key);
    setState(() {
      data = userData!;
      userKey = userkey!;
    });
  }

  Future<void> sendAnswerEmail({
    required String userEmail,
    required String question,
    required String answer,
  }) async {
    const serviceId = 'service_jn6pzmj';
    const templateId = 'template_ra9zhe6';
    const publicKey = '7-35kbYMhjWxg04ku';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'user_email': userEmail,
          'question': question,
          'answer': answer,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Scaffold(
            backgroundColor: const Color(0xfff2f6f7),
            appBar: AppBar(
              backgroundColor: const Color(0xfff2f6f7),
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Color(0xff12d3c6)),
            ),
            body: Container(
              color: Colors.white38,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "User Questions:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder(
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
                            questionList.add(MapEntry(
                              key,
                              UserAskQuestionModel.fromJson(Map<String, dynamic>.from(value)),
                            ));
                          });

                          return _buildUserQuestions(questionList);
                        } else {
                          return const Center(child: Text('No questions available'));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserQuestions(List<MapEntry<String, UserAskQuestionModel>> questionList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questionList.length,
      itemBuilder: (context, index) {
        final questionKey = questionList[index].key;
        final questionModel = questionList[index].value;
        TextEditingController answerController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
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
                          // Get user email from UserId
                          DatabaseReference userRef = FirebaseDatabase.instance
                              .ref()
                              .child('PG_helper/tblUser/${questionModel.UserId}');
                          DatabaseEvent event = await userRef.once();
                          String email = (event.snapshot.value as Map)['Email'];

                          // Send email via EmailJS
                          await sendAnswerEmail(
                            userEmail: email,
                            question: questionModel.Question,
                            answer: answer,
                          );

                          // Delete question using the correct Firebase key
                          DatabaseReference questionRef = FirebaseDatabase.instance
                              .ref()
                              .child('PG_helper/tblUserQuestions/$questionKey');
                          await questionRef.remove();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Answer sent and question removed')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: const Text('Send Answer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
