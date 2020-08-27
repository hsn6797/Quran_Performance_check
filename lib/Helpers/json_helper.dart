import 'dart:convert';
import 'package:flutter/services.dart';

class JsonHelper {
  Future<String> _loadFromAsset(String fileName) async {
    try {
      return await rootBundle.loadString("assets/$fileName");
    } catch (err) {
      print('${err.toString()}');
      return null;
    }
  }

  Future<dynamic> getAssetFileJson(String pathInAssets) async {
    String jsonString = await _loadFromAsset(pathInAssets);
    return jsonString != null ? jsonDecode(jsonString) : null;
  }
}
