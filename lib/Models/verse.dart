import 'package:audioplayerdb/Utills/functions.dart';

class Verse {
  int ind;
  int chapter_no;
  int verse_no;
  String arabic_text;
  String urdu_text;

  Duration arabic_start_time;
  Duration arabic_end_time;
  Duration urdu_start_time;
  Duration urdu_end_time;

  Verse(
      {this.ind,
      this.chapter_no,
      this.verse_no,
      this.arabic_text,
      this.urdu_text,
      this.arabic_start_time,
      this.arabic_end_time,
      this.urdu_start_time,
      this.urdu_end_time}); //  static DatabaseHelper dh;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'ind': ind,
      'chapter_no': chapter_no,
      'verse_no': verse_no,
      'arabic_text': arabic_text,
      'urdu_text': urdu_text,
      'arabic_start_time': arabic_start_time.toString(),
      'arabic_end_time': arabic_end_time.toString(),
      'urdu_start_time': urdu_start_time.toString(),
      'urdu_end_time': urdu_end_time.toString(),
    };
    return map;
  }

  factory Verse.fromJson(Map<String, dynamic> json) => Verse(
        ind: json['ind'],
        chapter_no: json['chapter_no'],
        verse_no: json['verse_no'],
        arabic_text: json['arabic_text'],
        urdu_text: json['urdu_text'],
        arabic_start_time: Functions.parseDuration(json['arabic_start_time']),
        arabic_end_time: Functions.parseDuration(json['arabic_end_time']),
        urdu_start_time: Functions.parseDuration(json['urdu_start_time']),
        urdu_end_time: Functions.parseDuration(json['urdu_end_time']),
      );

  static Future<List<Verse>> toObjectList(var maps) async {
    // Convert the List<Map<String, dynamic> into a List<Verse>.
    return List.generate(maps.length, (index) {
      return Verse.fromJson(maps[index]);
    });
  }

//  static Future<List<Verse>> list() async {
//    if (dh == null) dh = DatabaseHelper.instance;
//    // Convert the List<Map<String, dynamic> into a List<Verse>.
//    final List<Map<String, dynamic>> maps = await dh.queryAllRows();
//    await dh.disposeDatabase();
//    dh = null;
//    return generateList(maps);
//  }

//  static generateList(var maps) {
//    return List.generate(maps.length, (i) {
//      Verse v = Verse();
//      v.ind = maps[i]['ind'];
//      v.chapter_no = maps[i]['chapter_no'];
//      v.verse_no = maps[i]['verse_no'];
//      v.arabic_text = maps[i]['arabic_text'];
//      v.urdu_text = maps[i]['urdu_text'];
//
//      v.arabic_start_time =  parseDuration(maps[i]['arabic_start_time']);
//      v.arabic_end_time =    parseDuration(maps[i]['arabic_end_time']);
//      v.urdu_start_time =    parseDuration(maps[i]['urdu_start_time']);
//      v.urdu_end_time =      parseDuration(maps[i]['urdu_end_time']);
//
//      return v;
//    });
//  }
}
