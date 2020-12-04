import AVFoundation
import UIKit

enum AudioFilePlayerState {
    case awaitingFile
    case loading
    case stopped
    case paused
    case playing
}

final class AudioFilePlayer: ObservableObject {

    @Inject var logger: Logger

    @Inject var audioGraphicsRenderer: AudioGraphicsRenderer

    @Published var state: AudioFilePlayerState = .awaitingFile

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

    @Published var image: UIImage?
    @Published var renderingImage: Bool = false

    @Published var playPositionRange: ClosedRange<Double> = 0.0...1.0 {
        didSet {
            let previousState = state
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
    private var lastBufferCache: (buffer: AVAudioPCMBuffer, timeRange: ClosedRange<TimeInterval>)?

    deinit {
        stop()
        lastBufferCache = nil
    }
}

extension AudioFilePlayer {

    func loadAudioFile(url: URL?) {
        guard let url = url else { return }

        state = .loading

        do {
            audioFile = try AVAudioFile(forReading: url)

            let width = UIScreen.main.bounds.size.width
            let size = CGSize(width: width, height: width/3)
            updateWaveformImage(url: url, size: size)

            fileUrl = url
            stop()
        } catch {
            logger.log(.error, "Failed to load file \(url.absoluteString)", error: error)
            state = .awaitingFile
        }
    }

    func play() {
        guard let fileUrl = fileUrl else { return }
        guard playPositionRange.size > 0 else { return }

        do {
            // TODO: Investigate why we have to load load the audio file from the url here
            // guard let file = audioFile else { return }

            let file = try AVAudioFile(forReading: fileUrl)
            let frameCapacity = AVAudioFrameCount(file.length)

            guard file.length > 0, file.fileFormat.channelCount > 0 else { return }

            if lastBufferCache?.timeRange == playPositionRange, let buffer = lastBufferCache?.buffer {
                playBuffer(buffer, looping: loop)
            } else if let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCapacity) {
                try file.read(into: buffer)

                let start = AVAudioFramePosition(playPositionRange.lowerBound * Double(file.length))
                let end = AVAudioFramePosition(playPositionRange.upperBound * Double(file.length))
                if let segment = buffer.segment(from: start, to: end) {
                    playBuffer(segment, looping: loop)
                    lastBufferCache = (buffer: segment, timeRange: playPositionRange)
                }
            }

            DispatchQueue.main.async {
                self.audioPlayerNode.play()
                self.state = .playing
                self.startPlayheadUpdates()
            }

        } catch {
            logger.log(.error, "Failed to play file \(fileUrl.absoluteString)", error: error)
        }
    }

    private func playBuffer(_ buffer: AVAudioPCMBuffer, looping: Bool) {
        if loop {
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: [.loops, .interrupts])
        } else {
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: [.interrupts]) {
                DispatchQueue.main.async { [weak self] in
                    self?.stop()
                }
            }
        }
    }

    func stop() {
        audioPlayerNode.stop()
        stopPlayheadUpdates()
        playheadTime = nil
        playheadPosition = nil
        state = .stopped
    }

    func pause() {
        audioPlayerNode.pause()
        stopPlayheadUpdates()
        state = .paused
    }

    func unpause() {
        audioPlayerNode.play()
        startPlayheadUpdates()
        state = .playing
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

    private func updateWaveformImage(url: URL, size: CGSize) {
        self.image = nil
        renderingImage = true

        audioGraphicsRenderer.renderWaveformImage(audioFileUrl: url, size: size, style: .striped) { image in
            DispatchQueue.main.async { [weak self] in
                self?.image = image
                self?.renderingImage = false
            }
        }
    }
}
