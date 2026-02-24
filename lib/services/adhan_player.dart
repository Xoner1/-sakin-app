import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      // Reset the stop flag before playing
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stop_adhan_flag', false);

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

        // Start playing without awaiting its full completion here
        _player.play();

        // Polling loop: Wait for either the audio to finish natively OR the stop flag to be set
        while (_isPlaying &&
            _player.processingState != ProcessingState.completed) {
          final prefs = await SharedPreferences.getInstance();
          // Avoid aggressively hitting disk by keeping SharedPreferences instances cached,
          // but we reload to get updates from the other isolate
          await prefs.reload();
          final shouldStop = prefs.getBool('stop_adhan_flag') ?? false;

          if (shouldStop) {
            debugPrint(
                '🛑 Adhan interrupted by stop flag from another isolate.');
            await _player.stop();
            _isPlaying = false;
            break;
          }

          // Poll every 500 milliseconds
          await Future.delayed(const Duration(milliseconds: 500));
        }
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
      // Set the flag so the background isolate polling loop knows to stop
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stop_adhan_flag', true);

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
