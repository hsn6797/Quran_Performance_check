import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Models/quran_helper.dart';
import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/my_player.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class VerseListScreen extends StatefulWidget {
  final int chapter_no;
  final String title;
  final RukuMapping ruku;

  VerseListScreen({this.chapter_no, this.title, this.ruku});

  @override
  _VerseListScreenState createState() => _VerseListScreenState();
}

class _VerseListScreenState extends State<VerseListScreen>
    with WidgetsBindingObserver {
  String _URL = 'http://quranapp.masstechnologist.com/QuranAudio/';

  List<Verse> _versesList = [];
  MyPlayer _mp;
  bool _progressBarActive = false;
  int _currentSelectedVerse = -1;
  QuranHelper _qh;

  // Lifecycle Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('${widget.title}'),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemBuilder: (context, ind) {
              final verse = _versesList[ind];
              return ListTile(
                onTap: () async {
                  setState(() {
                    _currentSelectedVerse = ind;
                  });

                  print(verse.arabic_start_time);
                  print(verse.urdu_end_time);
//                   Play Arabic
                  await playVerse(verse.arabic_start_time, verse.urdu_end_time,
                      continues: true);
//                   Play Urdu
//                  await playVerse(verse.urdu_start_time, verse.urdu_end_time,
//                      continues: true);
                },
                title: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${verse.arabic_text}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: _currentSelectedVerse == ind
                          ? Colors.blue
                          : Colors.grey.shade900,
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${verse.urdu_text}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: _currentSelectedVerse == ind
                          ? Colors.blue
                          : Colors.grey.shade900,
                    ),
                  ),
                ),
              );
            },
            itemCount: _versesList.length,
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

//  setup and initialize all variable
    setUp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Dispose Called!!');
    // Release the resources
    releaseResources();
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

  // User Defined Methods
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

    // Define the QuranHandler Veriable
    _qh = QuranHelper.instance;

    // 1- Fetch list from JSON File
    _versesList = await _qh.ChapterVersesList(chapter_no: widget.chapter_no);

    // 2- Filter the List by Ruku start and end verse
    _versesList = _versesList
        .where((element) =>
            element.verse_no >= widget.ruku.first_verse &&
            element.verse_no <= widget.ruku.last_verse)
        .toList();

    var dateE = DateTime.now();

    setState(() => _progressBarActive = false);

    // Print the duration in which file loads in memory
    var end = dateE.difference(dateS);
    String time =
        'Fetching from JSON File in (' + end.inMilliseconds.toString() + ' ms)';
    print(time);

    // Destroy the QuranHandler Variable
    _qh = null;

    _URL = _URL + widget.ruku.file_name;
    print(_URL);

    await _setAudioPlayer(_URL,
        download: true, fileName: widget.ruku.file_name);
  }

  Future<void> _setAudioPlayer(String url, {download = false, fileName}) async {
    // Request Storage permission
    if (!await requestStoragePermission()) return;

    setState(() => _progressBarActive = true);

    _mp = MyPlayer();
    await _mp.loadAudio(url, download: download, fileName: fileName);
    if (_mp.audioFilePath == null) return;

    // Set the url
    await _mp.setUpPlayer(_mp.audioFilePath);

    setState(() => _progressBarActive = false);

    _mp.player.durationStream.listen((event) {
      print('Duration:  ' + event.toString());
    });
    _mp.player.getPositionStream().listen((event) {
      // Track the position
      if (_mp != null && _mp.endPosition != null && event >= _mp.endPosition) {
        setState(() {
          _currentSelectedVerse++;
          if (_currentSelectedVerse > 0 &&
              _currentSelectedVerse < _versesList.length) {
            _mp.startPosition =
                _versesList[_currentSelectedVerse].arabic_start_time;
            _mp.endPosition = _versesList[_currentSelectedVerse].urdu_end_time;
          } else {
            _currentSelectedVerse = -1;
          }
        });
      }
    });
  }

  Future playVerse(Duration s, Duration e, {bool continues = false}) async {
    if (_mp == null) return;
    if (_mp.player.playbackState == AudioPlaybackState.playing)
      await _mp.stopAudio();

    _mp.startPosition = s;
    _mp.endPosition = e;
//    print(s);
//    print(e);
    setState(() => _progressBarActive = true);
    await _mp.seekToNewPosition(continues: continues);
    setState(() => _progressBarActive = false);

    await _mp.playAudio();
  }

  void releaseResources() {
    if (_mp != null) _mp.releasePlayer();
    _mp = null;
    if (_versesList != null && _versesList.length > 0) _versesList.clear();
    _versesList = null;
    _qh = null;
  }
}
