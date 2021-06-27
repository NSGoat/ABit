import AVFoundation
import Foundation

extension AudioGraphicsRenderer: Injectable { }
extension AudioManager: Injectable { }
extension Logger: Injectable { }

class DependencyManager {

    static var shared = DependencyManager()

    lazy var appController = AppController.shared
    lazy var audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "PlayerConfiguration")

    // Injectable
    lazy var logger = Logger.shared
    lazy var audioFileGraphicsRenderer = AudioGraphicsRenderer.shared
    lazy var audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)

    init() {
        let resolver = Resolver.shared
        resolver.add(logger)
        resolver.add(audioFileGraphicsRenderer)
        resolver.add(audioManager)
    }
}
