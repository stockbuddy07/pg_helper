import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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

  List<Map<dynamic, dynamic>> previousMeals = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(today);
    dateController.text = todayDate;

    _loadTodayMeal(todayDate);
    _loadPreviousMeals();
  }

  Future<void> _loadTodayMeal(String date) async {
    final snapshot = await dbRef.orderByChild('date').equalTo(date).once();
    if (snapshot.snapshot.exists) {
      final existingMeal = snapshot.snapshot.children.first.value as Map;
      breakfastController.text = existingMeal['breakfast'] ?? '';
      lunchController.text = existingMeal['lunch'] ?? '';
      dinnerController.text = existingMeal['dinner'] ?? '';
      snacksController.text = existingMeal['snacks'] ?? '';
    }
  }

  Future<void> _loadPreviousMeals() async {
    final snapshot = await dbRef.orderByChild('timestamp').once();
    final List<Map<dynamic, dynamic>> meals = [];

    for (final child in snapshot.snapshot.children) {
      final data = child.value as Map<dynamic, dynamic>;
      meals.add(data);
    }

    meals.sort((a, b) => b['date'].compareTo(a['date']));
    setState(() {
      previousMeals = meals.take(5).toList(); // Show last 5 meals
    });
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
          _showSnackbar('Meal updated successfully', isSuccess: true);
        } else {
          await dbRef.push().set(mealData);
          _showSnackbar('Meal added successfully', isSuccess: true);
        }

        _loadPreviousMeals();
        breakfastController.clear();
        lunchController.clear();
        dinnerController.clear();
        snacksController.clear();
      } catch (e) {
        _showSnackbar('Error: $e');
      }
    }
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(dateController.text),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      dateController.text = formatted;
      _loadTodayMeal(formatted);
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 16),
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            BorderSide(color: Colors.deepPurple.shade300, width: 1.5),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget mealRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: ${value ?? '-'}",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMealTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previous Meals Timeline',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ...previousMeals.map((meal) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dot and line
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 120,
                    color: Colors.deepPurple.shade200,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Meal content card
              Expanded(
                child: Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['date'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        mealRow(Icons.free_breakfast_outlined, 'Breakfast',
                            meal['breakfast']),
                        mealRow(Icons.lunch_dining, 'Lunch', meal['lunch']),
                        mealRow(Icons.dinner_dining, 'Dinner', meal['dinner']),
                        if ((meal['snacks'] ?? '').toString().isNotEmpty)
                          mealRow(Icons.cookie, 'Snacks', meal['snacks']),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Add Daily Meal",
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                label: 'Date',
                controller: dateController,
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _selectDate,
              ),
              buildTextField(
                label: 'Breakfast',
                controller: breakfastController,
                icon: Icons.free_breakfast_outlined,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter breakfast' : null,
              ),
              buildTextField(
                label: 'Lunch',
                controller: lunchController,
                icon: Icons.lunch_dining,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter lunch' : null,
              ),
              buildTextField(
                label: 'Dinner',
                controller: dinnerController,
                icon: Icons.dinner_dining,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter dinner' : null,
              ),
              buildTextField(
                label: 'Snacks (Optional)',
                controller: snacksController,
                icon: Icons.cookie,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  onPressed: submitMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    'Submit Meal',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              buildMealTimeline(),
            ],
          ),
        ),
      ),
    );
  }
}
