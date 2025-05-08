import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'drawerSideNavigation.dart';
import 'models/userAskQuestion.dart';
import 'package:pg_helper/saveSharePreferences.dart'; // for getKey()

class UserQnAView extends StatefulWidget {
  const UserQnAView({super.key});

  @override
  State<UserQnAView> createState() => _UserQnAViewState();
}

class _UserQnAViewState extends State<UserQnAView> {
  late String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? uid = await getKey();
    setState(() {
      userId = uid ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Answered Questions')),
      endDrawer: const DrawerCode(),
      body: userId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child('PG_helper/tblUserQuestions')
            .orderByChild('UserId')
            .equalTo(userId)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data =
            snapshot.data!.snapshot.value as Map;
            List<UserAskQuestionModel> questionList = data.values
                .map((e) => UserAskQuestionModel.fromJson(
                Map<String, dynamic>.from(e)))
                .where((q) => q.Status == 'Completed')
                .toList();

            if (questionList.isEmpty) {
              return const Center(child: Text('No answered questions yet.'));
            }

            // Sort by most recent
            questionList.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

            return ListView.builder(
              itemCount: questionList.length,
              itemBuilder: (context, index) {
                final q = questionList[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    title: Text("Q: ${q.Question}"),
                    subtitle: Text("Answer: ${q.answer ?? 'No answer'}"),
                    trailing: Text(
                      q.dateTime ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No answered questions found.'));
          }
        },
      ),
    );
  }
}
