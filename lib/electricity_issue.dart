import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'BottomNavigation.dart';
import 'models/userAskQuestion.dart';

class ElectricityIssuePage extends StatefulWidget {
  const ElectricityIssuePage({super.key});

  @override
  State<ElectricityIssuePage> createState() => _ElectricityIssuePageState();
}

class _ElectricityIssuePageState extends State<ElectricityIssuePage>{
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
      appBar: AppBar(title: const Text("Electricity Issue")),
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
                          colors: [Color(0xff12d3c6), Color(0xff12d3c6)],
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
                                            "Thank you for your question. We will connect with you soon. Feel free to ask more queries if you have."),
                                        actions: <Widget>[
                                          OutlinedButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                  const BottomBar(),
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                  const Color(0xff12d3c6), // Change color here
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

List<Map<String, String>> faqs = [
  {
    "question": "Is electricity included in the rent?",
    "answer": "Electricity charges are included up to a certain limit. Extra usage (e.g., personal appliances) may be billed separately."
  },
  {
    "question": "Can I use electric appliances like heaters or induction cookers?",
    "answer": "Use of high-power appliances requires prior permission. Please contact the admin for approval."
  },
  {
    "question": "What happens during a power cut?",
    "answer": "We have a backup generator/inverter to ensure essential services remain uninterrupted."
  },
  {
    "question": "How is extra electricity usage calculated?",
    "answer": "A sub-meter reading is taken monthly, and extra units used are charged as per the current rates."
  }
];