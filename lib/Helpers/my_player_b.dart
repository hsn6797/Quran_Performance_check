import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

const String TAG = '{ MyPlayer }: ';

//enum PlayerStates { Playing, NotPlaying, Loading, Finished }

class MyPlayer {
//  Duration _startPosition;
//  Duration _endPosition;

//  PlayerStates _state;
//  PlayerStates get state => _state;

  AudioPlayer _player;
  AudioPlayer get player => _player;

  List<AudioSource> _playlist;

  MyPlayer(List<AudioSource> list) {
    if (Platform.isIOS) AudioPlayer.setIosCategory(IosCategory.playback);
    _player = AudioPlayer();
    _playlist = list;
    _loadAudio();

//    _player.playerStateStream.listen((playerState) {
//      final processingState = playerState?.processingState;
//      final playing = playerState?.playing;
//
//      if (processingState == ProcessingState.loading ||
//          processingState == ProcessingState.buffering) {
//        _state = PlayerStates.Loading;
//      } else if (playing != true) {
//        _state = PlayerStates.Play;
//      } else if (processingState != ProcessingState.completed) {
//        _state = PlayerStates.Pause;
//      } else {
//        _state = PlayerStates.Finished;
//      }
//    });
  }

  void _loadAudio() async {
    try {
      await _player.load(ConcatenatingAudioSource(children: _playlist));
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

//  AudioPlaybackState get status => player.sta;
//  Duration get startPosition => _startPosition;
//  set startPosition(Duration value) {
//    _startPosition = value;
//  }
//
//  Duration get endPosition => _endPosition;
//  set endPosition(Duration value) {
//    _endPosition = value;
//  }

  void releasePlayer() async => await player.dispose();

//  Future<Duration> setUpPlayer(String url) async {
//    return await player.setUrl(url);
//  }
//
//  Future<void> seekToNewPosition({continues = false}) async {
//    // Return true if successfully seek to audio start position, false otherwise
//    return !continues
//        ? await player.setClip(
//            start: this._startPosition, end: this._endPosition)
//        : await player.seek(this._startPosition);
//  }

  Future<void> playAudio() async {
    return await player.play();
  }

  Future<void> stopAudio() async {
    return await player.stop();
  }

  Future<void> pauseAudio() async {
    return player.pause();
  }

  static Future<File> _downloadAudioFile(
      {String url, File destinationFile}) async {
    try {
      final bytes = await readBytes(url);
      File f = await destinationFile.create(recursive: true);

      var fa = await f.open(mode: FileMode.write);
      File finalFile = await f.writeAsBytes(bytes);
      await fa.close();
      return finalFile;
    } catch (err) {
      print(err);
      return null;
    }
  }

  /// Get the url or path of audio file
  /// prams: url, download, filename
  /// check if file exists in phone storage return path
  /// if download = true downloads the file from url
  ///
  static Future<Uri> loadAudio(String url,
      {bool download = false, String fileName = ''}) async {
    var dir;

    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getExternalStorageDirectory();
    }

    File file = File('${dir.path}/Audio/$fileName');
    if (await file.exists() == false) {
      if (download) {
        File f1 = await _downloadAudioFile(
            url: url + fileName, destinationFile: file);
        if (f1 != null) return Uri.file(f1.path);
      } else {
        return Uri.parse(url + fileName);
      }
    } else {
      // File Exists in Phone Storage
      return Uri.file(file.path);
//      print('Already exists');
    }
  }
}
