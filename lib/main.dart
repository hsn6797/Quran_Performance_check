import 'dart:async';

import 'package:audioplayerdb/Helpers/FileHelper.dart';
import 'package:audioplayerdb/Helpers/quran_helper.dart';
import 'package:audioplayerdb/Screens/chapter_list_screen.dart';
import 'package:audioplayerdb/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadChapters();
  // - Get the download directory in App Storage
//  Constant.DOWNLOAD_DIR = await FileHelper.instance.downloadsDir;
//  print(Constant.DOWNLOAD_DIR.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Majid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChapterListScreen(),
    );
  }
}

Future _loadChapters() async {
  //fetch list from JSON File
  Constant.CHAPTER_LIST = await QuranHelper.instance.ChaptersList();
}
