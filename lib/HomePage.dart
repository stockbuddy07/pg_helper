import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:pg_helper/src/fillImageCard.dart';

import 'drawerSideNavigation.dart';
import 'firebase_api.dart';
import 'getHomeData.dart';
import 'models/MealsModel.dart';

class HomePage extends StatefulWidget {
  final String firstname;

  const HomePage({super.key, required this.firstname});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Query dbRef2 =
  FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');
  late String data;
  final key = 'username';
  late String userKey;
  final _messagingService = MessagingService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _messagingService.init(context);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userkey = await getKey();
    String? userData = await getData(key);
    setState(() {
      data = userData!;
      userKey = userkey!;
    });
    var fcmToken = await _fcm.getToken();
    final updatedData = {
      "UserFCMToken": fcmToken,
    };
    final userRef = FirebaseDatabase.instance
        .ref()
        .child("PG_helper/tblUser")
        .child(userKey);
    await userRef.update(updatedData);
  }

  var imagePath =
      "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/HospitalImage%2Faiims.jpeg?alt=media";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth * 1,
          height: constraints.maxHeight * 1,
          child: Scaffold(
            backgroundColor: const Color(0xfff2f6f7),
            appBar: AppBar(
              backgroundColor: const Color(0xfff2f6f7),
              automaticallyImplyLeading: false,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold)),
                  Text(
                    widget.firstname,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              iconTheme: const IconThemeData(
                color: Color(0xff12d3c6),
              ),
            ),
            endDrawer: const DrawerCode(),
            body: Container(
              height: double.maxFinite,
              color: Colors.white38,
              child: SingleChildScrollView(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Meals for Today:",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30)
                          ),
                          color: Color(0xff12d3c6),
                        ),
                        child: StreamBuilder(
                        stream: dbRef2.onValue,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                            Map<dynamic, dynamic> map = snapshot.data!.snapshot.value;
                            List<MealData> mealsList = [];
                            mealsList.clear();
                            map.forEach((key, value) {
                              mealsList.add(MealData.fromMap(value, key));
                            });

                            // Get today's date in the same format as the database date
                            String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

                            return Column(
                              children: [
                                _buildMealCard(
                                  mealsList: mealsList,
                                  todayDate: todayDate,
                                ),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                      ),
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

  Widget _buildMealCard({
    required List<MealData> mealsList,
    required String todayDate,
  }) {
    // Filter the meals based on the date
    List<MealData> filteredMeals = mealsList.where((meal) {
      return meal.date == todayDate;
    }).toList();

    // Get the meal content for all meals (Breakfast, Lunch, Dinner)
    String breakfastContent = '';
    String lunchContent = '';
    String dinnerContent = '';

    for (var meal in filteredMeals) {
      breakfastContent = meal.breakfast;
      lunchContent = meal.lunch;
      dinnerContent = meal.dinner;
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breakfast section
                if (breakfastContent.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Breakfast:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        breakfastContent,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                // Space between sections
                const SizedBox(height: 8),

                // Lunch section
                if (lunchContent.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lunch:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        lunchContent,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                // Space between sections
                const SizedBox(height: 8),

                // Dinner section
                if (dinnerContent.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dinner:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dinnerContent,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ),
    );
  }
}
