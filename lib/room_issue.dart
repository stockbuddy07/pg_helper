import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'BottomNavigation.dart';
import 'models/userAskQuestion.dart';

class RoomIssuePage extends StatefulWidget {
  const RoomIssuePage({super.key});

  @override
  State<RoomIssuePage> createState() => _RoomIssuePageState();
}

class _RoomIssuePageState extends State<RoomIssuePage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();
  late String userKey;
  DatabaseReference dbRef2 =
  FirebaseDatabase.instance.ref().child('PG_helper/tblUserQuestions');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userData = await getKey();
    setState(() {
      userKey = userData!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Room Issue")),
      body: Container(
        color: const Color(0xfff2f6f7),
        child: ListView.builder(
          itemCount: faqs.length + 1, // Add 1 for the additional card
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 8,
                    margin: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.blueAccent, Colors.blueAccent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Center(
                          child: Lottie.asset(
                            'assets/Animation/help_desk.json',
                            repeat: true,
                            reverse: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _textFieldController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Ask question';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Ask a question...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  var question = _textFieldController.text;
                                  UserAskQuestionModel regobj =
                                  UserAskQuestionModel(question, userKey,
                                      DateTime.now().toString(), "Pending","");
                                  dbRef2.push().set(regobj.toJson());
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: const Text(
                                            " Thank you for your question😊.\n We will connect with you soon 🔜!!\n Feel free to ask more queries ."),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              OutlinedButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const BottomBar(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],

                                      );
                                    },
                                  );
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                   Colors.blueAccent, // Change color here
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return ExpansionTile(
                title: Text(faqs[index - 1]['question']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(faqs[index - 1]['answer']!),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

List<Map<String, String>> faqs =[
  {
    "question": "Are rooms shared or private?",
    "answer": "We offer both shared and private rooms. Availability may vary, so please check with the admin."
  },
  {
    "question": "What furnishings are provided in the room?",
    "answer": "Each room includes a bed, mattress, table, chair, cupboard, and fan."
  },
  {
    "question": "Can I choose my roommate?",
    "answer": "We try to accommodate roommate preferences based on availability and mutual agreement."
  },
  {
    "question": "Is room cleaning provided?",
    "answer": "Yes, housekeeping is done 3 times a week. You can also request extra cleaning if needed."
  }
];