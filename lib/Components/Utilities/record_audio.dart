import 'dart:async';
import 'dart:io';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

class RecordAudio {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  String _filePath = '';
  bool _isPlaying = false;
  bool _isPaused = false;
  late Timer recordingTimer;
  Duration recordingDuration = Duration.zero;

  final BehaviorSubject<void> _playerFinishedStream = BehaviorSubject<void>();
  final BehaviorSubject<Duration> _positionStream = BehaviorSubject<Duration>();
  final BehaviorSubject<Duration> _recordingDurationStream = BehaviorSubject<Duration>();

  Stream<void> get onPlayerFinished => _playerFinishedStream.stream;
  Stream<Duration> get onPositionChanged => _positionStream.stream;
  Stream<Duration> get onRecordingDurationChanged => _recordingDurationStream.stream;


  Future<bool> init() async {
    var status = await Permission.microphone.request();
    if (status == PermissionStatus.denied) {
      InAppNotifications.show(
          description: 'Microphone needs to be enabled to record audio',
          onTap: () {}
      );
    } else if (status == PermissionStatus.permanentlyDenied) {
      InAppNotifications.show(
          description: 'Microphone permission is permanently denied. Please go to settings and enable it manually, or click this prompt',
          onTap: () {
            openAppSettings();
          }
      );
    } else if (status == PermissionStatus.granted) {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      return true;
    }
    return false;
  }

  Future<String> startAudioRecording() async {
    //Each audio recording would be saved in the format e.g. audio_20240619_143500.aac
    if (!_isRecorderInitialized) {
      throw Exception("Recorder is not initialized");
    }

    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';
    await Directory(dirPath).create(recursive: true);  // Create directory if it doesn't exist

    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    _filePath = 'audio_$timestamp.aac';

    await _recorder.startRecorder(
      toFile: '$dirPath/$_filePath',
      codec: Codec.aacADTS,
    );

    startRecordingTimer();

    return _filePath;
  }

  Future<void> stopAudioRecording(bool isAbruptStop) async {
    if (!_isRecorderInitialized) {
      throw Exception("Recorder is not initialized");
    }
    await _recorder.stopRecorder();
    stopRecordingTimer(isAbruptStop);
  }

  void startRecordingTimer() {
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration += const Duration(seconds: 1);
      _recordingDurationStream.add(recordingDuration);
    });
  }

  void stopRecordingTimer(bool isAbruptStop) {
    recordingTimer.cancel();
    if(isAbruptStop){
      recordingDuration = Duration.zero;
    }
    _recordingDurationStream.add(recordingDuration);
  }

  Future<void> openPlayer() async {
    await _player.openPlayer();
    _isPlayerInitialized = true;
  }

  Future<void> playAudioRecordingPlayback(String fileName) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';

    if (!_isPlayerInitialized) {
      await openPlayer();
    }
    if (_isPaused) {
      await _player.resumePlayer();
      _isPaused = false;
    } else {
      await _player.setSubscriptionDuration(const Duration(milliseconds: 100));
      await _player.startPlayer(
        fromURI: '$dirPath/$fileName',
        codec: Codec.aacADTS,
        whenFinished: () {
          _isPlaying = false;
          _playerFinishedStream.add(null);
          _player.closePlayer();
        },
      );
      _player.onProgress!.listen((event) {
        _positionStream.add(event.position);
      });
    }
    _isPlaying = true;
  }

  Future<void> stopAudioRecordingPlayback() async {
    _isPlaying = false;
    _playerFinishedStream.add(null);
    await _player.stopPlayer();
  }

  Future<void> pauseAudioRecording() async {
    if (_isPlaying && !_isPaused) {
      await _player.pausePlayer();
      _isPaused = true;
      _isPlaying = false;
    }
  }

  Future<void> deleteAudioRecording(String fileName) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';

    if (fileName.isEmpty) {
      throw Exception("File path is not set");
    }
    final file = File('$dirPath/$fileName');
    if (await file.exists()) {
      await file.delete();
      _recordingDurationStream.add(Duration.zero);
      recordingDuration = Duration.zero;
    } else {
      throw Exception("File does not exist");
    }
  }

  Future<void> seekingAudioPlayback(Duration duration) async {
    _player.seekToPlayer(Duration.zero);
    _positionStream.add(Duration.zero);
  }

  Future<void> dispose() async {
    _playerFinishedStream.close();
    _recordingDurationStream.close();
    _positionStream.close();
  }
}

