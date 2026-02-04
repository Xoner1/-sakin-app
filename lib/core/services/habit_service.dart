import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  static late SharedPreferences _prefs;
  static const String _keyHabits = 'user_habits_list';
  static const String _keyHeatmap = 'habits_heatmap_history';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- إدارة العادات ---

  static List<Map<String, dynamic>> loadHabits() {
    final String? jsonString = _prefs.getString(_keyHabits);
    if (jsonString == null) {
      // عادات افتراضية للبداية
      return [
        {
          'title': 'صلاة الفجر',
          'icon': 0,
          'completed': false
        }, // 0 indicates default icon logic
        {'title': 'ورد القرآن', 'icon': 1, 'completed': false},
      ];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  static Future<void> saveHabits(List<Map<String, dynamic>> habits) async {
    await _prefs.setString(_keyHabits, jsonEncode(habits));
    _updateTodayHeatmap(habits);
  }

  // --- إدارة الخريطة الحرارية (Heatmap) ---

  // يحسب نسبة الإنجاز لليوم ويحفظها في التاريخ الحالي
  static Future<void> _updateTodayHeatmap(
      List<Map<String, dynamic>> habits) async {
    if (habits.isEmpty) return;

    int completedCount = habits.where((h) => h['completed'] == true).length;
    double progress = completedCount / habits.length;

    // حفظ النسبة بتاريخ اليوم (YYYY-MM-DD)
    String todayKey = DateTime.now().toIso8601String().split('T')[0];
    Map<String, double> history = loadHeatmap();
    history[todayKey] = progress;

    await _prefs.setString(_keyHeatmap, jsonEncode(history));
  }

  static Map<String, double> loadHeatmap() {
    final String? jsonString = _prefs.getString(_keyHeatmap);
    if (jsonString == null) return {};
    Map<String, dynamic> decoded = jsonDecode(jsonString);
    // تحويل القيم إلى double لضمان السلامة
    return decoded
        .map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
}
