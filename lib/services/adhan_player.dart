import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

import 'package:audio_session/audio_session.dart';

/// Service to play Adhan audio
class AdhanPlayer {
  static final AdhanPlayer _instance = AdhanPlayer._internal();
  factory AdhanPlayer() => _instance;
  AdhanPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// Play Adhan audio
  Future<void> playAdhan() async {
    try {
      if (_isPlaying) {
        // Stop currently playing Adhan first
        await stopAdhan();
      }

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.alarm,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientExclusive, // Exclusive focus
        androidWillPauseWhenDucked: true,
      ));

      // Ensure audio session is active to pause other apps
      if (await session.setActive(true)) {
        // Load Adhan file from assets
        await _player.setAsset('assets/audio/adhan.mp3');

        // Set volume to maximum
        await _player.setVolume(1.0);

        // Start playback
        _isPlaying = true;
        await _player.play();
      }
    } catch (e) {
      debugPrint('Error playing Adhan: $e');
    } finally {
      _isPlaying = false;
      // Release audio focus so other apps can resume
      final session = await AudioSession.instance;
      await session.setActive(false);
    }
  }

  /// Stop Adhan audio
  Future<void> stopAdhan() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping Adhan: $e');
    }
  }

  /// Check playback status
  bool get isPlaying => _isPlaying;

  /// Dispose of audio resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
