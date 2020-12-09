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
            self.playhead = self.playhead(audioFilePlayer: self.audioFilePlayer)
            block(self.playhead)
        }

        return playhead
    }

    func stopTracking() {
        playheadUpdateTimer?.invalidate()
        playheadUpdateTimer = nil
    }

    private func playhead(audioFilePlayer: AudioFilePlayer) -> Playhead? {
        guard let duration = audioFilePlayer.audioFileDuration,
              let playerTime = audioFilePlayer.audioPlayerNode.currentTime
        else {
            return nil
        }

        let currentPlayheadTime = playheadTime(playerTime: playerTime,
                                               fileDuration: duration,
                                               playPositionRange: audioFilePlayer.playPositionRange,
                                               looping: audioFilePlayer.loop)

        return Playhead(time: currentPlayheadTime, position: currentPlayheadTime/duration)
    }

    private func playheadTime(playerTime: TimeInterval,
                              fileDuration: TimeInterval,
                              playPositionRange: ClosedRange<Double>,
                              looping: Bool) -> TimeInterval {

        if looping || playPositionRange.size < 1 {
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
