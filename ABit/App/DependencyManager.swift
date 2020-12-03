import Foundation

extension AudioGraphicsRenderer: Injectable { }
extension AudioManager: Injectable { }
extension Logger: Injectable { }
extension SystemVolumeChangeListener: Injectable { }

class DependencyManager {

    lazy var appController = AppController.shared

    // Injectable
    lazy var logger = Logger.shared
    lazy var audioFileGraphicsRenderer = AudioGraphicsRenderer.shared
    lazy var audioManager = AudioManager.shared
    lazy var systemVolumeChangeListener = SystemVolumeChangeListener.shared

    init() {
        let resolver = Resolver.shared
        resolver.add(logger)
        resolver.add(audioFileGraphicsRenderer)
        resolver.add(audioManager)
        resolver.add(systemVolumeChangeListener)
    }
}
