import 'dart:io';

import 'package:audioplayerdb/Helpers/FileHelper.dart';
import 'package:path/path.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audioplayerdb/constants.dart';

const String TAG = '{ MyPlayer }: ';

class MyPlayer {
  AudioPlayer _player;
  AudioPlayer get player => _player;

  MyPlayer() {
    AudioPlayer.setIosCategory(IosCategory.playback);
    _player = AudioPlayer();
    _player.setLoopMode(LoopMode.off);
  }

  Future<void> prepareAudioSource(String fileName) async {
    try {
      // if file not exists in storage.
//      Uri path = await getAudioUri(fileName: fileName);
      Uri path = await downloadFileFromInternet(fileName: fileName);
      print('Audio File Path To Play: -> {$path}');
      AudioSource source = AudioSource.uri(path);
      await _player.load(source);
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

  Future<void> seekToNewPosition(
      {Duration start, Duration end, bool continues = false}) async {
    // Return true if successfully seek to audio start position, false otherwise
    return !continues
        ? await player.setClip(start: start, end: end)
        : await player.seek(start);
  }

  Future<void> playAudio() async {
    return await player.play();
  }

  Future<void> stopAudio() async {
    return await player.stop();
  }

  Future<void> pauseAudio() async {
    return player.pause();
  }

  /// Return local audio file path Uri if exists
  /// otherwise returns audio file URL path Uri
  Future<Uri> downloadFileFromInternet({String fileName = ''}) async {
    FileHelper fh = FileHelper.instance;
    var downloadsDir = await fh.getApplicationDownloadsDirectory();
    File audioFile = File(
      join(
        downloadsDir.path,
        fileName,
      ),
    );

    if (await audioFile.exists()) {
      fh = null;
      return Uri.file(audioFile.path);
    } else {
      Uri url = Uri.parse(Constant.AudioFilesURL + fileName);
      print('Download URL: -> {$url}');
      if (await fh.download(url: url, destinationFile: audioFile)) {
        url = Uri.file(audioFile.path);
      }
      fh = null;
      return url;
    }
  }

  /// Return local audio file path Uri if exists
  /// otherwise returns audio file URL path Uri
  Future<Uri> getAudioUri({String fileName = ''}) async {
    FileHelper fh = FileHelper.instance;
    var downloadsDir = await fh.getApplicationDownloadsDirectory();
    File audioFile = File(
      join(
        downloadsDir.path,
        fileName,
      ),
    );
    fh = null;

    if (await audioFile.exists()) {
      return Uri.file(audioFile.path);
    } else {
      return Uri.parse(Constant.AudioFilesURL + fileName);
    }
  }

  void releasePlayer() async => await player.dispose();
}
