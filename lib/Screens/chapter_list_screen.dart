import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Helpers/quran_helper.dart';
import 'package:audioplayerdb/Screens/verse_list_screen.dart';
import 'package:audioplayerdb/Utills/functions.dart';
import 'package:flutter/material.dart';

class ChapterListScreen extends StatefulWidget {
  @override
  _ChapterListScreenState createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen>
    with WidgetsBindingObserver {
  List<Chapter> _chaptersList = [];
  QuranHelper _qh;
  bool _progressBarActive = false;

  /* ------------------ Screen Lifecycle Methods ------------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('All Suras'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            ListView.builder(
              itemBuilder: (context, ind) {
                final chapter = _chaptersList[ind];
                return ListTile(
                  onTap: () {
                    if (_progressBarActive) return;
                    // Go to verses list screen
                    Functions.changeScreen(
                      context,
                      screen: VerseListScreen(
                        chapter_no: chapter.ind,
                        rukus: chapter.ruku_mapping,
                        title: '${chapter.english_name}',
                      ),
                    );
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, bottom: 0, left: 4, right: 4),
                        child: Text(
                          '(${chapter.ind})  ${chapter.english_name}',
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 22.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, bottom: 0, left: 4, right: 4),
                        child: Text(
                          '(${chapter.ind})     ${chapter.name}',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontFamily: 'noorehira',
//                          fontFamily: 'KFGQPC Uthman Taha Naskh',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            wordSpacing: 0,
                            letterSpacing: 0.5,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 2, bottom: 0, left: 4, right: 4),
                        child: Text(
                          'Total Aayas ${chapter.total_verses}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 2, bottom: 0, left: 4, right: 4),
                        child: Text(
                          'Total Rukus ${chapter.ruku_mapping.length}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                    ],
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('Init Called!!');

//    get all chapters list
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Dispose Called!!');
    _releaseResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
//      this.init();
      print('App Resumed');
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
//      releaseResources();

      print('App Inactive');
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
//      releaseResources();

      print('App Paused');
    }
  }

/* ------------------ User Defined Methods ------------------ */
  void init() async {
    // Load all chapters list
    await _loadChapters();
  }

  Future<void> _loadChapters() async {
    _qh = QuranHelper.instance;

    setState(() => _progressBarActive = true);
    var dateS = DateTime.now();

    //fetch list from JSON File
    _chaptersList = await _qh.ChaptersList();

    var dateE = DateTime.now();
    setState(() => _progressBarActive = false);

    Functions.printLoadingTime(dateStart: dateS, dateEnd: dateE);

    _qh = null;
  }

  void _releaseResources() {
    if (_chaptersList != null && _chaptersList.length == 0)
      _chaptersList.clear();
    _qh = null;
  }
}
