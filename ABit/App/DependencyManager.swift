import AVFoundation
import Foundation

extension AudioGraphicsRenderer: Injectable { }
extension AudioManager: Injectable { }
extension Logger: Injectable { }
extension RedundantVolumeIncrementObserver: Injectable { }

class DependencyManager {

    lazy var appController = AppController()
    lazy var audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "PlayerConfiguration")

    // Injectable
    lazy var logger = Logger()
    lazy var audioFileGraphicsRenderer = AudioGraphicsRenderer()
    lazy var audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)
    lazy var redundantVolumeIncrementObserver = RedundantVolumeIncrementObserver()

    init() {
        let resolver = Resolver.shared
        resolver.add(logger)
        resolver.add(audioFileGraphicsRenderer)
        resolver.add(audioManager)
        resolver.add(redundantVolumeIncrementObserver)
    }
}
