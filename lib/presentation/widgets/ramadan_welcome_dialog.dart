import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme.dart';

class RamadanWelcomeDialog extends StatelessWidget {
  const RamadanWelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedMoon02,
              color: AppTheme.primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "رمضان مبارك 🌙",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Cairo', // Assuming Cairo is available
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "مبارك عليكم الشهر، وجعلنا الله وإياكم من صوامه وقوامه.\nنسأل الله أن يتقبل منكم صالح الأعمال.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "لا تنسونا من صالح دعائكم.",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "❤️", // Heart emoji
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              "أسرة تطبيق ساكن",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("تقبل الله منا ومنكم"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
