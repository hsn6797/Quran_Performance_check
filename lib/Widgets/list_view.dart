import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/Notifiers/main_notifier.dart';
import 'package:audioplayerdb/Widgets/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Listview extends StatelessWidget {
  final Function onPress;
  final Function onLongPress;
  final ScrollController controller;
  Listview({this.onPress, this.onLongPress, this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainNotifier>(
      builder: (context, mainNotifier, child) {
        return ListView.builder(
          itemBuilder: (context, ind) {
            Verse verse = mainNotifier.versesList[ind];
            return ListviewTile(
              title: verse.arabic_text,
              subtitle: verse.urdu_text,
              listPosition: ind,
              pressCallback: onPress(ind),
              longPressCallback: onLongPress,
            );
          },
          itemCount: mainNotifier.versesCount,
          controller: controller,
        );
      },
    );
  }
}

//ListView(
//children: <Widget>[
//ListviewTile(
//title: 'Google',
//subtitle: 'hsn6797@gmail.com',
//pressCallback: () {
//// Show the bottom sheet to enter new tasks
//showModalBottomSheet(
//context: context,
//isScrollControlled: true,
//builder: (context) => SingleChildScrollView(
//child: Container(
//padding: EdgeInsets.only(
//bottom: MediaQuery.of(context).viewInsets.bottom),
//child: DisplayScreen(),
//),
//),
//);
//},
//longPressCallback: null,
//),
//ListviewTile(
//title: 'Hotmail',
//subtitle: 'hsn6797@hotmail.com',
//pressCallback: null,
//longPressCallback: null,
//),
//ListviewTile(
//title: 'Yahoo',
//subtitle: 'hsn6797@yahoo.com',
//pressCallback: null,
//longPressCallback: null,
//),
//],
//);
