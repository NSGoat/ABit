import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    @Inject var audioManager: AudioManager

    var window: UIWindow?

    lazy var contentView = ContentView(audioManager: audioManager)

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()

        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }

        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 480, height: 580)
        #endif
    }
}
