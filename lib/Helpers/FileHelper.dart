import 'dart:io';
import 'package:audioplayerdb/constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:http/http.dart' as http;

class FileHelper {
  // make this a singleton class
  FileHelper._privateConstructor();
  static final FileHelper instance = FileHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Directory _downloadsDir;

  Future<Directory> get downloadsDir async {
    if (_downloadsDir != null) return _downloadsDir;
    // lazily instantiate the db the first time it is accessed
    _downloadsDir = await _initFileHelper();
    return _downloadsDir;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initFileHelper() async {
    return await getApplicationDownloadsDirectory();
  }

  /// On iOS its return getApplicationSupportDirectory
  /// its may be like: /Volumes/User/me/Library/Application Support
  ///
  /// On Android getExternalStorageDirectory
  /// i.e: file:///storage/emulated/0/Android/data/com.example.example_app/files
  Future<Directory> _getApplicationDirectory() async {
    if (Platform.isIOS) {
      return await pathProvider.getApplicationSupportDirectory();
    } else {
      return await pathProvider.getExternalStorageDirectory();
    }
  }

  /// Return the full Downloads Folder path in App's directory
  Future<Directory> getApplicationDownloadsDirectory() async {
    var externalDirectory = await _getApplicationDirectory();
    var downloadFolder = Directory(
      path.join(
        externalDirectory.path,
        "Downloads",
      ),
    );

    // Create the downloads folder if not exist
    if (await downloadFolder.exists() == false)
      downloadFolder = await downloadFolder.create();
    return downloadFolder;
  }

  /// Return true if file successfully downloads to destination directory
  /// otherwise returns false
  Future<bool> download({Uri url, File destinationFile}) async {
    try {
      print('Download Started...');
      final bytes = await http.readBytes(url);
      print('Downloaded successfully.');
      await _writeFile(bytes, destinationFile);
      return true;
    } catch (err) {
      print('Download failed {Error Message}-> ${err.toString()}');
      return false;
    }
  }

  /// Return true if audio file already exists in storage
  /// or successfully downloaded
  /// otherwise returns false;
  Future<bool> downloadFileFromInternet({String fileName = ''}) async {
    var downloadsDir = await getApplicationDownloadsDirectory();
    File audioFile = File(
      path.join(
        downloadsDir.path,
        fileName,
      ),
    );

    if (await audioFile.exists()) {
      return true;
    } else {
      print('Download URL: -> ${Constant.AudioFilesURL + fileName}');
      if (!await download(
          url: Uri.parse(Constant.AudioFilesURL + fileName),
          destinationFile: audioFile)) {
        return false;
      }
      return true;
    }
  }

  /// Return true if file successfully downloads to destination directory
  /// otherwise returns false
  Future<bool> _writeFile(bytes, File destinationFile) async {
    try {
      print('saving downloaded file to app cache storage...');
      File f = await destinationFile.create(recursive: true);
      var fa = await f.open(mode: FileMode.write);
      await f.writeAsBytes(bytes);
      print('All done!!');
      await fa.close();
      return true;
    } catch (err) {
      print('Download failed {Error Message}-> ${err.toStringValue()}');
      return false;
    }
  }

  Future<bool> downloadAudioFile(String fileName, File audioFilePath) async {
    if (!await audioFilePath.exists()) {
      print('Download URL: -> ${Constant.AudioFilesURL + fileName}');
      if (await download(
          url: Uri.parse(Constant.AudioFilesURL + fileName),
          destinationFile: audioFilePath)) {
        return true;
      } else {
        return false;
      }
    }
    return true;

//    if (!await audioFile.exists()) {
//    print('Download URL: -> $Constant.AudioFilesURL$fileName');
//    print('File Path: -> ${audioFile.path}');
//
//    if (!await _download(
//    url: Uri.parse(Constant.AudioFilesURL + config["fileName"].toString()),
//    destinationFile: audioFile)) {}
//    }
  }

  /// Return local audio file path Uri if exists
  /// otherwise returns audio file URL path Uri
  Future<Uri> getAudioFileUri(String fileName, File audioFile) async {
    if (!await FileHelper.instance.downloadAudioFile(fileName, audioFile)) {
      return Uri.parse(Constant.AudioFilesURL + fileName);
    }
    return Uri.file(audioFile.path);
  }

//  Future<bool> downloadAudioFile({Uri url, File destinationFile}) async {
//    http.StreamedResponse response =
//        await http.Client().send(http.Request('GET', url));
//    print('Status Code: ${response.statusCode}');
//    int total = response.contentLength;
//    int received = 0;
//    var bytes = List();
//    response.stream.listen((value) {
//      bytes.addAll(value);
//      received += value.length;
//      print('$received/$total');
//    }).onDone(() async {
//      await _writeFile(bytes, destinationFile);
//      print('Download done-> ' + destinationFile.path);
//      return true;
//    });
//    return false;
//  }
}
