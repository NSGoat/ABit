import AVFoundation

extension AVAudioPlayerNode {
    var currentTime: TimeInterval? {
        guard let nodeTime = lastRenderTime else { return nil }
        guard let playerTime = playerTime(forNodeTime: nodeTime) else { return nil }

        return Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
    }
}
