import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'drawerSideNavigation.dart';
import 'firebase_api.dart';
import 'models/MealsModel.dart';
import 'RoomInfoPage.dart';
import 'RoommatesInfoPage.dart';

class HomePage extends StatefulWidget {
  final String firstname;

  const HomePage({super.key, required this.firstname});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
    _DashboardItem("Room Info", Icons.meeting_room, Colors.blueAccent),
    _DashboardItem("Roommates Info", Icons.people_alt, Colors.teal),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Added scaffold key

  @override
  void initState() {
    super.initState();
    _messagingService.init(context);
    _loadUserData();
    _loadTodayMeals();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this
    );
    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack
    );
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
      data = userData ?? '';
      userKey = userkey ?? '';
    });

    var fcmToken = await _fcm.getToken();
    final updatedData = {"UserFCMToken": fcmToken};
    final userRef = FirebaseDatabase.instance.ref().child("PG_helper/tblUser/$userKey");
    await userRef.update(updatedData);
  }

  Future<void> _loadTodayMeals() async {
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dbRef = FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');

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

  Widget _buildAnimatedCard(int index) {
    final item = _features[index];
    return ScaleTransition(
      scale: _animation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                    builder: (_) => RoommatesInfoPage(firstname: widget.firstname),
                  ),
                );
                break;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(0.8),
                  item.color.withOpacity(0.5),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : "Not Available",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Added scaffold key
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              widget.firstname,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu,
                  size: 28,
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(), // Changed to use scaffold key
            ),
          ),
        ],
      ),
      endDrawer: const DrawerCode(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Today's Meals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Meals",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildMealCard("Breakfast", breakfast, Icons.breakfast_dining)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMealCard("Lunch", lunch, Icons.lunch_dining)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMealCard("Dinner", dinner, Icons.dinner_dining)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Access Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.dashboard, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    "Quick Access",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _features.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) => _buildAnimatedCard(index),
              ),
            ),
            const SizedBox(height: 24),

            // PG Rules Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.rule, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    "PG Rules & Regulations",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRuleItem("1. Maintain cleanliness in rooms and common areas."),
                      _buildRuleItem("2. No loud music or parties after 10 PM."),
                      _buildRuleItem("3. Outside guests are not allowed without permission."),
                      _buildRuleItem("4. Meal timings must be followed strictly."),
                      _buildRuleItem("5. Damages to property will be charged."),
                      _buildRuleItem("6. Maintain discipline and decorum."),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
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