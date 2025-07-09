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
    final todayDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day
        .toString().padLeft(2, '0')}";
    dateController.text = todayDate;

    // Fetch existing meal if available and pre-fill controllers
    dbRef.orderByChild('date').equalTo(todayDate).once().then((snapshot) {
      if (snapshot.snapshot.exists) {
        final existingMeal = snapshot.snapshot.children.first.value as Map;
        breakfastController.text = existingMeal['breakfast'] ?? '';
        lunchController.text = existingMeal['lunch'] ?? '';
        dinnerController.text = existingMeal['dinner'] ?? '';
        snacksController.text = existingMeal['snacks'] ?? '';
      }
    });
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
      final todayDate = dateController.text.trim();
      final mealData = {
        'date': todayDate,
        'breakfast': breakfastController.text.trim(),
        'lunch': lunchController.text.trim(),
        'dinner': dinnerController.text.trim(),
        'snacks': snacksController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      try {
        final snapshot =
        await dbRef.orderByChild('date').equalTo(todayDate).once();

        if (snapshot.snapshot.exists) {
          final existingMealKey = snapshot.snapshot.children.first.key;
          await dbRef.child(existingMealKey!).update(mealData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal updated successfully')),
          );
        } else {
          await dbRef.push().set(mealData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal added successfully')),
          );
        }

        breakfastController.clear();
        lunchController.clear();
        dinnerController.clear();
        snacksController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Colors.deepPurple.shade300, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 15),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Add Daily Meal",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                label: 'Snacks(Optional)',
                controller: snacksController,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: submitMeal,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    'Submit Meal',
                    style: TextStyle(fontSize: 20, color: Colors.white),
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
