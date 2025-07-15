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
import 'dart:ui';
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
  String snacks = '';

  final List<_DashboardItem> _features = [
    _DashboardItem("Room Info", Icons.meeting_room, Colors.blueAccent),
    _DashboardItem("Roommates Info", Icons.people_alt, Colors.teal),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _messagingService.init(context);
    _loadUserData();
    _loadTodayMeals();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
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
        snacks = meal.snacks;
      });
    }
  }

  Widget _buildMealCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : "Not Available",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1, // Increased ratio = reduced height
            ),
            itemBuilder: (context, index) {
              final item = _features[index];
              return ScaleTransition(
                scale: _animation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.color.withOpacity(0.4),
                            item.color.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (item.label == "Room Info") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RoomInfoPage(firstname: widget.firstname)),
                              );
                            } else if (item.label == "Roommates Info") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RoommatesInfoPage(firstname: widget.firstname)),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item.icon, size: 30, color: Colors.white),
                                const SizedBox(height: 8),
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
                      ),
                    ),
                  ),
                ),
              );

            },
          );
        },
      ),
    );
  }


  Widget _buildMealsSection(BuildContext context) {
    List<Widget> mealCards = [];

    if (breakfast.isNotEmpty) {
      mealCards.add(_buildMealCard("Breakfast", breakfast, Icons.breakfast_dining));
    }
    if (lunch.isNotEmpty) {
      mealCards.add(_buildMealCard("Lunch", lunch, Icons.lunch_dining));
    }
    if (dinner.isNotEmpty) {
      mealCards.add(_buildMealCard("Dinner", dinner, Icons.dinner_dining));
    }
    if (snacks.isNotEmpty) {
      mealCards.add(_buildMealCard("Snacks", snacks, Icons.fastfood));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: mealCards
            .map((card) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.3),
          child: card,
        ))
            .toList(),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
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
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(widget.firstname,
                  style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold)),
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
                  child: const Icon(Icons.menu, size: 28, color: Colors.blueAccent),
                ),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: const DrawerCode(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildSectionHeader(Icons.restaurant, "Today's Meals"),
                      _buildMealsSection(context),
                      const SizedBox(height: 24),
                      _buildSectionHeader(Icons.dashboard, "Quick Access"),
                      _buildQuickAccessSection(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(Icons.rule, "PG Rules & Regulations"),
                      _buildRulesSection(),
                    ],
                  ),
                ),
              ),
            );
          },
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
