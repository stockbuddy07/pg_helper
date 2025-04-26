// ignore_for_file: file_names

class MealData {
  final String id;
  final String breakfast;
  final String date;
  final String dinner;
  final String lunch;
  final String snacks;

  MealData(this.id, this.breakfast, this.date, this.dinner,
      this.lunch,
      this.snacks);

  factory MealData.fromMap(Map<dynamic, dynamic> map, String id) {
    return MealData(
      id,
      map["breakfast"] ?? '',
      map["date"] ?? '',
      map["dinner"] ?? '',
      map["lunch"] ?? '',
      map["snacks"] ?? '',
    );
  }
}
