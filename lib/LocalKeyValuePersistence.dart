import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print("Loaded");
    return json.decode(prefs.getString(key));
  }

  readStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print("Loaded");
    return prefs.getStringList(key);
  }

  getAllKeys() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
    print("Saved");
  }

  saveStringList(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
    print("Saved");
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    print("Removed");
  }
}