package com.shiftsync.shiftsync

import android.content.pm.ApplicationInfo
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Native device-integrity checks for anti-fraud (Phase 2).
 *
 * Exposed to Dart via MethodChannel `com.shiftsync.shiftsync/integrity`.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.shiftsync.shiftsync/integrity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isRooted" -> result.success(isRooted())
                    "isEmulator" -> result.success(isEmulator())
                    "isDeveloperMode" -> result.success(isDeveloperMode())
                    "isJailbroken" -> result.success(false) // Android-only
                    else -> result.notImplemented()
                }
            }
    }

    /** Heuristic root detection: su binary, test-keys, dangerous paths. */
    private fun isRooted(): Boolean {
        // 1) Build tags & debuggable flag
        val tags = Build.TAGS
        if (tags != null && tags.contains("test-keys")) return true

        // 2) Common su / Superuser binaries
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/magisk/.core/bin/su"
        )
        for (p in paths) {
            if (File(p).exists()) return true
        }

        // 3) which su
        try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val reader = process.inputStream.bufferedReader()
            val found = reader.readLine() != null
            process.destroy()
            if (found) return true
        } catch (_: Exception) {
            // ignore
        }

        // 4) Magisk / Xposed artifacts
        val magiskPaths = arrayOf(
            "/sbin/.magisk", "/sbin/.core/mirror", "/data/adb/magisk",
            "/data/adb/modules", "/system/framework/XposedBridge.jar"
        )
        for (p in magiskPaths) {
            if (File(p).exists()) return true
        }

        return false
    }

    /** Heuristic emulator detection. */
    private fun isEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT ?: ""
        val model = Build.MODEL ?: ""
        val manufacturer = Build.MANUFACTURER ?: ""
        val brand = Build.BRAND ?: ""
        val device = Build.DEVICE ?: ""
        val product = Build.PRODUCT ?: ""
        val hardware = Build.HARDWARE ?: ""

        return (fingerprint.startsWith("generic") ||
            fingerprint.startsWith("unknown") ||
            fingerprint.contains("generic") ||
            fingerprint.contains("vbox") ||
            fingerprint.contains("test-keys") ||
            model.contains("google_sdk") ||
            model.contains("Emulator") ||
            model.contains("Android SDK built for x86") ||
            manufacturer.contains("Genymotion") ||
            brand.startsWith("generic") ||
            brand.startsWith("vbox") ||
            device.startsWith("generic") ||
            product.contains("sdk") ||
            product.contains("emulator") ||
            product.contains("simulator") ||
            hardware.contains("goldfish") ||
            hardware.contains("ranchu") ||
            hardware.contains("vbox"))
    }

    private fun isDeveloperMode(): Boolean {
        return try {
            val dm = Settings.Global.getInt(
                contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
            )
            dm != 0
        } catch (_: Exception) {
            // Fallback: current app debuggable?
            (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        }
    }
}
