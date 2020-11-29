import AVFoundation

struct Playhead {
    let time: TimeInterval
    var position: Double
}

class AudioFilePlayerPlayheadTracker {

    private var playhead: Playhead?

    private let audioFilePlayer: AudioFilePlayer

    private var playheadUpdateTimer: Timer?

    init(audioFilePlayer: AudioFilePlayer) {
        self.audioFilePlayer = audioFilePlayer
    }

    @discardableResult
    func startTracking(withTimeInterval timeInterval: TimeInterval, block: @escaping (Playhead?) -> Void) -> Playhead? {
        playheadUpdateTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            if let audioFile = self.audioFilePlayer.audioFile,
               let playheadTime = self.playheadTime(audioFile: audioFile,
                                                    audioPlayerNode: self.audioFilePlayer.audioPlayerNode,
                                                    looping: self.audioFilePlayer.loop,
                                                    playPositionRange: self.audioFilePlayer.playPositionRange) {

                self.playhead = Playhead(time: playheadTime, position: playheadTime / audioFile.duration)
            } else {
                self.playhead = nil
            }

            block(self.playhead)
        }

        return playhead
    }

    func stopTracking() {
        playheadUpdateTimer?.invalidate()
        playheadUpdateTimer = nil
    }

    private func playheadTime(audioFile: AVAudioFile,
                              audioPlayerNode: AVAudioPlayerNode,
                              looping: Bool,
                              playPositionRange: ClosedRange<Double>) -> TimeInterval? {

        guard let playerTime = audioPlayerNode.currentTime else { return nil }

        if looping || playPositionRange.size < 1 {
            let fileDuration = audioFile.duration
            let loopStartTime = playPositionRange.lowerBound * fileDuration
            let loopDuration = playPositionRange.size * fileDuration
            let currentTimeInLoop = playerTime.truncatingRemainder(dividingBy: loopDuration)
            let currentTime = (loopStartTime + currentTimeInLoop)
            return currentTime
        } else {
            return playerTime
        }
    }
}
