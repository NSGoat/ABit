import AVFoundation
import UIKit

enum AudioFilePlayerState {
    case awaitingFile
    case stopped
    case paused
    case playing
}

final class AudioFilePlayer: ObservableObject {

    @Inject var logger: Logger

    @Published var playerState: AudioFilePlayerState = .awaitingFile

    @Published var playheadPosition: Double?

    @Published var playheadTime: Double?

    @Published var loop: Bool = true

    @Published var mute: Bool = false {
        didSet {
            audioPlayerNode.volume = mute ? 0 : 1
        }
    }

    @Published var audioFile: AVAudioFile? {
        didSet {
            stop()
            playTimeRange = audioFile?.timeRange(positionRange: playPositionRange)
        }
    }

    @Published var playPositionRange: ClosedRange<Double> = 0.0...1.0 {
        didSet {
            let previousState = playerState
            stop()
            playTimeRange = audioFile?.timeRange(positionRange: playPositionRange)

            if previousState == .playing {
                DispatchQueue.global(qos: .default).async {
                    self.play()
                }
            }
        }
    }

    @Published var playTimeRange: ClosedRange<TimeInterval>?

    var fileUrl: URL?
    lazy var audioPlayerNode = AVAudioPlayerNode()
    private lazy var playheadUpdater = AudioFilePlayerPlayheadTracker(audioFilePlayer: self)

    deinit {
        stop()
    }
}

extension AudioFilePlayer {

    @discardableResult
    func loadAudioFile(url: URL?) -> AVAudioFile? {
        guard let url = url else { return nil }

        do {
            audioFile = try AVAudioFile(forReading: url)
            fileUrl = url
            stop()

            return audioFile

        } catch {
            logger.log(.error, "Failed to load file \(url.absoluteString)", error: error)
            return nil
        }
    }

    func play() {
        guard let fileUrl = fileUrl else { return }
        guard playPositionRange.size > 0 else { return }

        do {
            // TODO: Investigate why we have to load load the audio file from the url here
            // Reading the file into a buffer fails if I use the class property (audioFile)
            let file = try AVAudioFile(forReading: fileUrl)
            let frameCapacity = AVAudioFrameCount(file.length)
            if let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCapacity) {
                try file.read(into: buffer)

                let start = AVAudioFramePosition(playPositionRange.lowerBound * Double(file.length))
                let end = AVAudioFramePosition(playPositionRange.upperBound * Double(file.length))
                if let segment = buffer.segment(from: start, to: end) {

                    if loop {
                        audioPlayerNode.scheduleBuffer(segment, at: nil, options: [.loops, .interrupts])
                    } else {
                        audioPlayerNode.scheduleBuffer(segment, at: nil, options: [.interrupts]) {
                            DispatchQueue.main.async { [weak self] in
                                self?.stop()
                            }
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.audioPlayerNode.play()
                self.playerState = .playing
                self.startPlayheadUpdates()
            }

        } catch {
            logger.log(.error, "Failed to play file \(fileUrl.absoluteString)", error: error)
        }
    }

    func stop() {
        audioPlayerNode.stop()
        stopPlayheadUpdates()
        playheadTime = nil
        playheadPosition = nil
        playerState = .stopped
    }

    func pause() {
        audioPlayerNode.pause()
        stopPlayheadUpdates()
        playerState = .paused
    }

    func unpause() {
        audioPlayerNode.play()
        startPlayheadUpdates()
        playerState = .playing
    }

    private func startPlayheadUpdates() {
        let updateInterval = 1.0/Double(UIScreen.main.maximumFramesPerSecond)
        playheadUpdater.startTracking(withTimeInterval: updateInterval) { playhead in
            self.playheadTime = playhead?.time
            self.playheadPosition = playhead?.position
        }
    }

    private func stopPlayheadUpdates() {
        playheadUpdater.stopTracking()
    }
}
