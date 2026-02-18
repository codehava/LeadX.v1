import Flutter
import UIKit
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register background task identifier for WorkManager
    WorkmanagerPlugin.registerTask(
      withIdentifier: "com.askrindo.leadx_crm.backgroundSync"
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
