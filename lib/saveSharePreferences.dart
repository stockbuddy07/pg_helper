// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveData(key, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> saveKey(value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("key", value);
}

Future<String?> getData(key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString(key);
  return value;
}

Future<String?> getKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString("key");
  return value;
}