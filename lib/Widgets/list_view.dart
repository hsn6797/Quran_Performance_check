import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/Widgets/verse_tile.dart';
import 'package:audioplayerdb/constants.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Listview extends StatelessWidget {
  final Function onTap;
  final Function onDoubleTap;
  final ItemScrollController itemScrollController;
  final currentSelectedVerse;
  final List<Verse> verseList;
  final QuranScript quranScript;

  Listview(List<Verse> verseList,
      {int currentSelectedVerse,
      QuranScript quranScript,
      this.onTap,
      this.onDoubleTap,
      this.itemScrollController})
      : this.verseList = verseList,
        this.quranScript = quranScript,
        this.currentSelectedVerse = currentSelectedVerse;

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemBuilder: (context, ind) {
//        print('List View: -------> $ind');
        Verse verse = verseList[ind];
//          double width = MediaQuery.of(context).size.width;
//          double height = MediaQuery.of(context).size.height;
//          printMessage(width.toString() + ' - ' + height.toString());

        return GestureDetector(
          onTap: () async => onTap(ind),
          onDoubleTap: onDoubleTap,
          child: VerseTile(
              verse: verse,
              ind: ind,
              currentSelectedVerse: currentSelectedVerse,
              quranScript: quranScript),
        );
      },
      itemCount: verseList.length,
      itemScrollController: itemScrollController,
      initialScrollIndex: currentSelectedVerse <= -1 ? 0 : currentSelectedVerse,
//      itemPositionsListener: _itemPositionsListener,
    );
  }
}
