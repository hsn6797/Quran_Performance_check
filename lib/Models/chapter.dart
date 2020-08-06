import 'package:audioplayerdb/Models/verse.dart';
import '../database_helper.dart';

enum City { MAKAH, MADINA }

class Chapter {
  int ind;
  String name;
  String english_name;
  String title;
  City city;
  int total_verses;
  List<RukuMapping> ruku_mapping;

//  List<Verse> verses;

//  static DatabaseHelper dh;

  Chapter(
      {this.ind,
      this.name,
      this.english_name,
      this.title,
      this.city,
      this.total_verses,
      this.ruku_mapping});

  bool isMaki() {
    if (city == City.MAKAH) return true;
    return false;
  }

  static City getCity(int isMaki) {
    if (isMaki == 1) return City.MAKAH;

    return City.MADINA;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'ind': ind,
      'name': name,
      'english_name': english_name,
      'title': title,
      'is_maki': isMaki() ? 1 : 0,
      'total_verses': total_verses,
      'ruku_mapping': ruku_mapping == null
          ? null
          : new List<dynamic>.from(ruku_mapping.map((x) => x.toJson()))
//      'verses': verses,
    };
//    if (chap_no != null) map['chap_no'] = chap_no;

    return map;
  }

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        ind: json['ind'],
        name: json['name'],
        english_name: json['english_name'],
        title: json['title'],
        city: getCity(json['is_maki']),
        total_verses: json['total_verses'],
        ruku_mapping: new List<RukuMapping>.from(
            json["ruku_mapping"].map((x) => RukuMapping.fromJson(x))),
      );

  static Future<List<Chapter>> toObjectList(var maps) async {
    // Convert the List<Map<String, dynamic> into a List<Verse>.
    return List.generate(maps.length, (index) {
      return Chapter.fromJson(maps[index]);
    });
  }
//  static Future<List<Chapter>> toObjectList(var maps) async {
//    // Convert the List<Map<String, dynamic> into a List<Verse>.
//    return List.generate(maps.length, (i) {
//      Chapter chap = Chapter();
//      chap.chap_no = int.parse(maps[i]['chap_no']);
//      chap.name = maps[i]['name'];
//      chap.english_name = maps[i]['english_name'];
//      chap.title = maps[i]['title'];
//      chap.city = getCity(maps[i]['city']);
//
//      return Chapter();
//    });
//  }

//  static Future<List<Chapter>> list(var maps) async {
//    // Convert the List<Map<String, dynamic> into a List<Verse>.
//    final List<Map<String, dynamic>> maps = await dh.queryAllRows();
//
//    return toObjectList(maps);
//  }
}

class RukuMapping {
  int first_verse;
  int last_verse;
  int total_verses;
  String file_name;

  RukuMapping(
      {this.first_verse, this.last_verse, this.total_verses, this.file_name});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'first_verse': first_verse,
      'last_verse': last_verse,
      'total_verses': total_verses,
      'file_name': file_name,
    };
    return map;
  }

  factory RukuMapping.fromJson(Map<String, dynamic> json) => RukuMapping(
        first_verse: json['first_verse'],
        last_verse: json['last_verse'],
        total_verses: json['total_verses'],
        file_name: json['file_name'],
      );
}
