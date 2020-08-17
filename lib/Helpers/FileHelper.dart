import 'dart:io';
import 'package:audioplayerdb/constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:http/http.dart' as http;

class FileHelper {
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
      print('Download URL: -> ${AudioFilesURL + fileName}');
      if (!await download(
          url: Uri.parse(AudioFilesURL + fileName),
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
      print('Download failed {Error Message}-> ${err.toString()}');
      return false;
    }
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
