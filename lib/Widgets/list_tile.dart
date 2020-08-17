import 'package:audioplayerdb/Notifiers/main_notifier.dart';
import 'package:audioplayerdb/Screens/verse_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListviewTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int listPosition;

  final Function pressCallback;
  final Function longPressCallback;

  ListviewTile({
    @required this.title,
    this.subtitle,
    this.listPosition,
    this.pressCallback,
    this.longPressCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: longPressCallback,
      onTap: pressCallback,
      title: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 8),
        child: Text(
          title,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'KFGQPC Uthman Taha Naskh',
            fontWeight: FontWeight.bold,
            wordSpacing: 4,
            letterSpacing: 0,
            color: Provider.of<MainNotifier>(context).currentSelectedVerse ==
                    listPosition
                ? Colors.blue
                : Colors.blueGrey.shade900,
          ),
        ),
      ),
      subtitle: Provider.of<MainNotifier>(context).translation ==
              Translation.Arabic_Urdu
          ? Padding(
              padding: const EdgeInsets.only(
                  left: 14, right: 20, top: 8, bottom: 20),
              child: Text(
                subtitle,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 26,
//                            fontFamily: 'noorehira',
                  wordSpacing: 2,
                  color:
                      Provider.of<MainNotifier>(context).currentSelectedVerse ==
                              listPosition
                          ? Colors.blue
                          : Colors.grey.shade900,
                ),
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
            ),
    );
  }
}
