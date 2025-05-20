import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'MyQueries_userHomePage.dart';
import 'drawerSideNavigation.dart';
import 'firebase_api.dart';
import 'models/MealsModel.dart';
import 'HelpDesk.dart';



class HomePage extends StatefulWidget {
  final String firstname;

  const HomePage({super.key, required this.firstname});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Query dbRef2 = FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');
  final key = 'username';
  late String userKey;
  late String data;
  final _messagingService = MessagingService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<_DashboardItem> _features = [
    _DashboardItem(" Room Info", Icons.meeting_room, Colors.blue),
    _DashboardItem(" Today's Meals", Icons.fastfood, Colors.orange),
    _DashboardItem(" Raise a Query", Icons.message, Colors.green),
    _DashboardItem(" My Queries", Icons.inbox, Colors.deepPurple),
    _DashboardItem(" Complaints", Icons.report_problem, Colors.red),
    _DashboardItem(" Roommates Info", Icons.people, Colors.teal),
  ];

  @override
  void initState() {
    super.initState();
    _messagingService.init(context);
    _loadUserData();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    String? userkey = await getKey();
    String? userData = await getData(key);
    setState(() {
      data = userData!;
      userKey = userkey!;
    });

    var fcmToken = await _fcm.getToken();
    final updatedData = {"UserFCMToken": fcmToken};
    final userRef = FirebaseDatabase.instance.ref().child("PG_helper/tblUser").child(userKey);
    await userRef.update(updatedData);
  }

  Widget _buildAnimatedCard(int index) {
    final item = _features[index];

    return ScaleTransition(
      scale: _animation,
      child: InkWell(
        onTap: () async {
          if (item.label.trim() == "Today's Meals") {
            String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
            DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');

            DatabaseEvent event = await dbRef.once();
            Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
            List<MealData> mealsList = [];
            map.forEach((key, value) {
              mealsList.add(MealData.fromMap(value, key));
            });

            final filteredMeals = mealsList.where((meal) => meal.date == todayDate).toList();

            String breakfast = '', lunch = '', dinner = '';
            for (var meal in filteredMeals) {
              breakfast = meal.breakfast;
              lunch = meal.lunch;
              dinner = meal.dinner;
            }

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Today's Meals"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (breakfast.isNotEmpty)
                        Text(
                          '🥞 Breakfast: $breakfast',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      if (lunch.isNotEmpty)
                        Text(
                          '🍛 Lunch: $lunch',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      if (dinner.isNotEmpty)
                        Text(
                          '🍽️ Dinner: $dinner',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      if (breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty)
                        const Text(
                          'No meal information available for today.',
                          style: TextStyle(fontSize: 20),
                        ),
                    ],
                  ),

                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE'),
                    ),
                  ],
                );
              },
            );
          }

          // Redirections
    else if (item.label.trim() == "Raise a Query") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyHelpDesk()),);
    }
    else if (item.label.trim() == "My Queries") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyQueriesPage()),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.label} tapped')),

      );
    }
    },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [item.color.withOpacity(0.9), item.color.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(3, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 36, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6f7),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f6f7),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
            Text(widget.firstname,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xff12d3c6)),
      ),
      endDrawer: const DrawerCode(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _features.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) => _buildAnimatedCard(index),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("PG Rules & Regulations:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("1. Maintain cleanliness in rooms and common areas."),
                      SizedBox(height: 8),
                      Text("2. No loud music or parties after 10 PM."),
                      SizedBox(height: 8),
                      Text("3. Outside guests are not allowed without permission."),
                      SizedBox(height: 8),
                      Text("4. Meal timings must be followed strictly."),
                      SizedBox(height: 8),
                      Text("5. Damages to property will be charged."),
                      SizedBox(height: 8),
                      Text("6. Maintain discipline and decorum."),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), // bottom padding
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String label;
  final IconData icon;
  final Color color;

  _DashboardItem(this.label, this.icon, this.color);
}
