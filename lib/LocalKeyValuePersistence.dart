import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print("[SharedPref] Loaded: " + key);
    return json.decode(prefs.getString(key));
  }

  readStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print("[SharedPref] Loaded: " + key);
    return prefs.getStringList(key);
  }

  getAllKeys() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
    print("[SharedPref] Saved: " + key);
  }

  saveStringList(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
    print("[SharedPref] Saved: " + key);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    print("[SharedPref] Removed: " + key);
  }

  findAndRemoveStringList(String key, String listKey) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = await readStringList(key);
    var toRemove = [];
    await prefs.remove(key);
    list.forEach((data) {
      if(data == listKey) {
        toRemove.add(data);
      }
    });
    list.removeWhere( (e) => toRemove.contains(e));
    await saveStringList(key, list);
  }
}