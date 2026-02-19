import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class RamadanMessagesService {
  static const String _boxName = 'ramadan_messages';
  static const String _lastScheduledKey = 'last_scheduled_date';

  // List of motivational/personal messages
  static const List<String> _messages = [
    "أخي/أختي.. لا تجعل هذا اليوم يمر دون قراءة صفحة من كتاب الله. والله إني أحب لك الخير.",
    "هل استثمرت دقائق الانتظار اليوم في ذكر الله؟ أنا وأنت في سباق إلى الجنة.. فلا تسبقني بالكسل!",
    "أسأل الله أن يتقبل صيامك ويغفر ذنبك.. لا تنسَ أن تدعو لنفسك ولمن تحب في هذه الساعات المباركة.",
    "جرب أن تغلق هاتفك لساعة وتخلو بربك.. ستجد راحة عجيبة. جربها الآن!",
    "رمضان فرصة للتغيير.. ابدأ اليوم بشيء واحد صغير تود تغييره في نفسك واستعن بالله.",
    "الصيام ليس فقط عن الطعام.. بل عن الكلام السيء والظنون السيئة. طهّر قلبك كما تطهر معدتك.",
    "هل تصدقت اليوم؟ ولو بابتسامة أو كلمة طيبة.. الصدقة تطفئ غضب الرب.",
    "الدعاء سهم لا يخطئ.. خصص وقتاً للدعاء بقلب خاشع، فالله قريب يجيب المضطر.",
    "لا تنسَ قيام الليل ولو بركعتين.. فهي شرف المؤمن ونور في الوجه.",
    "سامح من أخطأ في حقك اليوم.. ليعفو الله عنك. (وليعفوا وليصفحوا ألا تحبون أن يغفر الله لكم).",
    "اذكر الله في الغافلين.. كن مثل النخلة، أينما وقعت نفعت.",
    "جدد نيتك في كل عمل تقوم به.. حتى نومك اجعله تقوياً على طاعة الله.",
    "اقرأ تفسير آية واحدة اليوم.. القرآن رسالة من الله إليك، افهم ماذا يريد منك.",
    "صلة الرحم تزيد في الرزق والعمر.. اتصل بقريب لم تسمع صوته منذ فترة.",
    "استغفر الله للمؤمنين والمؤمنات.. فلك بكل واحد منهم حسنة!",
    "تفكر في خلق الله.. انظر للسماء، للشجر.. سبحان من أبدع هذا الكون.",
    "هل صليت على النبي ﷺ اليوم؟ إنها تكفيك همك وتغفر ذنبك.",
    "أطعم طعاماً.. ولو تمراً أو ماءً لصائم، فلك مثل أجره.",
    "احفظ لسانك.. فإنه أخطر جوارحك. قل خيراً أو اصمت.",
    "كن صاحب أثر.. ساعد محتاجاً، علم جاهلاً، أو واسِ حزيناً.",
    "لا تضيع وقتك في الجدال.. الصائم لا يرفث ولا يجهل.",
    "تذكر الموت.. فإنه هادم اللذات وموقظ الغفلات. ماذا أعددت له؟",
    "احمد الله على نعمة الإسلام.. ونعمة بلوغ رمضان. غيرك تحت التراب يتمنى ركعة.",
    "اجعل لك خبيئة من عمل صالح لا يعلمها إلا الله.. تكون نوراً لك في قبرك.",
    "ابتسم.. فبشرك في وجه أخيك صدقة، وهي تفتح القلوب المغلقة.",
    "لا تغضب.. الغضب جمرة من الشيطان تفسد الصيام.",
    "أحسن الظن بالله.. فالله عند ظن عبده به.",
    "كن مستغفراً بالأسحار.. وقت السحر وقت مبارك، لا تضيعه في النوم فقط.",
    "ادعُ لإخوانك المستضعفين في كل مكان.. فهم بحاجة لدعائك.",
    "اجتهد في العشر الأواخر.. فهي خلاصة الشهر وعتق من النيران."
  ];

  /// Checks if it is Ramadan and schedules a random message if not already scheduled for today.
  static Future<void> scheduleDailyMessage() async {
    final box = await Hive.openBox(_boxName);
    final lastScheduledStr = box.get(_lastScheduledKey);
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    // If already scheduled for today, skip
    if (lastScheduledStr == todayStr) {
      debugPrint("Ramadan message already scheduled for today.");
      return;
    }

    // Check if it's Ramadan using Hijri Calendar
    final hijriDate = HijriCalendar.now();
    // Month 9 is Ramadan
    if (hijriDate.hMonth != 9) {
      // Uncomment for testing if needed, or allow running outside Ramadan for verification
      // debugPrint("Not Ramadan. Skipping motivational message.");
      // return;
      // For now, to allow testing/demo, we might want to comment out this strict check
      // or make it an option. But per requirement, it's for Ramadan.
      // Let's implement strict check but log it.
      if (kDebugMode) {
        debugPrint(
            "Note: strict Ramadan check is active. Today is Hijri Month ${hijriDate.hMonth}.");
      }
      if (hijriDate.hMonth != 9) return;
    }

    // Schedule for today at a random time between 10 AM and 11 PM (23:00)
    // If it's already past 11 PM, schedule for tomorrow? No, just skip or try next time.
    // Let's say we check this on app open.
    // If now is before 10 AM -> schedule between 10 AM and 11 PM.
    // If now is between 10 AM and 11 PM -> schedule between now+10min and 11 PM.
    // If now is after 11 PM -> schedule for tomorrow 10 AM - 11 PM?
    // Simpler: Just pick a random time between 10:00 and 23:00.
    // If that time is in the past for today, schedule for tomorrow?
    // Actually, `zonedSchedule` with `matchDateTimeComponents` isn't needed here if we just want a one-off for "today" or "tomorrow".

    // Let's generate a random target time for TODAY.
    final random = Random();
    int randomHour = 10 + random.nextInt(14); // 10 to 23 (11 PM)
    int randomMinute = random.nextInt(60);

    var scheduledDate =
        DateTime(now.year, now.month, now.day, randomHour, randomMinute);

    // If the random time has already passed today, try to schedule for tomorrow?
    // Or if it's passed, just show it immediately/soon?
    // Let's say if passed, schedule for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final messageIndex = random.nextInt(_messages.length);
    final message = _messages[messageIndex];

    await _scheduleNotification(scheduledDate, message);

    await box.put(_lastScheduledKey,
        todayStr); // Mark knowing we attempted/scheduled for "this cycle"
    debugPrint("Scheduled Ramadan message for $scheduledDate: $message");
  }

  static Future<void> _scheduleNotification(
      DateTime scheduledDate, String message) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ramadan_messages_channel',
      'رسائل رمضانية',
      channelDescription: 'رسائل تحفيزية وتذكيرية خلال شهر رمضان',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(''), // Allows long text
    );

    // iOS details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      888, // Unique ID for daily message (replaces previous if distinct, but we want one pending)
      'رسالة من أخيك ❤️',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Checks if welcome dialog should be shown for the current Ramadan.
  static Future<bool> shouldShowWelcomeDialog() async {
    final hijriDate = HijriCalendar.now();
    // Only show during Ramadan
    if (hijriDate.hMonth != 9) {
      if (kDebugMode && hijriDate.hMonth == 8) {
        // Allow testing in Sha'ban if needed, or uncomment to test
        // return true;
      }
      return false;
    }

    final box = await Hive.openBox(_boxName);
    final key = 'ramadan_welcome_shown_${hijriDate.hYear}';
    final hasShown = box.get(key, defaultValue: false);

    return !hasShown;
  }

  /// Marks the welcome dialog as shown for the current year.
  static Future<void> markWelcomeDialogShown() async {
    final hijriDate = HijriCalendar.now();
    final box = await Hive.openBox(_boxName);
    final key = 'ramadan_welcome_shown_${hijriDate.hYear}';
    await box.put(key, true);
  }
}
