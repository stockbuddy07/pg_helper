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
import 'RoomInfoPage.dart';
import 'RoommatesInfoPage.dart';   // ✅ NEW import

class HomePage extends StatefulWidget {
  final String firstname;

  const HomePage({super.key, required this.firstname});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final key = 'username';
  late String userKey;
  late String data;

  final _messagingService = MessagingService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late AnimationController _controller;
  late Animation<double> _animation;

  String breakfast = '';
  String lunch = '';
  String dinner = '';

  final List<_DashboardItem> _features = [
    _DashboardItem("Room Info", Icons.meeting_room, Colors.blue),
    _DashboardItem("Roommates Info", Icons.people, Colors.teal),
    _DashboardItem("Raise a Query", Icons.help_center, Colors.orange),
  ];

  @override
  void initState() {
    super.initState();
    _messagingService.init(context);
    _loadUserData();
    _loadTodayMeals();
    _controller =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  Future<void> _loadUserData() async {
    String? userkey = await getKey();
    String? userData = await getData(key);
    setState(() {
      data = userData ?? '';
      userKey = userkey ?? '';
    });

    var fcmToken = await _fcm.getToken();
    final updatedData = {"UserFCMToken": fcmToken};
    final userRef =
    FirebaseDatabase.instance.ref().child("PG_helper/tblUser/$userKey");
    await userRef.update(updatedData);
  }

  Future<void> _loadTodayMeals() async {
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dbRef =
    FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');

    final event = await dbRef.once();
    if (event.snapshot.value == null) return;

    final map = event.snapshot.value as Map<dynamic, dynamic>;
    final mealsList = map.entries
        .map((e) => MealData.fromMap(e.value, e.key))
        .where((meal) => meal.date == todayDate)
        .toList();

    for (var meal in mealsList) {
      setState(() {
        breakfast = meal.breakfast;
        lunch = meal.lunch;
        dinner = meal.dinner;
      });
    }
  }

  /// Dashboard card
  Widget _buildAnimatedCard(int index) {
    final item = _features[index];
    return ScaleTransition(
      scale: _animation,
      child: InkWell(
        onTap: () {
          switch (item.label) {
            case "Room Info":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomInfoPage(firstname: widget.firstname),
                ),
              );
              break;
            case "Roommates Info":
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RoommatesInfoPage(firstname: widget.firstname), // ✅ pass firstname
                ),
              );
              break;
            case "Raise a Query":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyHelpDesk()),
              );
              break;
            default:
              break;
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.9),
                item.color.withOpacity(0.6),
              ],
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

  /// Meal card
  Widget _buildMealCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(2, 3),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value.isNotEmpty ? value : "Not Available",
                textAlign: TextAlign.center),
          ],
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
            Text(
              "Welcome",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.firstname,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      endDrawer: const DrawerCode(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            /// Meal section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "🍽️ Today's Meals",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  _buildMealCard("Breakfast", breakfast, Icons.breakfast_dining),
                  _buildMealCard("Lunch", lunch, Icons.lunch_dining),
                  _buildMealCard("Dinner", dinner, Icons.dinner_dining),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Dashboard grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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

            /// Rules
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "📌 PG Rules & Regulations :",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16  ),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Dashboard item model
class _DashboardItem {
  final String label;
  final IconData icon;
  final Color color;

  _DashboardItem(this.label, this.icon, this.color);
}
