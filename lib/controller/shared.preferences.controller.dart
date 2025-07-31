import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesController {
   get(BuildContext context,String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  set(BuildContext context,String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(key, value);
    } catch (e) {
      log('Error saving value to SharedPreferences: $e');
    }

  }

}
