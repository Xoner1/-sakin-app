# Sakin App | تطبيق ساكن 🕌 🚀

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Android 15](https://img.shields.io/badge/Android-15-green?style=flat&logo=android)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)

**Sakin** is a modern, stable, and minimalist Flutter application designed to be your daily spiritual companion. Built with a focus on privacy, sincerity, and offline stability.

**تطبيق ساكن** هو تطبيق عصري، مستقر، وبسيط؛ صُمم ليكون رفيقك الإيماني اليومي. تم بناؤه بتركيز كامل على الخصوصية، المصداقية، والاستقرار حتى بدون اتصال بالإنترنت.

---

## 🌟 Why Sakin? | لماذا تطبيق ساكن؟
لقد قمنا ببناء "ساكن" واضعين المصداقية والشفافية كقيم أساسية لنا:
- **Zero Ads & Tracking**: Privacy focused and ad-free. It stores all data locally using Hive.
- **Verified Content**: Carefully calculated prayer times and authenticated Adhkar.
- **Android 15 Optimized**: Smooth performance on the latest APIs (API 35) with stable background services.

---

## ✨ Features | المميزات الحالية
- ✅ **Smart Prayer Times**: Real-time updates with offline caching.
- ✅ **Adhan System**: Full background audio support even on latest Android APIs.
- ✅ **Daily Tracking**: Track your prayers and habits with a beautiful monthly view.
- ✅ **Qiam-ul-Layl**: Dedicated timings for Midnight and the Last Third of the night.
- ✅ **Multi-language**: Support for Arabic, English, and French.

- ✅ **مواقيت ذكية**: تحديث لحظي مع خاصية الحفظ للعمل بدون إنترنت.
- ✅ **نظام الأذان**: دعم كامل للصوت في الخلفية حتى على أحدث الأنظمة.
- ✅ **تتبع يومي**: تتبع صلواتك وعاداتك مع عرض إحصائيات شهرية جذابة.
- ✅ **قيام الليل**: مواقيت خاصة لمنتصف الليل والثلث الأخير.
- ✅ **لغات متعددة**: دعم اللغات العربية، الإنجليزية، والفرنسية.

---

## 📸 Screenshots | لقطات من التطبيق
<p align="center">
  <img src="screenshots/Screenshot_2026-01-30-17-12-18-647_com.example.sakin_app.jpg" width="200" />
  <img src="screenshots/Screenshot_2026-01-30-17-12-26-936_com.example.sakin_app.jpg" width="200" />
  <img src="screenshots/Screenshot_2026-01-30-17-12-22-584_com.example.sakin_app.jpg" width="200" />
</p>

---

## 📂 Project Structure | هيكلية المشروع

Sakin follows a clean and modular architecture for performance and maintainability:

- **`lib/`**: Core source code.
  - **`main.dart`**: Entry point.
  - **`core/`**: Application-wide themes ([theme.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/core/theme.dart)).
  - **`data/`**: Data persistence layer ([hive_database.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/data/hive_database.dart)).
  - **`models/`**: Data objects (e.g., [adhan_model.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/models/adhan_model.dart), [location_info.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/models/location_info.dart)).
  - **`presentation/`**: UI components.
    - **`screens/`**: Pages like [home_screen.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/presentation/screens/home_screen.dart), [prayer_times_screen.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/presentation/screens/prayer_times_screen.dart), and [adhkar_screen.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/presentation/screens/adhkar_screen.dart).
    - **`widgets/`**: Reusable components.
  - **`providers/`**: State management ([adhan_provider.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/providers/adhan_provider.dart)).
  - **`services/`**: Business logic.
    - [notification_service.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/services/notification_service.dart): Alarms and notifications.
    - [background_service_new.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/services/background_service_new.dart): Background tasks.
    - [location_service.dart](file:///Users/fakhreddinefarhat/sakin_final/sakin_app/lib/services/location_service.dart): Location/GPS features.
  - **`utils/`**: Utilities and extensions.

---

## 🚀 Road to Play Store | الطريق إلى متجر جوجل
We are working hard to fulfill all requirements to publish **Sakin** on the **Google Play Store** very soon, Insha'Allah.

---

## 🤝 Open Source & License
This project is licensed under the **GNU GPL v3**. We welcome contributions from developers worldwide to improve and audit the code.
هذا المشروع مرخص بموجب **GNU GPL v3**. نرحب بمساهمات المبرمجين من جميع أنحاء العالم لتحسين وتدقيق الكود.

---

## 📢 Feedback | تواصل معنا
📧 **Email**: [fakhr.farhat@gmail.com](mailto:fakhr.farhat@gmail.com)
💬 **WhatsApp**: [+216 94 380 416](https://wa.me/21694380416)
📸 **Instagram**: [@fd_farhat](https://instagram.com/fd_farhat)