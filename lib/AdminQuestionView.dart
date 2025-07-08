// Imports
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pg_helper/saveSharePreferences.dart';

class AdminQuestionView extends StatefulWidget {
  const AdminQuestionView({super.key});

  @override
  _AdminQuestionView createState() => _AdminQuestionView();
}

class _AdminQuestionView extends State<AdminQuestionView> {
  final Query dbRef =
  FirebaseDatabase.instance.ref().child('PG_helper/tblUserQuestions');
  final String key = 'username';
  late String data;
  late String userKey;
  final Map<String, Map<String, dynamic>> _userInfoCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    if (_userInfoCache.containsKey(userId)) {
      return _userInfoCache[userId]!;
    }

    try {
      final userRef =
      FirebaseDatabase.instance.ref().child('PG_helper/tblUser/$userId');
      final event = await userRef.once();
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        final userData =
        data.map((key, value) => MapEntry(key.toString(), value));
        _userInfoCache[userId] = userData;
        return userData;
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('❌ Error fetching user data: $e');
      return {};
    }
  }

  Future<void> sendNotificationToUser({
    required String token,
    required String title,
    required String body,
  }) async {
    const String serverKey = 'YOUR_SERVER_KEY_HERE';
    final Uri fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

    try {
      final response = await http.post(
        fcmUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {'title': title, 'body': body},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done'
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

  String formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Unknown time';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}  ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Invalid time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xfff2f6f7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Admin Question View',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black45,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Unanswered'),
              Tab(text: 'History'),
            ],
          ),
        ),

        body: StreamBuilder(
          stream: dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            }
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map dataMap = snapshot.data!.snapshot.value as Map;
              List<MapEntry<String, Map>> unanswered = [];
              List<MapEntry<String, Map>> history = [];

              dataMap.forEach((key, value) {
                final questionData = Map<String, dynamic>.from(value);
                if (questionData['Status'] == 'Completed') {
                  history.add(MapEntry(key, questionData));
                } else {
                  unanswered.add(MapEntry(key, questionData));
                }
              });

              // Sort history by timestamp descending
              history.sort((a, b) {
                final aTime =
                    DateTime.tryParse(a.value['Timestamp'] ?? '') ??
                        DateTime(0);
                final bTime =
                    DateTime.tryParse(b.value['Timestamp'] ?? '') ??
                        DateTime(0);
                return bTime.compareTo(aTime);
              });

              return TabBarView(
                children: [
                  _buildListView(unanswered, isHistory: false),
                  _buildListView(history, isHistory: true),
                ],
              );
            } else {
              return const Center(child: Text('No questions available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<MapEntry<String, Map>> list,
      {required bool isHistory}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final questionData = list[index].value;
        final userId = questionData['UserId'] ?? '';
        return FutureBuilder<Map<String, dynamic>>(
          future: _getUserInfo(userId),
          builder: (context, snapshot) {
            final user = snapshot.data ?? {};
            return isHistory
                ? _buildHistoryCard(list[index], user)
                : _buildQuestionCard(list[index], user);
          },
        );
      },
    );
  }

  Widget _buildQuestionCard(MapEntry<String, Map> entry, Map user) {
    final questionData = entry.value;
    final questionKey = entry.key;
    final TextEditingController answerController = TextEditingController();
    final timestamp = formatTimestamp(questionData['Timestamp']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(user, questionData),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.question_answer, color: Color(0xD72A8AEA)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      questionData['Question'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Date: $timestamp',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text('Answer:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              TextField(
                controller: answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    const BorderSide(color: Color(0xffe0e0e0), width: 1),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Answer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xD72A8AEA),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                      String fcmToken = user['FCMToken'] ?? '';
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
                        const SnackBar(
                            content: Text('Answer submitted successfully')),
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

  Widget _buildHistoryCard(MapEntry<String, Map> entry, Map user) {
    final questionData = entry.value;
    final timestamp = formatTimestamp(questionData['Timestamp']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(user, questionData),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.question_mark, color: Color(0xD72A8AEA)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      questionData['Question'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Date: $timestamp',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "Answer: ${questionData['Answer'] ?? 'No answer'}",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(Map user, Map questionData) {
    String name =
    "${user['FirstName'] ?? ''} ${user['LastName'] ?? ''}".trim();
    String number = user['ContactNumber'] ?? 'N/A';
    String room = user['RoomNumber'] ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Name: ${name.isNotEmpty ? name : 'Unknown'}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("Number: $number"),
        Text("Room: $room"),
      ],
    );
  }
}
