import Foundation

extension AudioManager: Injectable { }
extension Logger: Injectable { }

class DependencyManager {

    init() {
        let resolver = Resolver.shared
        resolver.add(Logger.shared)
        resolver.add(AudioManager.shared)
    }
}
