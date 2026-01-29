import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class MonthlyHeatMap extends StatelessWidget {
  final DateTime month;
  final int Function(DateTime) getCompletionCount;
  final Locale locale;

  const MonthlyHeatMap({
    super.key,
    required this.month,
    required this.getCompletionCount,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // حساب عدد الأيام في الشهر
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = (firstDayOfMonth.weekday % 7); // 0 = Sunday

    // اسم الشهر
    final monthName = DateFormat.MMMM(locale.languageCode).format(month);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$monthName ${month.year}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: daysInMonth + firstWeekday,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }

              final day = index - firstWeekday + 1;
              final date = DateTime(month.year, month.month, day);
              final count = getCompletionCount(date);
              final isToday = _isSameDay(date, DateTime.now());

              return Tooltip(
                message: "${date.day}/${date.month}: $count/5",
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColorForCount(count),
                    borderRadius: BorderRadius.circular(6),
                    border: isToday
                        ? Border.all(color: AppTheme.primaryColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontSize: 10,
                        color: count > 3 ? Colors.white : Colors.black54,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getColorForCount(int count) {
    if (count == 0) return Colors.grey.shade100;
    if (count <= 1) return AppTheme.primaryColor.withValues(alpha: 0.2);
    if (count <= 2) return AppTheme.primaryColor.withValues(alpha: 0.4);
    if (count <= 3) return AppTheme.primaryColor.withValues(alpha: 0.6);
    if (count <= 4) return AppTheme.primaryColor.withValues(alpha: 0.8);
    return AppTheme.primaryColor;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
