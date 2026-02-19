import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../models/prayer_offsets.dart';
import '../../services/alarm_service.dart';
import '../../services/prayer_service.dart';
import '../../core/theme.dart';

class PrayerAdjustmentDialog extends StatefulWidget {
  const PrayerAdjustmentDialog({super.key});

  @override
  State<PrayerAdjustmentDialog> createState() => _PrayerAdjustmentDialogState();
}

class _PrayerAdjustmentDialogState extends State<PrayerAdjustmentDialog> {
  late PrayerOffsets _offsets;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffsets();
  }

  Future<void> _loadOffsets() async {
    final box = await Hive.openBox('settings');
    final data = box.get('prayer_offsets');
    setState(() {
      _offsets = data != null
          ? PrayerOffsets.fromJson(Map<String, dynamic>.from(data))
          : PrayerOffsets();
      _isLoading = false;
    });
  }

  Future<void> _saveOffsets() async {
    final box = await Hive.openBox('settings');
    await box.put('prayer_offsets', _offsets.toJson());

    // Reschedule all alarms
    await PrayerAlarmScheduler.schedulePrayerAlarms();

    if (mounted) {
      // Refresh UI services
      Provider.of<PrayerService>(context, listen: false).calculatePrayers();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: const Text(
        'تعديل مواقيت الصلاة',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOffsetItem('الفجر', Prayer.fajr, _offsets.fajr, (val) {
              setState(() => _offsets = _offsets.copyWith(fajr: val));
            }),
            _buildOffsetItem('الظهر', Prayer.dhuhr, _offsets.dhuhr, (val) {
              setState(() => _offsets = _offsets.copyWith(dhuhr: val));
            }),
            _buildOffsetItem('العصر', Prayer.asr, _offsets.asr, (val) {
              setState(() => _offsets = _offsets.copyWith(asr: val));
            }),
            _buildOffsetItem('المغرب', Prayer.maghrib, _offsets.maghrib, (val) {
              setState(() => _offsets = _offsets.copyWith(maghrib: val));
            }),
            _buildOffsetItem('العشاء', Prayer.isha, _offsets.isha, (val) {
              setState(() => _offsets = _offsets.copyWith(isha: val));
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _saveOffsets,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  Widget _buildOffsetItem(
      String name, Prayer prayer, int value, Function(int) onChanged) {
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final rawTime = prayerService.prayerTimes?.timeForPrayer(prayer);
    final adjustedTime = rawTime?.add(Duration(minutes: value));
    final formattedTime =
        adjustedTime != null ? DateFormat.jm().format(adjustedTime) : '--:--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(formattedTime,
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.redAccent),
                onPressed: () => onChanged(value - 1),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value > 0 ? "+" : ""}$value دقيقة',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
