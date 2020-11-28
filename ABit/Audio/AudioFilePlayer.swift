import AVFoundation

enum AudioFilePlayerState {
    case awaitingFile
    case stopped
    case paused
    case playing
}

final class AudioFilePlayer: ObservableObject {

    @Inject var logger: Logger

    @Published var playerState: AudioFilePlayerState = .awaitingFile

    @Published var loop: Bool = true

    @Published var mute: Bool = false {
        didSet {
            audioPlayerNode.volume = mute ? 0 : 1
        }
    }

    @Published var playheadPosition: Double?
    @Published var playheadTime: Double?

    var fileUrl: URL?

    var audioPlayerNode = AVAudioPlayerNode()

    private var playheadUpdateTimer: Timer?

    private var name: String

    init(name: String) {
        self.name = name
    }

    @Published var audioFile: AVAudioFile? {
        didSet {
            stop()
            playTimeRange = playTimeRange(audioFile: audioFile, playPositionRange: playPositionRange)
        }
    }

    @Published var playPositionRange: ClosedRange<TimeInterval> = 0.0...1.0 {
        didSet {
            let previousState = playerState
            stop()
            playTimeRange = playTimeRange(audioFile: audioFile, playPositionRange: playPositionRange)

            if previousState == .playing {
                play()
            }
        }
    }

    @Published var playTimeRange: ClosedRange<TimeInterval>?

    deinit {
        stopPlayheadUpdates()
        stop()
    }

    func play() {
        guard let fileUrl = fileUrl else { return }

        do {
            // TODO: Investigate why we have to load load the audio file from the url here
            // Reading the file into a buffer fails if I use the class property (audioFile)
            let file = try AVAudioFile(forReading: fileUrl)

            if loop {
                let frameCapacity = AVAudioFrameCount(file.length)
                if let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCapacity) {
                    try file.read(into: buffer)

                    let start = AVAudioFramePosition(playPositionRange.lowerBound * Double(file.length))
                    let end = AVAudioFramePosition(playPositionRange.upperBound * Double(file.length))
                    if let segment = buffer.segment(from: start, to: end) {
                        audioPlayerNode.scheduleBuffer(segment,
                                                       at: nil,
                                                       options: [.loops, .interrupts],
                                                       completionHandler: nil)
                    }
                }

            } else {
                audioPlayerNode.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.stop()
                    }
                }
            }

            audioPlayerNode.play()
            playerState = .playing
            startPlayheadUpdates()

        } catch {
            logger.log(.error, "Failed to play file \(fileUrl.absoluteString)", error: error)
        }
    }

    @discardableResult
    func loadAudioFile(url: URL?) -> AVAudioFile? {
        guard let url = url else { return nil }

        do {
            audioFile = try AVAudioFile(forReading: url)
            fileUrl = url
            playerState = .stopped

            return audioFile

        } catch {
            logger.log(.error, "Failed to load file \(url.absoluteString)", error: error)
            return nil
        }
    }

    func unpause() {
        audioPlayerNode.play()
        startPlayheadUpdates()
        playerState = .playing
    }

    func pause() {
        audioPlayerNode.pause()
        stopPlayheadUpdates()
        playerState = .paused
    }

    func stop() {
        audioPlayerNode.stop()
        stopPlayheadUpdates()
        playerState = .stopped
    }

    private func playTimeRange(audioFile: AVAudioFile?,
                               playPositionRange: ClosedRange<Double>) -> ClosedRange<TimeInterval>? {
        guard let duration = audioFile?.duration else { return nil }
        let timesBounds = [duration * playPositionRange.lowerBound,
                           duration * playPositionRange.upperBound]

        let startTime = timesBounds.min() ?? 0
        let endTime = timesBounds.max() ?? duration

        return startTime...endTime
    }

    private func startPlayheadUpdates(withTimeInterval interval: TimeInterval = 1/60) {
        playheadUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard
                let self = self,
                let fileDuration = self.audioFile?.duration,
                let playerTime = self.audioPlayerNode.currentTime
            else {
                return
            }

            if self.loop {
                let loopStartTime = self.playPositionRange.lowerBound * fileDuration
                let loopDuration = self.playPositionRange.size * fileDuration
                let currentTimeInLoop = playerTime.truncatingRemainder(dividingBy: loopDuration)
                let currentTime = (loopStartTime + currentTimeInLoop)
                self.playheadTime = currentTime
                self.playheadPosition = currentTime / fileDuration
            } else {
                self.playheadTime = playerTime
                self.playheadPosition = playerTime / fileDuration
            }
        }
    }

    private func stopPlayheadUpdates() {
        playheadUpdateTimer?.invalidate()
        playheadUpdateTimer = nil
    }
}
