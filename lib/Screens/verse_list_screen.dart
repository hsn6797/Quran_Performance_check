import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Helpers/quran_helper.dart';
import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/Helpers/my_player.dart';
import 'package:audioplayerdb/Utills/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

const TAG = 'Verse List Screen: ';

enum Translation { Arabic, Urdu, Urdu_Arabic }

class VerseListScreen extends StatefulWidget {
  final int chapter_no;
  final String title;
  final List<RukuMapping> rukus;

  VerseListScreen({this.chapter_no, this.title, this.rukus});

  @override
  _VerseListScreenState createState() => _VerseListScreenState();
}

class _VerseListScreenState extends State<VerseListScreen>
    with WidgetsBindingObserver {
  final _controller = ScrollController();

  MyPlayer _mp;
  QuranHelper _qh;
  List<Verse> _versesList = [];

  bool _isplaying = false;
  bool _progressBarActive = false;
  int _currentSelectedVerse = -1;
  int _currentRukuNo = 0;
  //  bool _hasInternetAccess;
  Translation _translation = Translation.Urdu_Arabic;

//  Icon iconPlay = Icon(Icons.play_arrow);

  /* ------------------ Screen Lifecycle Methods ------------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
        actions: <Widget>[
//          FlatButton(
//            child: Text(
//              _translation.toString().split(".")[1],
//              style: TextStyle(color: Colors.white),
//            ),
//            onPressed: () {
//              setState(() {
//                if (_translation == Translation.Urdu_Arabic)
//                  _translation = Translation.Arabic;
//                else
//                  _translation = Translation.Urdu_Arabic;
//              });
//            },
//          ),
//          IconButton(
//            icon: iconPlay,
//            onPressed: () async {
//              if (_isplaying) {
//                setState(() => iconPlay = Icon(Icons.pause));
//                _mp.pauseAudio();
//              } else {
//                setState(() => iconPlay = Icon(Icons.play_arrow));
//                // Check and change the ruku if needed and play
//                if (_currentSelectedVerse == -1) {
//                  setState(() {
//                    _currentSelectedVerse = 0;
//                  });
//                  await _loadAndPlayVerse(play: true);
//                } else {
//                  _mp.playAudio();
//                }
//              }
//            },
//          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemBuilder: (context, ind) {
              Verse verse = _versesList[ind];
              return ListTile(
                onTap: () async {
                  if (_progressBarActive) return;

                  // Change selected _currentSelectedVerse
                  setState(() => _currentSelectedVerse = ind);

                  // Check and change the ruku if needed and play
                  await _loadAndPlayVerse(play: true);
                },
                title: Padding(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14, top: 10, bottom: 8),
                  child: Text(
                    '${verse.arabic_text}',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'KFGQPC Uthman Taha Naskh',
                      fontWeight: FontWeight.bold,
                      wordSpacing: 4,
                      letterSpacing: 0,
                      color: _currentSelectedVerse == ind
                          ? Colors.blue
                          : Colors.blueGrey.shade900,
                    ),
                  ),
                ),
                subtitle: _translation == Translation.Urdu_Arabic
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 14, right: 20, top: 8, bottom: 20),
                        child: Text(
                          '${verse.urdu_text}',
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 26,
//                            fontFamily: 'noorehira',
                            wordSpacing: 2,
                            color: _currentSelectedVerse == ind
                                ? Colors.blue
                                : Colors.grey.shade900,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 5, bottom: 5),
                      ),
              );
            },
            itemCount: _versesList.length,
            controller: _controller,
          ),
          _progressBarActive == true
              ? Center(child: const CircularProgressIndicator())
              : Container(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    printMessage('Init Called!!');
    // Initialize all resources
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    printMessage('Dispose Called!!');
    // Release all resources
    _releaseResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
//      this.init();
      printMessage('App Resumed');
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
//      releaseResources();
      printMessage('App Inactive');
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
//      releaseResources();
      printMessage('App Paused');
    }
  }

  /* ------------------ User Defined Methods ------------------ */
  void init() async {
//     Request Storage permission
//    if (!await requestStoragePermission()) return;

    // Stream for internet availability
//    Connectivity().onConnectivityChanged.listen((internet) {
//      if (internet == ConnectivityResult.wifi ||
//          internet == ConnectivityResult.mobile) {
//        _hasInternetAccess = true;
//        printMessage('Internet Available');
//      } else {
//        _hasInternetAccess = false;
//        printMessage('No Internet');
//      }
//    });

    // 1- Initialize player object
    _mp = MyPlayer();
    // 2- Initialize player streams
    _mp.player.playerStateStream.listen((playerState) async {
      final processingState = playerState?.processingState;
      final playing = playerState?.playing;
      _isplaying = playing;
//      printMessage("{Player State} -> " + playerState.toString());
      if (_isplaying && processingState == ProcessingState.completed) {
        if (_mp != null) {
//          _controller.animateTo(_containerHight * _currentSelectedVerse,
//              duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
          setState(() {
            _currentSelectedVerse += 1;
//            _controller.jumpTo(double.parse(_currentSelectedVerse.toString()));
          });

          // Play next verse while _currentSelectedVerse is in the range of verse List.
          if (_currentSelectedVerse > -1 &&
              _currentSelectedVerse < _versesList.length) {
            // Check and change the rukuNo if needed and play
            _loadAndPlayVerse(play: true);
          }
        }
      }
    });

//    _mp.player.positionStream.listen((position) {
//      Future.delayed(Duration(seconds: 1), () {
//        printMessage(position.abs().toString());
//      });
//    });

    // Load verses list
    await _loadVerses();

    // load the first ruku audio
    await _loadAndPlayVerse();
  }

  Future<void> _setAudioPlayer() async {
    await _mp.prepareAudioSource(widget.rukus[_currentRukuNo].file_name);
  }

  Future<void> _loadAndPlayVerse({bool play = false}) async {
    setState(() => _progressBarActive = true);
    _mp.pauseAudio();
    // - Select currently playing ruku
    var ruku = widget.rukus[_currentRukuNo];
    // - Check if the selected verse is not in the ruku
    if ((_currentSelectedVerse + 1) < ruku.first_verse ||
        (_currentSelectedVerse + 1) > ruku.last_verse) {
      changeCurrentRukuNo();
      // Load new ruku AudioSource
      await _setAudioPlayer();
    }
    setState(() => _progressBarActive = false);

    if (play) {
      // Play the Verse
      await _playVerse(
        _versesList[_currentSelectedVerse],
        continues: false,
      );
    }
  }

  Future _playVerse(Verse v, {bool continues = false}) async {
    if (_mp == null) return;

    if (_translation == Translation.Urdu_Arabic)
      await _mp.seekToNewPosition(
          start: v.arabic_start_time,
          end: v.urdu_end_time,
          continues: continues);
    else if (_translation == Translation.Arabic)
      await _mp.seekToNewPosition(
          start: v.arabic_start_time,
          end: v.arabic_end_time,
          continues: continues);
    else if (_translation == Translation.Urdu)
      await _mp.seekToNewPosition(
          start: v.urdu_start_time, end: v.urdu_end_time, continues: continues);

    await _mp.playAudio();
  }

  void changeCurrentRukuNo() async {
    // - Check that in which ruku _currentSelectedVerse falls
    for (int num = 0; num < widget.rukus.length; num++) {
      var ruku = widget.rukus[num];
      if ((_currentSelectedVerse + 1) >= ruku.first_verse &&
          (_currentSelectedVerse + 1) <= ruku.last_verse) {
        _currentRukuNo = (num);
        break;
      }
    }
  }

  Future<void> _loadVerses() async {
    // Define the QuranHandler Veriable
    _qh = QuranHelper.instance;

    setState(() => _progressBarActive = true);
    var dateS = DateTime.now();
    // Fetch list from JSON File
    _versesList = await _qh.ChapterVersesList(chapter_no: widget.chapter_no);
    var dateE = DateTime.now();
    setState(() => _progressBarActive = false);

    // Destroy the QuranHandler Variable
    _qh = null;

    // Print the duration in which file loads in memory
    Functions.printLoadingTime(dateStart: dateS, dateEnd: dateE);
  }

  void _releaseResources() {
    if (_mp != null) _mp.releasePlayer();
    _mp = null;
    if (_versesList != null && _versesList.length > 0) _versesList.clear();
    _versesList = null;
    _qh = null;
  }

  void printMessage(String msg) => print(TAG + msg);
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }
    return false;
  }
}
