import AudioKit
import AVFoundation

final class AudioFilePlayer: ObservableObject {

    enum PlayerState {
        case awaitingFile
        case stopped
        case paused
        case playing
    }

    var loadedFileUrl: URL?

    @Published var playerState: PlayerState = .awaitingFile

    @Published var loop: Bool = true {
        didSet {
            if playerState == .playing {
                audioPlayer?.stopAtNextLoopEnd()
            }
        }
    }

    @Published var mute: Bool = false {
        didSet {
            audioPlayer?.volume = mute ? 0 : 1
        }
    }

    @Published var playheadTime: Double?
    @Published var playheadPosition: Double?

    var audioPlayer: AKAudioPlayer?

    var playheadUpdateTimer: Timer?

    var name: String

    var file: AKAudioFile? {
        didSet {
            playTimeRange = playTimeRange(fileDuration: file?.duration, playRange: playPositionRange)
        }
    }

    @Published var playTimeRange: ClosedRange<Double>?
    @Published var playPositionRange = 0.0...1.0 {
        didSet {
            playTimeRange = playTimeRange(fileDuration: file?.duration, playRange: playPositionRange)
        }
    }

    init(name: String) {
        self.name = name
        if let audioFile = try? AKAudioFile(createFileFromFloats: [[]]) {
            self.audioPlayer = try? AKAudioPlayer(file: audioFile)
        }

        self.audioPlayer?.completionHandler = {
            self.playerState = .stopped
        }
    }

    deinit {
        stopPlayheadUpdates()
        stop()
        file = nil
        loadedFileUrl = nil
    }

    func play() {
        if let file = file, let range = playTimeRange {

            if audioPlayer?.audioFile.url != file.url {
                try? audioPlayer?.replace(file: file)
            }

            audioPlayer?.looping = loop
            audioPlayer?.play(from: range.lowerBound, to: range.upperBound)
            playerState = .playing
            startPlayheadUpdates()
        } else {
            loadedFileUrl = nil
        }
    }

    @discardableResult
    func loadAudioFile(url: URL?) -> AKAudioFile? {
        guard let url = url else { return nil }

        do {
            file = try AKAudioFile(forReading: url)
            loadedFileUrl = url
            playerState = .stopped

            return file

        } catch {
            print(error)
            return nil
        }
    }

    func unpause() {
        audioPlayer?.start()
        startPlayheadUpdates()
        playerState = .playing
    }

    func pause() {
        audioPlayer?.pause()
        stopPlayheadUpdates()
        playerState = .paused
    }

    func stop() {
        audioPlayer?.stop()
        stopPlayheadUpdates()
        playerState = .stopped
    }

    private func playTimeRange(fileDuration: Double?, playRange: ClosedRange<Double>) -> ClosedRange<Double>? {
        guard let duration = fileDuration  else { return nil }
        let times = [duration * playRange.lowerBound,
                     duration * playRange.upperBound]

        if let startTime = times.min(), let endTime = times.max() {
            return startTime...endTime
        }

        return nil
    }

    private func startPlayheadUpdates(withTimeInterval interval: TimeInterval = 1/60) {
        playheadUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let playhead = self.audioPlayer?.playhead {
                self.playheadTime = playhead

                if let duration = self.file?.duration {
                    self.playheadPosition = playhead/duration
                }
            }
        }
    }

    private func stopPlayheadUpdates() {
        playheadUpdateTimer?.invalidate()
        playheadUpdateTimer = nil
    }
}
