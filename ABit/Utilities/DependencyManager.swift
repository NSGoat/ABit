import Foundation

extension AudioFileGraphicsRenderer: Injectable { }
extension AudioManager: Injectable { }
extension Logger: Injectable { }

class DependencyManager {

    lazy var logger = Logger.shared
    lazy var audioFileGraphicsRenderer = AudioFileGraphicsRenderer.shared
    lazy var audioManager = AudioManager.shared

    init() {
        let resolver = Resolver.shared
        resolver.add(logger)
        resolver.add(audioFileGraphicsRenderer)
        resolver.add(audioManager)
    }
}
