
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddDailyMeal extends StatefulWidget {
  const AddDailyMeal({super.key});

  @override
  State<AddDailyMeal> createState() => _AddDailyMealState();
}

class _AddDailyMealState extends State<AddDailyMeal> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController breakfastController = TextEditingController();
  final TextEditingController lunchController = TextEditingController();
  final TextEditingController dinnerController = TextEditingController();
  final TextEditingController snacksController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    breakfastController.dispose();
    lunchController.dispose();
    dinnerController.dispose();
    snacksController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    dateController.text = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }


  Future<void> submitMeal() async {
    if (_formKey.currentState!.validate()) {
      final mealData = {
        'date': dateController.text.trim(),
        'breakfast': breakfastController.text.trim(),
        'lunch': lunchController.text.trim(),
        'dinner': dinnerController.text.trim(),
        'snacks': snacksController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await dbRef.push().set(mealData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal added successfully')),
      );
      // dateController.text="";
      breakfastController.text="";
      lunchController.text="";
      dinnerController.text="";
      snacksController.text="";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: breakfastController,
                decoration: const InputDecoration(
                  labelText: 'Breakfast',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter breakfast' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lunchController,
                decoration: const InputDecoration(
                  labelText: 'Lunch',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter lunch' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dinnerController,
                decoration: const InputDecoration(
                  labelText: 'Dinner',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter dinner' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: snacksController,
                decoration: const InputDecoration(
                  labelText: 'Snacks',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                width: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff12d3c6),
                      Color(0xff12d3c6)
                    ],
                  ),
                  borderRadius: BorderRadius.all(
                      Radius.circular(20)),
                ),
                child: ElevatedButton(
                  onPressed: submitMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Submit Meal',
                    style:
                    TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
