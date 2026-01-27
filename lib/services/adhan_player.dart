import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// خدمة تشغيل الأذان
class AdhanPlayer {
  static final AdhanPlayer _instance = AdhanPlayer._internal();
  factory AdhanPlayer() => _instance;
  AdhanPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// تشغيل الأذان
  Future<void> playAdhan() async {
    try {
      if (_isPlaying) {
        // إيقاف الأذان الحالي أولاً
        await stopAdhan();
      }

      // تحميل ملف الأذان من الأصول
      await _player.setAsset('assets/audio/adhan.mp3');

      // ضبط مستوى الصوت على الحد الأقصى
      await _player.setVolume(1.0);

      // تشغيل الأذان
      _isPlaying = true;
      await _player.play();

      // الاستماع لانتهاء التشغيل
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    } catch (e) {
      debugPrint('خطأ في تشغيل الأذان: $e');
      _isPlaying = false;
    }
  }

  /// إيقاف الأذان
  Future<void> stopAdhan() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('خطأ في إيقاف الأذان: $e');
    }
  }

  /// التحقق من حالة التشغيل
  bool get isPlaying => _isPlaying;

  /// تنظيف الموارد
  Future<void> dispose() async {
    await _player.dispose();
  }
}
