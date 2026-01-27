import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/prayer_service.dart';
import '../../services/notification_service.dart';
import '../../data/hive_database.dart';
import 'package:adhan/adhan.dart'; // لاستخدام Prayer Enum

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerService = Provider.of<PrayerService>(context);
    final hiveDb = Provider.of<HiveDatabase>(context);
    final nextPrayer = prayerService.nextPrayer;

    // تحويل اسم الصلاة لعربي
    String prayerNameAr = "لا يوجد";
    if (nextPrayer != Prayer.none) {
      switch (nextPrayer) {
        case Prayer.fajr:
          prayerNameAr = "الفجر";
          break;
        case Prayer.dhuhr:
          prayerNameAr = "الظهر";
          break;
        case Prayer.asr:
          prayerNameAr = "العصر";
          break;
        case Prayer.maghrib:
          prayerNameAr = "المغرب";
          break;
        case Prayer.isha:
          prayerNameAr = "العشاء";
          break;
        default:
          prayerNameAr = "";
      }
    }

    String nextTimeStr = "";
    if (prayerService.prayerTimes != null && nextPrayer != Prayer.none) {
      final time = prayerService.prayerTimes!.timeForPrayer(nextPrayer);
      if (time != null) nextTimeStr = prayerService.getFormattedTime(time);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("السلام عليكم،",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("واصل عملك الجيد!",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  // زر اختبار الأذان
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 28),
                    tooltip: 'اختبار الأذان',
                    onPressed: () async {
                      await NotificationService.showPrayerNotificationWithAdhan(
                          "الفجر (اختبار)");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Card
              Container(
                width: double.infinity,
                height: 160,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      opacity: 0.15,
                      alignment: Alignment.centerRight,
                      fit: BoxFit.contain,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("الصلاة القادمة: $prayerNameAr",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(nextTimeStr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 5),
                        Text("متبقي: ${prayerService.getTimeRemaining()}",
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("مهام اليوم",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryColor),
                    onPressed: () {
                      _showAddTaskDialog(context, hiveDb);
                    },
                  )
                ],
              ),

              Expanded(
                child: hiveDb.tasks.isEmpty
                    ? const Center(
                        child: Text("لا توجد مهام بعد",
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: hiveDb.tasks.length,
                        itemBuilder: (context, index) {
                          final task = hiveDb.tasks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: Checkbox(
                                value: task['isDone'],
                                activeColor: AppTheme.primaryColor,
                                onChanged: (val) {
                                  hiveDb.toggleTask(
                                      task['key'], task['isDone']);
                                },
                              ),
                              title: Text(
                                task['title'],
                                style: TextStyle(
                                  decoration: task['isDone']
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task['isDone']
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () => hiveDb.deleteTask(task['key']),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, HiveDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة مهمة"),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "اسم المهمة")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                db.addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("حفظ", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
