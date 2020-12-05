import AVFoundation
import Foundation

extension AudioGraphicsRenderer: Injectable { }
extension AudioManager: Injectable { }
extension Logger: Injectable { }

class DependencyManager {

    static var shared = DependencyManager()

    lazy var appController = AppController.shared
    lazy var audioFileManager = DocumentFileManager<AVAudioFile>(directoryName: "Audio")

    // Injectable
    lazy var logger = Logger.shared
    lazy var audioFileGraphicsRenderer = AudioGraphicsRenderer.shared
    lazy var audioManager = AudioManager(dependencyManager: self)

    init() {
        let resolver = Resolver.shared
        resolver.add(logger)
        resolver.add(audioFileGraphicsRenderer)
        resolver.add(audioManager)
    }
}
