import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.shiftsync.shiftsync/integrity",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "isJailbroken":
          result(IntegrityChecker.isJailbroken())
        case "isEmulator":
          result(IntegrityChecker.isSimulator())
        case "isRooted":
          result(false) // iOS-only
        case "isDeveloperMode":
          result(false) // iOS-only
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Heuristic jailbreak / simulator detection for iOS.
enum IntegrityChecker {
  static func isJailbroken() -> Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    // 1) Common jailbreak file paths
    let paths = [
      "/Applications/Cydia.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/bin/bash",
      "/usr/sbin/sshd",
      "/etc/apt",
      "/private/var/lib/apt/",
      "/private/var/lib/cydia",
      "/private/var/stash",
      "/usr/bin/ssh",
      "/usr/libexec/sftp-server",
      "/Applications/FakeCarrier.app",
      "/Applications/SBSettings.app",
      "/Applications/WinterBoard.app",
      "/Applications/blackra1n.app",
      "/Applications/IntelliScreen.app",
      "/Applications/Snoop-itConfig.app",
      "/var/lib/cydia",
      "/var/cache/apt",
      "/var/lib/dpkg/info"
    ]
    for path in paths where FileManager.default.fileExists(atPath: path) {
      return true
    }

    // 2) Can we write outside the sandbox?
    let testPath = "/private/jailbreak_test.txt"
    do {
      try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
      try? FileManager.default.removeItem(atPath: testPath)
      return true
    } catch {
      // Expected on non-jailbroken devices
    }

    // 3) Can we open cydia:// URL scheme?
    if let url = URL(string: "cydia://package/com.example.package"),
       UIApplication.shared.canOpenURL(url) {
      return true
    }

    return false
    #endif
  }

  static func isSimulator() -> Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
  }
}
