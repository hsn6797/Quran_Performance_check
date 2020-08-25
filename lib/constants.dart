//  String URL =
import 'package:audioplayerdb/Models/chapter.dart';

////      'http://192.168.10.6:8888/PHP_Scripts/01.mp3';
////      'http://download.quranurdu.com/Al%20Quran%20with%20Urdu%20Translation%20By%20Mishari%20Bin%20Rashid%20Al%20Afasi/1%20Al%20Fatiha.mp3';
////      'http://quranapp.masstechnologist.com/01.mp3';
////      'https://luan.xyz/files/audio/ambient_c_motion.mp3';
//      'https://firebasestorage.googleapis.com/v0/b/quranpashto-5a040.appspot.com/o/mp3%2F001-Al-Fatiha-Ruku-01.mp3?alt=media&token=ba4b801b-dfc5-40b6-a1fc-2e04c0fc6721';

enum QuranScript { Arabic, Urdu, Arabic_Urdu, NONE }

class Constant {
  static const AudioFilesURL =
      'http://quranapp.masstechnologist.com/QuranAudio/';

  static const String SCRIPT = 'Only Arabic Script';

  static const List<String> OPTIONS = <String>[
    SCRIPT,
  ];

  static List<Chapter> CHAPTER_LIST;
}
