import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dependancyManager = DependencyManager()
    lazy var appController = dependancyManager.appController

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        appController.toggleChannelOnRedundantVolumeIncrement(true)

        dependancyManager.logger.showSourceLocation = false

        setupDemoTracks()

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

extension AppDelegate {
    func setupDemoTracks() {
        if loadDemoAudioA {
            let path = Bundle.main.path(forResource: "OneTwoThreeFour_48000", ofType: "mp3")!
            dependancyManager.audioManager.audioFilePlayer(channel: .a).loadAudioFile(url: URL(fileURLWithPath: path))
        }

        if loadDemoAudioB {
            let path = Bundle.main.path(forResource: "Winstons - Amen, Brother", ofType: ".aif")!
            dependancyManager.audioManager.audioFilePlayer(channel: .b).loadAudioFile(url: URL(fileURLWithPath: path))
        }
    }

    var loadDemoAudioA: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return CommandLine.arguments.contains("-loadPlayerA")
        #endif
    }

    var loadDemoAudioB: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return CommandLine.arguments.contains("-loadPlayerB")
        #endif
    }
}


