import 'dart:convert';
import 'package:flutter/services.dart';

class JsonHelper {
  Future<String> _loadFromAsset(String fileName) async {
    return await rootBundle.loadString("assets/$fileName");
  }

  Future<dynamic> getAssetFileJson(String pathInAssets) async {
    String jsonString = await _loadFromAsset(pathInAssets);
    return jsonDecode(jsonString);
  }
}
