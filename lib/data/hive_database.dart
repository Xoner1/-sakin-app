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
  bool getHabitStatus(String prayerName, {DateTime? date}) {
    final d = date ?? DateTime.now();
    final dateStr = d.toString().split(' ')[0];
    final key = "${dateStr}_$prayerName";
    return _habitsBox.get(key, defaultValue: false);
  }

  // الحصول على عدد الصلوات المكتملة في يوم معين
  int getPrayersCountForDay(DateTime date) {
    final dateStr = date.toString().split(' ')[0];
    int count = 0;
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    for (var p in prayers) {
      if (_habitsBox.get("${dateStr}_$p", defaultValue: false)) {
        count++;
      }
    }
    return count;
  }

  Future<void> toggleHabit(String prayerName, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    final dateStr = d.toString().split(' ')[0];
    final key = "${dateStr}_$prayerName";
    final current = getHabitStatus(prayerName, date: d);
    await _habitsBox.put(key, !current);
    notifyListeners();
  }
}
