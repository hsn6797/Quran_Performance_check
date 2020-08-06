import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Models/quran_helper.dart';
import 'package:audioplayerdb/Screens/ruku_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Models/verse.dart';
import 'my_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Quran'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
//  String URL =
////      'http://192.168.10.6:8888/PHP_Scripts/01.mp3';
////      'http://download.quranurdu.com/Al%20Quran%20with%20Urdu%20Translation%20By%20Mishari%20Bin%20Rashid%20Al%20Afasi/1%20Al%20Fatiha.mp3';
////      'http://quranapp.masstechnologist.com/01.mp3';
////      'https://luan.xyz/files/audio/ambient_c_motion.mp3';
//      'https://firebasestorage.googleapis.com/v0/b/quranpashto-5a040.appspot.com/o/mp3%2F001-Al-Fatiha-Ruku-01.mp3?alt=media&token=ba4b801b-dfc5-40b6-a1fc-2e04c0fc6721';

  List<Chapter> _chaptersList = [];

  bool _progressBarActive = false;
  QuranHelper _qh;

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }
    return false;
  }

  void setUp() async {
    setState(() => _progressBarActive = true);
    var dateS = DateTime.now();

    _qh = QuranHelper.instance;

    //fetch list from JSON File
    _chaptersList = await _qh.ChaptersList();

    var dateE = DateTime.now();

    setState(() => _progressBarActive = false);

    var end = dateE.difference(dateS);
    String time =
        'Fetching from JSON File in (' + end.inMilliseconds.toString() + ' ms)';
    print(time);

    _qh = null;
  }

  @override
  Widget build(BuildContext context) {
//    MyPlayer _mp = MyPlayer(URL);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          ListView.builder(
            itemBuilder: (context, ind) {
              final chapter = _chaptersList[ind];
              return ListTile(
                onTap: () {
                  // go to rukus screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RukuScreen(
                              chapter: chapter,
                            )),
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${chapter.ind}- ${chapter.english_name}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${chapter.name}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Total Verses ${chapter.total_verses}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              );
            },
            itemCount: _chaptersList.length,
          ),
          _progressBarActive == true
              ? Center(child: const CircularProgressIndicator())
              : Container(
                  height: 10,
                ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('Init Called!!');

//    get all chapters list
    setUp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Dispose Called!!');

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      this.setUp();
      print('App Resumed');
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      releaseResources();

      print('App Inactive');
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      releaseResources();

      print('App Paused');
    }
  }

  void releaseResources() {
    if (_chaptersList != null && _chaptersList.length == 0)
      _chaptersList.clear();
    _qh = null;
  }
}
