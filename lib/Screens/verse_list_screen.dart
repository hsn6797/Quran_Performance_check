import 'dart:ui';

import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Helpers/quran_helper.dart';
import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/Helpers/my_player.dart';
import 'package:audioplayerdb/Utills/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


const TAG = 'Verse List Screen: ';

enum Translation { Arabic, Urdu, Arabic_Urdu }

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
  MyPlayer _mp;
  List<Verse> _versesList = [];

  ItemScrollController _itemScrollController = ItemScrollController();
//  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  bool _isplaying = false;

  bool _scrollFirstTime = true;

  bool _progressBarActive = false;
  int _currentSelectedVerse = -1;
  int _currentRukuNo = 0;
  Translation _translation = Translation.Arabic_Urdu;
  Icon iconPlay = Icon(Icons.play_arrow);

//  ItemScrollController _itemScrollController;
  ItemPositionsListener _itemPositionsListener;
//
//  _isplaying = false;
//
//  _progressBarActive = false;
//  _currentSelectedVerse = -1;
//  _currentRukuNo = 0;
//  _translation = Translation.Arabic_Urdu;
//  iconPlay = Icon(Icons.play_arrow);

  /* ------------------ Screen Lifecycle Methods ------------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              _translation.toString().split(".")[1],
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              // - Change Translation mode
              if (_translation == Translation.Arabic_Urdu)
                _translation = Translation.Arabic;
              else
                _translation = Translation.Arabic_Urdu;
              // - Refresh UI
              setState(() {});

              // - Scroll to the current verse
              if (_currentSelectedVerse >= 0) {
                _itemScrollController.jumpTo(index: _currentSelectedVerse);
                // - Play the verse
                await _loadAndPlayVerse(play: true);
              }
            },
          ),
          IconButton(
            icon: iconPlay,
            onPressed: () async {
              if (_isplaying) {
                setState(() => iconPlay = Icon(Icons.play_arrow));
                _mp.pauseAudio();
              } else {
                setState(() => iconPlay = Icon(Icons.pause));
                // Check and change the ruku if needed and play
                if (_currentSelectedVerse == -1) {
                  setState(() => _currentSelectedVerse = 0);
                  await _loadAndPlayVerse(play: true);
                } else {
                  _mp.playAudio();
                }
              }
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          ScrollablePositionedList.builder(
            itemBuilder: (context, ind) {
              Verse verse = _versesList[ind];
              return Card(
                child: Container(
                  child: ListTile(
                    onTap: () async {
                      if (_progressBarActive) return;

                      setState(() => iconPlay = Icon(Icons.pause));
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
                          fontSize: 26,
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
                    subtitle: _translation == Translation.Arabic_Urdu
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 20, top: 8, bottom: 20),
                            child: Text(
                              '${verse.urdu_text}',
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 24,
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
                  ),
                ),
              );
            },
            itemCount: _versesList.length,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
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
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    printMessage('Dispose Called!!');
    // Release all resources
    _releaseResources();
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
    // 1- Initialize objects
    _mp = MyPlayer();
//  _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();

    // 2- Initialize Streams and Listners
    _mp.player.playerStateStream.listen((playerState) async {
      final processingState = playerState?.processingState;
      final playing = playerState?.playing;
      _isplaying = playing;
      if (_isplaying && processingState == ProcessingState.completed) {
        if (_mp != null) {
          setState(() => _currentSelectedVerse += 1);

          // Play next verse while _currentSelectedVerse is in the range of verse List.
          if (_currentSelectedVerse > -1 &&
              _currentSelectedVerse < _versesList.length) {
            // Check and change the rukuNo if needed and play
            _loadAndPlayVerse(play: true);

            // - Scroll to next verse
            if (_currentSelectedVerse > 0) {
              _itemScrollController.jumpTo(index: _currentSelectedVerse);
//              if (!_scrollFirstTime) {
//                _itemScrollController.scrollTo(
//                    index: _currentSelectedVerse,
//                    duration: Duration(seconds: 1),
//                    curve: Curves.fastOutSlowIn);
//              } else {
//                _itemScrollController.scrollTo(
//                    index: _currentSelectedVerse,
//                    duration: Duration(microseconds: 2),
//                    curve: Curves.easeInBack);
//                _scrollFirstTime = false;
//              }
            }
          }
        }
      }
    });

//    _itemPositionsListener.itemPositions.addListener(() {});
    // In Documentation
//    itemPositionsListener.positions.addListener((positions) => ...);

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
      await changeCurrentRukuNo();

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

  Future changeCurrentRukuNo() async {
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

  Future _playVerse(Verse v, {bool continues = false}) async {
    if (_mp == null) return;

    if (_translation == Translation.Arabic_Urdu)
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

  Future<void> _loadVerses() async {
    // Define the QuranHandler Veriable

    setState(() => _progressBarActive = true);
    var dateS = DateTime.now();
    // Fetch list from JSON File
    _versesList = await QuranHelper.instance
        .ChapterVersesList(chapter_no: widget.chapter_no);
    var dateE = DateTime.now();
    setState(() => _progressBarActive = false);

    // Print the duration in which file loads in memory
    Functions.printLoadingTime(dateStart: dateS, dateEnd: dateE);
  }

  void _releaseResources() async {
    if (_mp != null) _mp.releasePlayer();
    _mp = null;
    if (_versesList != null && _versesList.length > 0) _versesList.clear();
    _versesList = null;
  }

  void printMessage(String msg) => print(TAG + msg);
}

/* -------------------- Unused Code ------------------------- */

//typedef void OnWidgetSizeChange(Size size);
//
//class MeasureSize extends StatefulWidget {
//  final Widget child;
//  final OnWidgetSizeChange onChange;
//
//  const MeasureSize({
//    Key key,
//    @required this.onChange,
//    @required this.child,
//  }) : super(key: key);
//
//  @override
//  _MeasureSizeState createState() => _MeasureSizeState();
//}
//
//class _MeasureSizeState extends State<MeasureSize> {
//  @override
//  Widget build(BuildContext context) {
//    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
//    return Container(
//      key: widgetKey,
//      child: widget.child,
//    );
//  }
//
//  var widgetKey = GlobalKey();
//  var oldSize;
//
//  void postFrameCallback(_) {
//    var context = widgetKey.currentContext;
//    if (context == null) return;
////    RenderBox _box = context.findRenderObject();
////    var yPosition = _box.localToGlobal(Offset.zero).dy;
//    var newSize = context.size;
//    if (oldSize == newSize) return;
//
//    oldSize = newSize;
//    widget.onChange(newSize);
//  }
//
//}

//double getFocusedVerse({int verseNo}) {
//  double sum = 0;
//  _tilesList.forEach((key, value) {
//    if (key < verseNo) {
//      sum += value;
//    }
//  });
//  return sum;
//}

//Function itemBuilder() {
//  //
//  final List<double> heights = new List<double>.generate(
//      527, (i) => Random().nextInt(200).toDouble() + 30.0);
//
//  return (BuildContext context, int index) {
//    //
//    return Card(
//      child: Container(
//        height: heights[index % 527],
//        color: (index == 0) ? Colors.red : Colors.green,
//        child: Center(child: Text('ITEM $index')),
//      ),
//    );
//  };
//}
