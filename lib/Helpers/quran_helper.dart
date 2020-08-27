import 'package:audioplayerdb/Helpers/json_helper.dart';
import 'package:audioplayerdb/Models/chapter.dart';
import 'package:audioplayerdb/Models/verse.dart';
import 'package:audioplayerdb/constants.dart';

enum DatabaseType { SQL_LITE, JSON }

class QuranHelper {
//  static DatabaseHelper _dh;
  static JsonHelper _jh;

  // make this a singleton class
  QuranHelper._privateConstructor();
  static final QuranHelper instance = QuranHelper._privateConstructor();

  JsonHelper get jh {
    if (_jh != null) return _jh;
    // lazily instantiate the db the first time it is accessed
    _jh = JsonHelper();
    return _jh;
  }

//  DatabaseHelper get dh {
//    if (_dh != null) return _dh;
//    // lazily instantiate the db the first time it is accessed
//    _dh = DatabaseHelper.instance;
//    return _dh;
//  }

  Future<List<Chapter>> ChaptersList() async {
    JsonHelper helper = instance.jh;
    var jsonData = await helper.getAssetFileJson('Chapter.json');
    return jsonData != null ? Chapter.toObjectList(jsonData) : null;
  }

  Future<List<Verse>> ChapterVersesList(
      {DatabaseType databaseType = DatabaseType.JSON, int chapter_no}) async {
    // load from Json
    var jsonData =
        await instance.jh.getAssetFileJson('Verses/$chapter_no.json');
    return jsonData != null ? Verse.toObjectList(jsonData) : null;
  }

  Chapter GetChapterfromStaticList({int chapterNo = -1}) {
    if (Constant.CHAPTER_LIST != null) {
      try {
        return Constant.CHAPTER_LIST.firstWhere((chapter) {
          if (chapterNo != -1 && chapter.ind == chapterNo) {
            return true;
          } else
            return false;
        });
      } catch (err) {
        print(err.toString());
        return null;
      }
    } else {
      print("Chapters static list is empty");
      return null;
    }
  }
}
