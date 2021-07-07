import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dependancyManager = DependencyManager()
    lazy var appController = dependancyManager.appController

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        appController.toggleChannelOnRedundantVolumeIncrement(true)

        dependancyManager.logger.showSourceLocation = false

        #if targetEnvironment(simulator)
        let aUrl = Bundle.main.path(forResource: "OneTwoThreeFour_48000", ofType: "mp3")!
        let bUrl = Bundle.main.path(forResource: "Winstons - Amen, Brother", ofType: ".aif")!
        dependancyManager.audioManager.audioFilePlayer(channel: .a).loadAudioFile(url: URL(fileURLWithPath: aUrl))
        dependancyManager.audioManager.audioFilePlayer(channel: .b).loadAudioFile(url: URL(fileURLWithPath: bUrl))
        #endif

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
