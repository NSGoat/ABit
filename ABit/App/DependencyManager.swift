import Foundation

class DependencyManager {
    private let audioManager = AudioManager()

    init() {
        let resolver = Resolver.shared
        resolver.add(audioManager)
    }
}
