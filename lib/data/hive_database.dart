import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase with ChangeNotifier {
  late Box _tasksBox;
  late Box _habitsBox;

  List<Map<dynamic, dynamic>> _tasks = [];

  // لتهيئة البيانات عند الفتح
  Future<void> init() async {
    // تهيئة Hive قبل فتح الصناديق
    await Hive.initFlutter();
    _tasksBox = await Hive.openBox('tasks');
    _habitsBox = await Hive.openBox('habits');
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _tasksBox.keys.map((key) {
      final item = _tasksBox.get(key);
      return {"key": key, "title": item['title'], "isDone": item['isDone']};
    }).toList();
    notifyListeners();
  }

  List<Map<dynamic, dynamic>> get tasks => _tasks;

  // إضافة مهمة
  Future<void> addTask(String title) async {
    await _tasksBox.add({"title": title, "isDone": false});
    _loadTasks();
  }

  // حذف مهمة
  Future<void> deleteTask(int key) async {
    await _tasksBox.delete(key);
    _loadTasks();
  }

  // تبديل حالة المهمة
  Future<void> toggleTask(int key, bool currentVal) async {
    final item = _tasksBox.get(key);
    item['isDone'] = !currentVal;
    await _tasksBox.put(key, item);
    _loadTasks();
  }

  // العادات (الصلاة) - مفتاح اليوم + اسم الصلاة
  bool getHabitStatus(String prayerName) {
    // المفتاح يكون مثل: 2024-01-26_Fajr
    final today = DateTime.now().toString().split(' ')[0];
    final key = "${today}_$prayerName";
    return _habitsBox.get(key, defaultValue: false);
  }

  Future<void> toggleHabit(String prayerName) async {
    final today = DateTime.now().toString().split(' ')[0];
    final key = "${today}_$prayerName";
    final current = getHabitStatus(prayerName);
    await _habitsBox.put(key, !current);
    notifyListeners();
  }
}
