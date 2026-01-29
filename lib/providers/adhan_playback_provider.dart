import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AdhanPlayBackProvider with ChangeNotifier {
  int playing = -1;
  final AudioPlayer _player = AudioPlayer();

  Future playBack(int notifyID) async {
    final res = playing == notifyID ? await stop() : await play(notifyID);
    playing = res ?? -1;
    notifyListeners();
  }

  Future<int?> play(int notifyID) async {
    try {
      await _player
          .setAsset('assets/audio/adhan.mp3'); // Ensure path is correct
      await _player.play();
      return notifyID;
    } catch (e) {
      debugPrint("Error playing adhan: $e");
      return -1;
    }
  }

  @override
  void dispose() {
    stop();
    _player.dispose();
    super.dispose();
  }

  Future<int?> stop() async {
    try {
      await _player.stop();
      return -1;
    } catch (e) {
      return -1;
    }
  }
}
