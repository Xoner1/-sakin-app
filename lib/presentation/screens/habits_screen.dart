import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/hive_database.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<HiveDatabase>(context);
    final prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    final prayersAr = ["الفجر", "الظهر", "العصر", "المغرب", "العشاء"];

    return Scaffold(
      appBar: AppBar(title: const Text("تتبع الصلوات")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Text("هل صليت اليوم؟",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(prayers.length, (index) {
                      final isDone = db.getHabitStatus(prayers[index]);
                      return GestureDetector(
                        onTap: () => db.toggleHabit(prayers[index]),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade200,
                                border: isDone
                                    ? null
                                    : Border.all(color: Colors.grey),
                              ),
                              child: Icon(Icons.check,
                                  color: isDone ? Colors.white : Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            Text(prayersAr[index],
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for charts
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 50, color: Colors.grey),
                    Text("إحصائيات الأسبوع قريباً",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
