package com.xoner1.sakin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * يستمع لحدثين:
 * 1. MY_PACKAGE_REPLACED → فور تحديث التطبيق من Play Store
 * 2. BOOT_COMPLETED      → فور إعادة تشغيل الجهاز
 *
 * يكتب علامة في SharedPreferences يقرأها Flutter عند الفتح
 * ليُعيد جدولة أذانات الصلاة تلقائيًا.
 */
class AppUpdateReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AppUpdateReceiver"

        // مكتبة shared_preferences في Flutter تستخدم هذا الاسم وهذه البادئة تحديدًا
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val KEY = "flutter.needs_reschedule_after_update"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        Log.i(TAG, "📡 حدث مستلم: $action")

        when (action) {
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_BOOT_COMPLETED -> markNeedsReschedule(context)
        }
    }

    private fun markNeedsReschedule(context: Context) {
        // نكتب في نفس ملف Flutter SharedPreferences حتى تقرأه مكتبة Dart
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean(KEY, true)
            .apply()
        Log.i(TAG, "✅ علامة إعادة الجدولة كُتبت في FlutterSharedPreferences (key=$KEY)")
    }
}
