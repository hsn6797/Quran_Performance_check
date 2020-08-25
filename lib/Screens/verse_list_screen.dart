import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:audioplayerdb/Widgets/verse_tile.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:audioplayerdb/Widgets/list_view.dart';
import 'package:audioplayerdb/Utills/functions.dart';
import 'package:audioplayerdb/constants.dart';

import 'package:audioplayerdb/Helpers/FileHelper.dart';
import 'package:audioplayerdb/Helpers/shared_prefs.dart';
import 'package:audioplayerdb/Helpers/quran_helper.dart';
import 'package:audioplayerdb/Helpers/my_player.dart';

import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/Models/chapter.dart';

const TAG = 'Verse List Screen: ';

class VerseListScreen extends StatefulWidget {
  final int chapter_no;
  final String title;
  final List<RukuMapping> rukus;

  VerseListScreen({this.chapter_no, this.title, this.rukus});

  @override
  _VerseListScreenState createState() => _VerseListScreenState();
}

class _VerseListScreenState extends State<VerseListScreen>
    with WidgetsBindingObserver /*,SingleTickerProviderStateMixin*/ {
  MyPlayer _mp;
  List<Verse> _versesList = <Verse>[];

  ItemScrollController _itemScrollController;
//  ItemPositionsListener _itemPositionsListener;

//  bool _isplaying = false;
//  int _currentSelectedVerse = -1;
//  int _currentRukuNo = 0;
//  QuranScript _quranScript;
//  Icon _iconPlay = Icon(Icons.play_arrow);
//
//  bool _progressBarActive = false;
//  bool _isDownloading = false;

  bool _isplaying;
  int _currentSelectedVerse;
  int _currentRukuNo;
  QuranScript _quranScript;
  Icon _iconPlay;
  bool _progressBarActive;
  bool _isDownloading;
  bool _doubleTapfirstTime;

  static Directory _downloadsDir;

//  AnimationController animationController;
//  Animation<double> animation;

  /* ------------------ User Defined Methods ------------------ */

  void init() async {
    // ---- Initialize objects
    _mp = MyPlayer();
    _itemScrollController = ItemScrollController();
//    _itemPositionsListener = ItemPositionsListener.create();
    _isplaying = false;
    _currentRukuNo = 0;
    _iconPlay = Icon(Icons.play_arrow);

    _progressBarActive = false;
    _isDownloading = false;
    _currentSelectedVerse = -1;
    _doubleTapfirstTime = true;

    // - Load verses list
    await _loadVerses();
    // - Get the Script Value from Shared Preferences
    _quranScript = await CustomSharedPreferences.getQuranScript();
    // - Get the download directory in App Storage
    _downloadsDir = await FileHelper.instance.downloadsDir;

    // 2- Initialize Streams and Listeners
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
            await _letsGo(play: true);

//            // - Scroll to next verse
//            jumptoCurrentVerse();

//            if (_currentSelectedVerse > 0) {
//              _itemScrollController.jumpTo(index: _currentSelectedVerse);
//            }
          }
        }
      }
    });
//    _itemPositionsListener.itemPositions.addListener(() {});

