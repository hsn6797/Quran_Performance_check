import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/constants.dart';
import 'package:flutter/material.dart';

class VerseTile extends StatelessWidget {
  const VerseTile({
    @required this.verse,
    @required this.ind,
    @required int currentSelectedVerse,
    @required QuranScript quranScript,
  })  : _currentSelectedVerse = currentSelectedVerse,
        _quranScript = quranScript;

  final Verse verse;
  final int _currentSelectedVerse;
  final int ind;
  final QuranScript _quranScript;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        child: ListTile(
          title: Padding(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
            child: Text(
              '${verse.arabic_text}',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'KFGQPC Uthman Taha Naskh',
                fontWeight: FontWeight.bold,
                wordSpacing: 8,
                letterSpacing: 0,
                color: _currentSelectedVerse == ind
                    ? Colors.blue
                    : Colors.blueGrey.shade900,
              ),
            ),
          ),
          subtitle: _quranScript == QuranScript.Arabic_Urdu
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14, top: 5, bottom: 5),
                  child: Text(
                    '${verse.urdu_text}',
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'noorehira',
                      wordSpacing: 8,
                      color: _currentSelectedVerse == ind
                          ? Colors.blue
                          : Colors.grey.shade800,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14, top: 5, bottom: 5),
                  child: Container(),
                ),
        ),
      ),
    );
  }
}
