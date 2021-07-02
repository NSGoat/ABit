import class AVFoundation.AVAudioPlayerNode

extension AVAudioPlayerNode {

    @discardableResult
    func startEngineIfNeeded() -> Bool {
        guard let engine = engine else { return false }
        guard !engine.isRunning else { return true }

        return (try? engine.start()) != nil
    }
}