//    animationController = AnimationController(
//      vsync: this,
//      duration: Duration(seconds: 2),
//    )
//      ..addListener(() => setState(() {}))
//      ..repeat();
//    animation = Tween<double>(
//      begin: 100.0,
//      end: 140.0,
//    ).animate(animationController);
//
//    animationController.forward();

    // - Load the first ruku audio

    await _letsGo();

    // get current verse from shared prefrences
    await getCurrentVerseFromSP();
  }

  void _releaseResources() async {
    if (_mp != null) _mp.releasePlayer();
    _mp = null;

    if (_versesList != null && _versesList.length >= 0) _versesList.clear();
    _versesList = null;

    _iconPlay = null;
    _itemScrollController = null;
//    _itemPositionsListener = null;
    _downloadsDir = null;
//    animationController.dispose();

    CustomSharedPreferences.setBookmark(
        widget.chapter_no, _currentSelectedVerse);
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

  Future<void> _setAudioPlayer() async {
    await _mp.prepareAudioSource(widget.rukus[_currentRukuNo].file_name);
  }

  Future<void> _letsGo({bool play = false, bool changedScript = false}) async {
    // - Select currently playing ruku
    var ruku = widget.rukus[_currentRukuNo];

    // - Check if the selected verse is not in the current ruku
    if ((_currentSelectedVerse + 1) < ruku.first_verse ||
        (_currentSelectedVerse + 1) > ruku.last_verse) {
      // - Change ruku number
      printMessage(
          'changing ruku {${_currentRukuNo + 1}} to ruku {${_currentRukuNo + 2}} ...');
      _changeCurrentRukuNo();

      setState(() => _isDownloading = true);
      // - Load new ruku AudioSource
      printMessage('setting up ruku {${_currentRukuNo + 1}} audio source...');
      await _setAudioPlayer();
      setState(() => _isDownloading = false);

      // - Start downloading next ruku audio file
      printMessage(
          'Ruku {${_currentRukuNo + 2}} audio downloading in background...');
      _startDownloadIsolate();
    }

    // Jump to current verse index
    jumptoCurrentVerse();

    if (play) {
      // Play the Verse
      printMessage(
          'Playing ruku {${_currentRukuNo + 1}} verse {${_currentSelectedVerse + 1}} ...');
      await _playVerse(
        _versesList[_currentSelectedVerse],
        continues: false,
      );
//      if (changedScript) await _mp.pauseAudio();
    }
  }

  Future _playVerse(Verse v, {bool continues = false}) async {
    if (_mp == null || _quranScript == QuranScript.NONE) return;
    if (_quranScript == QuranScript.Arabic_Urdu)
      await _mp.seekToNewPosition(
          start: v.arabic_start_time,
          end: v.urdu_end_time,
          continues: continues);
    else if (_quranScript == QuranScript.Arabic)
      await _mp.seekToNewPosition(
          start: v.arabic_start_time,
          end: v.arabic_end_time,
          continues: continues);
    else if (_quranScript == QuranScript.Urdu)
      await _mp.seekToNewPosition(
          start: v.urdu_start_time, end: v.urdu_end_time, continues: continues);

    await _mp.playAudio();
  }

  void jumptoCurrentVerse() {
    if (_currentSelectedVerse > -1)
      _itemScrollController.jumpTo(index: _currentSelectedVerse);
    else
      _itemScrollController.jumpTo(index: 0);
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

  void _changeCurrentRukuNo() {
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

  static _downloadRukuAudio(dynamic isolateToMainStream) async {
    final ReceivePort mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);

    final config = await mainToIsolateStream.first;
    print(config);

    File audioFile = File(
      join(config["downloadsDir"].toString(), config["fileName"].toString()),
    );
    FileHelper fh = FileHelper.instance;

    if (!await fh.downloadAudioFile(config["fileName"].toString(), audioFile)) {
      // if file is not downloaded successfully
      isolateToMainStream.send("Error");
    } else {
      isolateToMainStream.send("Done");
    }
  }

  _startDownloadIsolate() async {
    if (_currentRukuNo >= widget.rukus.length - 1) return;

    final ReceivePort isolateToMainStream = ReceivePort();
    Isolate _isolate =
        await Isolate.spawn(_downloadRukuAudio, isolateToMainStream.sendPort);

    isolateToMainStream.listen((dynamic data) {
      if (data is SendPort) {
        data.send({
          'fileName': widget.rukus[_currentRukuNo + 1].file_name,
          'downloadsDir': _downloadsDir.path,
        });
      } else {
        print('--------------- [isolateToMainStream] -> $data ---------------');
        if (data == 'Done') {
          isolateToMainStream.close();
          _isolate.kill(priority: Isolate.immediate);
          _isolate = null;
        } else if (data == 'Error') {
          // File not downloaded
        }
      }
    });
  }

  Future getCurrentVerseFromSP() async {
    String value = await CustomSharedPreferences.getBookmark();
    List<String> lis = Functions.splitString(value, "|");
    if (lis != null) {
      int chapter = int.parse(lis[0]);
      int verse = int.parse(lis[1]);
      if (chapter == widget.chapter_no) {
        _currentSelectedVerse = verse;
        // Jump to current verse index
        jumptoCurrentVerse();
        return;
      }
    }
    _currentSelectedVerse = -1;
  }

  void printMessage(String msg) => print(TAG + msg);

  /* ------------------ Methods use in Build Method ------------------ */
  Future tapOnTile(int ind) async {
    if (_progressBarActive || _isDownloading) return;
    setState(() {
      _iconPlay = Icon(Icons.pause);
      _currentSelectedVerse = ind;
    });

    // Check and change the ruku if needed and play

    await _letsGo(play: true);
  }

  Future doubleTapOnTile() async {
    if (_mp == null || _progressBarActive || _isDownloading) return;
//    _isplaying ? animationController.repeat() : animationController.reset();

    if (_isplaying) {
      setState(() => _iconPlay = Icon(Icons.play_arrow));
      await _mp.pauseAudio();
    } else {
      setState(() => _iconPlay = Icon(Icons.pause));
      // Check and change the ruku if needed and play
      if (_currentSelectedVerse == -1) {
        setState(() => _currentSelectedVerse = 0);
        await _letsGo(play: true);
      } else {
        if (_doubleTapfirstTime) {
          await _letsGo(play: true);
          _doubleTapfirstTime = false;
        } else {
          await _mp.playAudio();
        }
      }
    }
  }

  void changeQuranScriptValue() async {
    setState(() => _quranScript = _quranScript != QuranScript.Arabic
        ? QuranScript.Arabic
        : QuranScript.Arabic_Urdu);

    // - Save value to Cache
    CustomSharedPreferences.setQuranScript(_quranScript);

    if (_progressBarActive || _isDownloading) return;

    // - Play the verse
    if (_currentSelectedVerse > -1)
      await _letsGo(play: true, changedScript: true);

    // Jump to current verse index
    jumptoCurrentVerse();
  }

  // Menu list options
  void choiceAction(String value) {
    printMessage(value);
    if (value == Constant.SCRIPT) {
      // Change Quran Script
      changeQuranScriptValue();
    }
  }

  /* ------------------ Screen Lifecycle Methods ------------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
        actions: <Widget>[
          _isDownloading
              ? Center(
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : SizedBox(
                  width: 25,
                  height: 25,
                  child: IconButton(
                    icon: _iconPlay,
                  ),
                ),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constant.OPTIONS.map((e) {
                return PopupMenuItem<String>(
                  value: e,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(e),
                      SizedBox(
                        width: 50.0,
                      ),
                      Icon(
                        Icons.check,
                        color: _quranScript == QuranScript.Arabic
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
//          Listview(
//            _versesList,
//            currentSelectedVerse: _currentSelectedVerse,
//            quranScript: _quranScript,
//            itemScrollController: _itemScrollController,
//            onTap: tapOnTile,
//            onDoubleTap: doubleTapOnTile,
//          ),
          ScrollablePositionedList.builder(
            itemBuilder: (context, ind) {
              Verse verse = _versesList[ind];
//              double width = MediaQuery.of(context).size.width;
//              double height = MediaQuery.of(context).size.height;
//              printMessage(width.toString() + ' - ' + height.toString());
              return GestureDetector(
                onTap: () async {
                  if (_progressBarActive || _isDownloading) return;
                  await tapOnTile(ind);
                },
                onDoubleTap: () async {
                  if (_progressBarActive || _isDownloading) return;
                  doubleTapOnTile();
                },
                child: VerseTile(
                    verse: verse,
                    ind: ind,
                    currentSelectedVerse: _currentSelectedVerse,
                    quranScript: _quranScript),
              );
            },
            itemCount: _versesList.length,
            itemScrollController: _itemScrollController,
//            initialScrollIndex:
//                _currentSelectedVerse <= -1 ? 0 : _currentSelectedVerse,
//            itemPositionsListener: _itemPositionsListener,
          ),
//          Center(
//            child: !_isplaying
//                ? Icon(
//                    Icons.play_circle_filled,
//                    size: animation.value,
//                    color: Color(0x99757575),
//                  )
//                : SizedBox(),
//          ),
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
