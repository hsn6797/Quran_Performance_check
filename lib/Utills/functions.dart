import 'package:flutter/material.dart';

class Functions {
  // Go to next screen
  static void changeScreen(BuildContext context, {Widget screen}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static printLoadingTime({DateTime dateStart, DateTime dateEnd}) {
    // Print the duration in which file loads in memory
    var end = dateEnd.difference(dateStart);
    String time =
        'Fetching from JSON File in (' + end.inMilliseconds.toString() + ' ms)';
    print(time);
  }

  static Duration parseDuration(String s) {
    if (s == null || s.isEmpty) return null;
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  static String replaceCharacter(
      String str, String replaceChar, String withChar) {
    if (str.isEmpty) return null;
    String resultString = str;
    if (str.contains(replaceChar)) {
      resultString = str.replaceAll(replaceChar, withChar);
    }
    return resultString;
  }
}
