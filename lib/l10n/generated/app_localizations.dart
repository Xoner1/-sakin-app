import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @general.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get general;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التطبيق'**
  String get appVersion;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @supplication.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسونا من صالح دعائكم'**
  String get supplication;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @adhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get adhkar;

  /// No description provided for @habits.
  ///
  /// In ar, this message translates to:
  /// **'العادات'**
  String get habits;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @changeLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم،'**
  String get greeting;

  /// No description provided for @encouragement.
  ///
  /// In ar, this message translates to:
  /// **'واصل عملك الجيد!'**
  String get encouragement;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// No description provided for @timeLeft.
  ///
  /// In ar, this message translates to:
  /// **'متبقي'**
  String get timeLeft;

  /// No description provided for @midnight.
  ///
  /// In ar, this message translates to:
  /// **'منتصف الليل'**
  String get midnight;

  /// No description provided for @lastThird.
  ///
  /// In ar, this message translates to:
  /// **'الثلث الأخير'**
  String get lastThird;

  /// No description provided for @tasbih.
  ///
  /// In ar, this message translates to:
  /// **'المسبحة'**
  String get tasbih;

  /// No description provided for @todaysTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get todaysTasks;

  /// No description provided for @noTasksYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام بعد'**
  String get noTasksYet;

  /// No description provided for @addTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة'**
  String get addTask;

  /// No description provided for @taskName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المهمة'**
  String get taskName;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @hour.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minute;

  /// No description provided for @imsak.
  ///
  /// In ar, this message translates to:
  /// **'الإمساك'**
  String get imsak;

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get isha;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد'**
  String get none;

  /// No description provided for @and.
  ///
  /// In ar, this message translates to:
  /// **'و'**
  String get and;

  /// No description provided for @dailyTracking.
  ///
  /// In ar, this message translates to:
  /// **'تتبع صلوات اليوم'**
  String get dailyTracking;

  /// No description provided for @monthlyStats.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات الشهرية'**
  String get monthlyStats;

  /// No description provided for @prayerTracking.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الصلوات'**
  String get prayerTracking;

  /// No description provided for @ignoreBatteryOptimization.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل تحسين البطارية'**
  String get ignoreBatteryOptimization;

  /// No description provided for @batteryOptimized.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل - الأذان يعمل بدقة'**
  String get batteryOptimized;

  /// No description provided for @batteryRestricted.
  ///
  /// In ar, this message translates to:
  /// **'غير مفعّل - قد يتأخر الأذان'**
  String get batteryRestricted;

  /// No description provided for @habitLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الالتزام'**
  String get habitLog;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @addHabit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عادة'**
  String get addHabit;

  /// No description provided for @editHabit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العادة'**
  String get editHabit;

  /// No description provided for @habitName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العادة'**
  String get habitName;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف العادة؟'**
  String get deleteHabitTitle;

  /// No description provided for @deleteHabitConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟'**
  String get deleteHabitConfirmation;

  /// No description provided for @achievementBoard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الإنجاز'**
  String get achievementBoard;

  /// No description provided for @smallSteps.
  ///
  /// In ar, this message translates to:
  /// **'خطواتك الصغيرة تصنع فرقاً كبيراً'**
  String get smallSteps;

  /// No description provided for @updatingLocation.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديث الموقع...'**
  String get updatingLocation;

  /// No description provided for @changeLocation.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الموقع'**
  String get changeLocation;

  /// No description provided for @locationChangeDetected.
  ///
  /// In ar, this message translates to:
  /// **'تم اكتشاف تغيير كبير في الموقع ولديك تعديلات يدوية محفوظة.\nهل تريد الاحتفاظ بها للموقع الجديد أم إعادة ضبطها؟'**
  String get locationChangeDetected;

  /// No description provided for @keep.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ'**
  String get keep;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التعديلات'**
  String get reset;

  /// No description provided for @locationUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الموقع والمواقيت بنجاح'**
  String get locationUpdatedSuccess;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

  /// No description provided for @refreshLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع'**
  String get refreshLocation;

  /// No description provided for @refreshing.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحديث...'**
  String get refreshing;

  /// No description provided for @mosqueTimeSync.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة وقت المسجد'**
  String get mosqueTimeSync;

  /// No description provided for @mosqueTimeSyncDesc.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الضغط على أي صلاة لتخصيص وقت الأذان (تقديم أو تأخير) ليتطابق مع أذان المسجد القريب منك.'**
  String get mosqueTimeSyncDesc;

  /// No description provided for @adjustTime.
  ///
  /// In ar, this message translates to:
  /// **'تعديل وقت {prayerName}'**
  String adjustTime(String prayerName);

  /// No description provided for @adjustTimeDesc.
  ///
  /// In ar, this message translates to:
  /// **'تقديم أو تأخير الوقت بالدقائق'**
  String get adjustTimeDesc;

  /// No description provided for @monthAchievement.
  ///
  /// In ar, this message translates to:
  /// **'إنجاز الشهر'**
  String get monthAchievement;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get days;

  /// No description provided for @currentStreak.
  ///
  /// In ar, this message translates to:
  /// **'السلسلة الحالية'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In ar, this message translates to:
  /// **'أفضل سلسلة'**
  String get bestStreak;

  /// No description provided for @successRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل النجاح'**
  String get successRate;

  /// No description provided for @sun.
  ///
  /// In ar, this message translates to:
  /// **'أ'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In ar, this message translates to:
  /// **'خ'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In ar, this message translates to:
  /// **'ج'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In ar, this message translates to:
  /// **'ح'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In ar, this message translates to:
  /// **'س'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In ar, this message translates to:
  /// **'ن'**
  String get sat;

  /// No description provided for @january.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get january;

  /// No description provided for @february.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get february;

  /// No description provided for @march.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get march;

  /// No description provided for @april.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get april;

  /// No description provided for @may.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get may;

  /// No description provided for @june.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get june;

  /// No description provided for @july.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get july;

  /// No description provided for @august.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get august;

  /// No description provided for @september.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get september;

  /// No description provided for @october.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get october;

  /// No description provided for @november.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get november;

  /// No description provided for @december.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get december;

  /// No description provided for @selectLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختر الموقع'**
  String get selectLocation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
