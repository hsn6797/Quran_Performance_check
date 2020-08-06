import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Screens/verse_list_screen.dart';
import 'package:flutter/material.dart';

class RukuScreen extends StatefulWidget {
  final Chapter chapter;

  RukuScreen({this.chapter});

  @override
  _RukuScreenState createState() => _RukuScreenState();
}

class _RukuScreenState extends State<RukuScreen> with WidgetsBindingObserver {
  bool _progressBarActive = false;

  // Lifecycle Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('${widget.chapter.english_name} Rukus'),
      ),
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          ListView.builder(
            itemBuilder: (context, ind) {
              final ruku = widget.chapter.ruku_mapping[ind];
              return ListTile(
                onTap: () async {
                  // go to verses screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerseListScreen(
                        chapter_no: widget.chapter.ind,
                        ruku: ruku,
                        title: '${widget.chapter.english_name} Ruku ${ind + 1}',
                      ),
                    ),
                  );
                },
                title: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Ruku ${ind + 1}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Total Verses ${ruku.total_verses}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              );
            },
            itemCount: widget.chapter.ruku_mapping.length,
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Dispose Called!!');
    // Release the resources
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      print('App Resumed');
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      print('App Inactive');
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      print('App Paused');
    }
  }
}
