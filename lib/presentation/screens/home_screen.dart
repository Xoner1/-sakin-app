import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/hive_database.dart';

import '../../services/permission_service.dart';

import 'adhkar_screen.dart';
import 'tasbih_screen.dart';

import 'package:intl/intl.dart';
import 'package:sakin_app/l10n/generated/app_localizations.dart';

import 'dart:async';
import 'package:sakin_app/models/adhan_model.dart';
import 'package:sakin_app/providers/adhan_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update UI every minute to refresh countdown
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });

    // Check for critical permissions (Xiaomi/Samsung)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    final permissionService = PermissionService();
    // 1. Check Standard Permissions
    final granted = await permissionService.requestNotificationPermissions();
    if (!granted && mounted) {
      // Optional: Show snackbar
    }

    // 2. Check Device Specific (Xiaomi/Samsung)
    if (await permissionService.hasPowerRestrictions()) {
      if (mounted) {
        _showPowerDialog(context, permissionService);
      }
    }
  }

  void _showPowerDialog(BuildContext context, PermissionService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ تنبيه هام'),
        content: const Text(
            'هاتفك (شاومي/سامسونج) قد يمنع الأذان من العمل في الخلفية.\n\n'
            'لضمان عمل الأذان 100%، يرجى تفعيل خيار:\n'
            'Show on Lock Screen (أو Autostart)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              service.openPowerSettings();
              Navigator.pop(ctx);
            },
            child: const Text('فتح الإعدادات',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدم AdhanProvider الجديد
    final adhanProvider = Provider.of<AdhanProvider>(context);
    final hiveDb = Provider.of<HiveDatabase>(context);
    final l10n = AppLocalizations.of(context)!;

    // الحصول على الأذان القادم
    final nextAdhan = adhanProvider.nextAdhan;
    final allAdhans = adhanProvider.getAdhanData(DateTime.now());

    // تحويل اسم الصلاة
    String prayerNameLocal = nextAdhan.title;

    // تنسيق وقت الصلاة القادم
    String nextTimeStr =
        DateFormat.jm(l10n.localeName).format(nextAdhan.startTime);

    // حساب الوقت المتبقي
    final remainingDuration = nextAdhan.startTime.difference(DateTime.now());

    // تنسيق الوقت المتبقي
    String remainingTimeStr = "";
    final hours = remainingDuration.inHours;
    final minutes = remainingDuration.inMinutes.remainder(60);
    final nf = NumberFormat.decimalPattern(l10n.localeName);

    if (hours > 0) {
      remainingTimeStr =
          "${nf.format(hours)} ${l10n.hour} ${l10n.and} ${nf.format(minutes)} ${l10n.minute}";
    } else {
      remainingTimeStr = "${nf.format(minutes)} ${l10n.minute}";
    }

    // Helper to format simple times
    String formatTime(DateTime? t) {
      if (t == null) return "--:--";
      return DateFormat.jm(l10n.localeName).format(t);
    }

    // استخراج أوقات السنة
    final midnightAdhan = allAdhans.firstWhere(
        (a) => a.type == adhanTypeMidnight,
        orElse: () => Adhan(
            type: -1,
            title: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            notifyBefore: 0,
            manualCorrection: 0,
            localCode: '',
            startingPrayerTime: DateTime.now(),
            shouldCorrect: false));
    final lastThirdAdhan = allAdhans.firstWhere(
        (a) => a.type == adhanTypeThirdNight,
        orElse: () => Adhan(
            type: -1,
            title: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            notifyBefore: 0,
            manualCorrection: 0,
            localCode: '',
            startingPrayerTime: DateTime.now(),
            shouldCorrect: false));

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.greeting,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.encouragement,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
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
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${l10n.nextPrayer}: $prayerNameLocal",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      nextTimeStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${l10n.timeLeft}: $remainingTimeStr",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // أوقات السنة (منتصف الليل والثلث الأخير)
              if (midnightAdhan.type != -1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSunnahTime(
                        l10n.midnight,
                        formatTime(midnightAdhan.startTime),
                        Icons.nightlight_round,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade200,
                      ),
                      _buildSunnahTime(
                        l10n.lastThird,
                        formatTime(lastThirdAdhan.startTime),
                        Icons.star_rate_rounded,
                      ),
                    ],
                  ),
                ),

              // أزرار سريعة
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.auto_stories,
                      label: l10n.adhkar,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdhkarScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.fingerprint,
                      label: l10n.tasbih,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasbihScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.todaysTasks,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      _showAddTaskDialog(context, hiveDb, l10n);
                    },
                  ),
                ],
              ),

              Expanded(
                child: hiveDb.tasks.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noTasksYet,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: hiveDb.tasks.length,
                        itemBuilder: (context, index) {
                          final task = hiveDb.tasks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task['isDone'],
                                activeColor: AppTheme.primaryColor,
                                onChanged: (val) {
                                  hiveDb.toggleTask(
                                    task['key'],
                                    task['isDone'],
                                  );
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
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
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

  Widget _buildSunnahTime(String label, String time, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(
    BuildContext context,
    HiveDatabase db,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addTask),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.taskName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                db.addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// زر إجراء سريع
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.grey.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
