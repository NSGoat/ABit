import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dependancyManager = DependencyManager()
    lazy var appController = dependancyManager.appController

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        appController.toggleChannelOnRedundantVolumeIncrement(true)

        dependancyManager.logger.showSourceLocation = false

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        dependancyManager.audioManager.saveAllConfigurations()
    }
}
