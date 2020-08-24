import 'dart:collection';

import 'package:audioplayerdb/Helpers/quran_helper.dart';
import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/Screens/verse_list_screen.dart';
import 'package:audioplayerdb/Utills/functions.dart';
import 'package:audioplayerdb/constants.dart';
import 'package:flutter/foundation.dart';

class MainNotifier extends ChangeNotifier {
  QuranHelper _qh;

  int _currentSelectedVerse = 0;
  int get currentSelectedVerse => _currentSelectedVerse;
  set currentSelectedVerse(int currentVerse) {
    _currentSelectedVerse = currentVerse;
    // Notify changes
    notifyListeners();
  }

  bool _verseScreenLoader = false;
  bool get verseScreenLoader => _verseScreenLoader;
  set verseScreenLoader(bool loading) {
    _verseScreenLoader = loading;
    // Notify changes
    notifyListeners();
  }

  QuranScript _translation = QuranScript.Arabic_Urdu;
  QuranScript get translation => _translation;
  set translation(QuranScript translation) {
    _translation = translation;
    // Notify changes
    notifyListeners();
  }

  List<Verse> _versesList = [];
  UnmodifiableListView<Verse> get versesList =>
      UnmodifiableListView(_versesList);
  int get versesCount => _versesList.length;

  void loadVerses(int chapterNo) async {
    // Define the QuranHandler Veriable
    _qh = QuranHelper.instance;

    _verseScreenLoader = true;
    var dateS = DateTime.now();

    // 1- Fetch list from JSON File
    _versesList = await _qh.ChapterVersesList(chapter_no: chapterNo);
    notifyListeners();
    var dateE = DateTime.now();
    _verseScreenLoader = false;

    // Destroy the QuranHandler Variable
    _qh = null;

    // Print the duration in which file loads in memory
    Functions.printLoadingTime(dateStart: dateS, dateEnd: dateE);
  }
}