// class PlayAudio {
//   // Singleton instance
//   static final PlayAudio _instance = PlayAudio._internal();
//
//   // Private constructor
//   PlayAudio._internal();
//
//   // Factory constructor to return the same instance
//   factory PlayAudio() {
//     return _instance;
//   }
//
//   // Map to hold AudioPlayer instances
//   final Map<String, AudioPlayer> _players = {};
//   final _playbackCompleteController = StreamController<void>.broadcast();
//
//   Stream<void> get playbackCompleteStream => _playbackCompleteController.stream;
//
//   Stream<Duration> get positionStream {
//     // Only provide position stream of the currently active player, if any
//     if (_players.isNotEmpty) {
//       return _players.values.first.positionStream;
//     } else {
//       return Stream.value(Duration.zero); // Default value when no players are active
//     }
//   }
//
//   Future<void> playVoiceNote(String fileName) async {
//     print('current audio $fileName');
//
//     // // Check if the player already exists for the fileName
//     // if (_players.containsKey(fileName)) {
//     //   final existingPlayer = _players[fileName];
//     //   if (existingPlayer != null) {
//     //     await existingPlayer.stop();
//     //     existingPlayer.dispose();
//     //     _players.remove(fileName);
//     //   }
//     // }
//
//     // Stop and dispose all current players
//     for (var player in _players.values) {
//       print('old player: $player');
//       await player.stop();
//       print(player.playing);
//       // player.dispose();
//     }
//     // _players.clear();
//
//     Directory? appDocDirectory = await getExternalStorageDirectory();
//     String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';
//     final player = AudioPlayer();
//     _players[fileName] = player;
//     print('all players: $_players');
//
//     player.playerStateStream.asBroadcastStream().listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         _playbackCompleteController.add(null);
//         _players.remove(fileName);
//         player.dispose();
//       }
//     });
//     print('all players two: $_players');
//
//     await player.setUrl('$dirPath/$fileName');
//     await player.play();
//   }
//
//   Future<void> pauseVoiceNote(String? fileName) async {
//     final player = _players[fileName];
//     if (player != null) {
//       await player.pause();
//     }
//   }
//
//   Future<void> resumeVoiceNote(String? fileName) async {
//     final player = _players[fileName];
//     if (player != null) {
//       await player.play();
//     }
//   }
//
//   Future<void> seekToPosition(String? fileName, Duration position) async {
//     final player = _players[fileName];
//     if (player != null) {
//       await player.seek(position);
//     }
//   }
//
//   void dispose() {
//     for (var player in _players.values) {
//       player.dispose();
//     }
//     _players.clear();
//     _playbackCompleteController.close();
//   }
// }



// class PlayAudio {
//   final Map<String, AudioPlayer> _players = {};
//   final _playbackCompleteController = StreamController<void>();
//
//   PlayAudio() {
//     // No need to listen to player state changes in the constructor anymore
//   }
//
//   Stream<void> get playbackCompleteStream => _playbackCompleteController.stream;
//
//   Stream<Duration> get positionStream {
//     // Combining position streams from all players (for demonstration purposes)
//     return Stream.periodic(Duration(milliseconds: 200)).asyncMap((_) {
//       return Future.wait(
//           _players.values.map((player) => player.positionStream.first));
//     }).map((positions) => positions.reduce((a, b) => a + b));
//   }
//
//   Future<void> playVoiceNote(String fileName) async {
//     // Stop and dispose all current players
//     for (var player in _players.values) {
//       await player.stop();
//       player.dispose();
//     }
//     _players.clear();
//
//     Directory? appDocDirectory = await getExternalStorageDirectory();
//     String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';
//     final player = AudioPlayer();
//     _players[fileName] = player;
//
//     player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         _playbackCompleteController.add(null);
//       }
//     });
//
//     await player.setUrl('$dirPath/$fileName');
//     await player.play();
//   }
//
//   Future<void> pauseVoiceNote(String? fileName) async {
//     final player = _players[fileName];
//     if (player != null) {
//       await player.pause();
//     }
//   }
//
//   Future<void> resumeVoiceNote(String? fileName) async {
//     final player = _players[fileName];
//     if (player != null) {
//       await player.play();
//     }
//   }
//
//   Future<void> seekToPosition(String? fileName, Duration position) async {
//     final player = _players[fileName];
//     if (player != null) {
//       await player.seek(position);
//     }
//   }
//
//   void dispose() {
//     for (var player in _players.values) {
//       player.dispose();
//     }
//     _players.clear();
//     _playbackCompleteController.close();
//   }
// }

// class PlayAudio {
//   // Singleton instance
//   static final PlayAudio _instance = PlayAudio._internal();
//
//   // Factory constructor to return the same instance
//   factory PlayAudio() {
//     return _instance;
//   }
//   // Private constructor
//   PlayAudio._internal() {
//     player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         _playbackCompleteController.add(null);
//       }
//     });
//   }
//
//   // Audio player instance
//   final AudioPlayer player = AudioPlayer();
//
//   // Stream controller to notify playback completion
//   final _playbackCompleteController = StreamController<void>.broadcast();
//
//   // Getter for playback complete stream
//   Stream<void> get playbackCompleteStream => _playbackCompleteController.stream;
//
//   // Getter for position stream
//   Stream<Duration> get positionStream => player.positionStream;
//
//   // Method to play a voice note
//   Future<void> playVoiceNote(String fileName) async {
//     Directory? appDocDirectory = await getExternalStorageDirectory();
//     String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';
//     await player.setUrl('$dirPath/$fileName');
//     await player.play();
//   }
//
//   // Method to pause playback
//   Future<void> pauseVoiceNote() async {
//     await player.pause();
//   }
//
//   // Method to resume playback
//   Future<void> resumeVoiceNote() async {
//     await player.play();
//   }
//
//   // Method to seek to a specific position
//   Future<void> seekToPosition(Duration position) async {
//     await player.seek(position);
//   }
//
//   // Dispose resources
//   void dispose() {
//     player.dispose();
//     _playbackCompleteController.close();
//   }
// }

class PlayAudio {
  final player = AudioPlayer();
  final _playbackCompleteController = StreamController<void>();

  PlayAudio() {
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playbackCompleteController.add(null);
      }
    });
  }

  Stream<void> get playbackVoiceNoteCompleteStream => _playbackCompleteController.stream;

  Stream<Duration> get positionVoiceNoteStream => player.positionStream;

  Future<void> playVoiceNote(String fileName) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';
    await player.setUrl('$dirPath/$fileName');
    await player.play();
  }

  Future<void> pauseVoiceNote() async {
    await player.pause();
  }

  Future<void> resumeVoiceNote() async {
    await player.play();
  }

  Future<void> stopVoiceNote() async {
    await player.stop();
  }

  Future<void> seekToPosition(Duration position) async {
    await player.seek(position);
  }

  void dispose() {
    player.dispose();
    _playbackCompleteController.close();
  }
}
