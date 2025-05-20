import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddDailyMeal extends StatefulWidget {
  const AddDailyMeal({super.key});

  @override
  State<AddDailyMeal> createState() => _AddDailyMealState();
}

class _AddDailyMealState extends State<AddDailyMeal> {
  final DatabaseReference dbRef =
  FirebaseDatabase.instance.ref().child('PG_helper/tblDailyMeals');
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController breakfastController = TextEditingController();
  final TextEditingController lunchController = TextEditingController();
  final TextEditingController dinnerController = TextEditingController();
  final TextEditingController snacksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    dateController.text =
    "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    dateController.dispose();
    breakfastController.dispose();
    lunchController.dispose();
    dinnerController.dispose();
    snacksController.dispose();
    super.dispose();
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

      breakfastController.clear();
      lunchController.clear();
      dinnerController.clear();
      snacksController.clear();
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Daily Meal'),
        backgroundColor: const Color(0xff12d3c6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                label: 'Date',
                controller: dateController,
                readOnly: true,
              ),
              buildTextField(
                label: 'Breakfast',
                controller: breakfastController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter breakfast' : null,
              ),
              buildTextField(
                label: 'Lunch',
                controller: lunchController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter lunch' : null,
              ),
              buildTextField(
                label: 'Dinner',
                controller: dinnerController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter dinner' : null,
              ),
              buildTextField(
                label: 'Snacks (Optional)',
                controller: snacksController,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submitMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff12d3c6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Submit Meal',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
