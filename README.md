# Sakin App | تطبيق ساكن 🕌 🚀

![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B.svg?style=flat&logo=Flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-12%2B-green?style=flat&logo=android)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)

**Sakin** is a modern, privacy-focused Islamic lifestyle application built with Flutter. It is designed to be a sincere spiritual companion, offering accurate prayer times, ad-free experience, and complete offline functionality.

**تطبيق ساكن** هو رفيقك المؤمن العصري. صُمم ليكون تطبيقاً صادقاً، خالياً من الإعلانات، ويعمل بكفاءة تامة دون الحاجة للإنترنت، مع تركيز كامل على الخصوصية وتحسين استهلاك البطارية.

---

## 🌟 Why Sakin? | لماذا ساكن؟

We believe spiritual apps should be distractions-free. Sakin is built on three core pillars:
1.  **Privacy First**: No data collection, no tracking. Everything stays on your device (Hive DB).
2.  **Battery Efficient**: Uses **Exact Alarms** instead of battery-draining background services. The app wakes up only when needed.
3.  **Modern Design**: A beautiful, "Sage Green" aesthetic with Dark Mode support and glassmorphism elements.

---

## ✨ Key Features | المميزات الرئيسية

### 🕒 Smart Prayer Times & Adhan
- **Exact Calculation**: High-precision prayer times based on your location.
- **Background Adhan**: Full-screen Adhan notification that works perfectly even when the app is closed, using Android's exact alarm API.
- **Manual Adjustments**: Fine-tune times for each prayer individually to match your local mosque.

### 🔋 Optimized Performance
- **Zero Background Drain**: The new engine removes persistent background services, relying on system alarms to save battery life.
- **Offline First**: All data is cached locally.

### 🎨 Beautiful UI/UX
- **Redesigned Interface**: A clean, modern dashboard with squares and glassmorphism effects.
- **Dark Mode**: Fully supported dark theme for comfortable night usage.
- **Monthly Heatmap**: Track your prayer habits visually over the month.

### 📿 Digital Tasbih & Adhkar
- **Smart Counter**: Haptic feedback and auto-save for your daily Dhikr.
- **Adhkar Library**: Authentic morning and evening Adhkar.

---

## 📸 Screenshots | لقطات الشاشة

### 🌙 Dark Mode | الوضع الليلي
<p align="center">
  <img src="screenshots/Screenshot_2026-02-04-19-05-44-598_com.example.sakin_app.jpg" width="200" alt="Home Light" style="border-radius: 10px; margin: 5px;" />
  <img src="screenshots/Screenshot_2026-02-04-19-05-57-660_com.example.sakin_app.jpg" width="200" alt="Detail Light" style="border-radius: 10px; margin: 5px;" />
  <img src="screenshots/Screenshot_2026-02-04-19-06-04-860_com.example.sakin_app.jpg" width="200" alt="Settings Light" style="border-radius: 10px; margin: 5px;" />
  <img src="screenshots/Screenshot_2026-02-04-19-06-07-844_com.example.sakin_app.jpg" width="200" alt="Tasbih Light" style="border-radius: 10px; margin: 5px;" />
</p>

### ☀️ Light Mode | الوضع النهاري
<p align="center">
  <img src="screenshots/Screenshot_2026-02-04-19-08-17-272_com.example.sakin_app.jpg" width="200" alt="Home Dark" style="border-radius: 10px; margin: 5px;" />
  <img src="screenshots/Screenshot_2026-02-04-19-08-21-498_com.example.sakin_app.jpg" width="200" alt="Detail Dark" style="border-radius: 10px; margin: 5px;" />
  <img src="screenshots/Screenshot_2026-02-04-19-08-26-276_com.example.sakin_app.jpg" width="200" alt="Settings Dark" style="border-radius: 10px; margin: 5px;" />
  <img src="screenshots/Screenshot_2026-02-04-19-08-29-003_com.example.sakin_app.jpg" width="200" alt="Tasbih Dark" style="border-radius: 10px; margin: 5px;" />
</p>

---

## 🛠 Tech Stack | التقنيات المستخدمة

- **Framework**: Flutter (Dart)
- **State Management**: Provider & Bloc (Cubit)
- **Local Database**: Hive (NoSQL, Fast & Secure)
- **Background Execution**: `android_alarm_manager_plus` & `flutter_local_notifications`
- **Location**: `geolocator` & `geocoding`
- **Audio**: `just_audio`

---

## 📂 Project Structure | هيكلية المشروع

The project follows a **Clean Architecture** approach to ensure scalability and maintainability:

```
lib/
├── business_logic/   # State Management (Cubits)
├── core/             # Core Utilities, Themes, and Constants
├── data/             # Repositories & Hive Database implementation
├── models/           # Dart Data Models
├── presentation/     # UI Layer (Screens & Widgets)
├── services/         # Services (Notification, Alarm, Location)
└── main.dart         # Entry Point
```

---

## 🚀 Getting Started | التشغيل

To build and run this project locally:

1.  **Prerequisites**:
    - Flutter SDK `3.16+`
    - Android Studio / VS Code

2.  **Clone & Install**:
    ```bash
    git clone https://github.com/your-username/sakin_app.git
    cd sakin_app
    flutter pub get
    ```

3.  **Run Code Generation** (important for Hive):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run App**:
    ```bash
    flutter run
    ```

---

## 🤝 Contribution | المساهمة

We welcome contributions! This project is open-source to benefit the Ummah.
- **Code Style**: Please use English for all code comments and commit messages.
- **Architecture**: Stick to the existing folder structure and Clean Architecture principles.

---

## 📞 Contact | تواصل معنا

Developed with ❤️ by **Fakhreddine Farhat**.

- 📧 Email: [fakhr.farhat@gmail.com](mailto:fakhr.farhat@gmail.com)
- 📸 Instagram: [@fd_farhat](https://instagram.com/fd_farhat)
- 💬 WhatsApp: [+216 94 380 416](https://wa.me/21694380416)

---
*License: GNU GPL v3*