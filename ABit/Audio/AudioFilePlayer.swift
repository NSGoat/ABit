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

    private var audioFileManager: DocumentFileManager<AVAudioFile>

    @Published var state: AudioFilePlayerState = .awaitingFile

    @Published var playheadPosition: Double?

    @Published var playheadTime: Double?

    @Published var loop: Bool = true

    @Published var mute: Bool = false {
        didSet {
            audioPlayerNode.volume = mute ? 0 : 1
        }
    }

    @Published var image: UIImage?
    @Published var renderingImage: Bool = false

    @Published var playTimeRange: ClosedRange<TimeInterval>?
    @Published var playPositionRange: ClosedRange<Double> = 0.0...1.0 {
        didSet {
            let previousState = state
            stop()
            playTimeRange = timeRange(forPositionRange: playPositionRange, fromDuration: audioFileDuration)

            if previousState == .playing {
                DispatchQueue.global(qos: .default).async {
                    self.play()
                }
            }
        }
    }

    var audioFileDuration: TimeInterval? {
        didSet {
            playTimeRange = timeRange(forPositionRange: playPositionRange, fromDuration: audioFileDuration)
        }
    }

    var fileUrl: URL?
    var bookmarkKey: String
    lazy var audioPlayerNode = AVAudioPlayerNode()
    private lazy var playheadUpdater = AudioFilePlayerPlayheadTracker(audioFilePlayer: self)
    private var lastBufferCache: (buffer: AVAudioPCMBuffer, timeRange: ClosedRange<TimeInterval>)?

    init(audioFileManager: AudioFileManager, cacheKey: String) {
        self.bookmarkKey = cacheKey
        self.audioFileManager = audioFileManager
    }

    deinit {
        unloadPlayer()
    }
}

extension AudioFilePlayer {

    func loadAudioFile(url: URL?) {
        guard let url = url else { return }
        unloadPlayer()
        state = .loading

        do {
            let document = try audioFileManager.storeFileAsDocument(sourceUrl: url, bookmarkedWithKey: bookmarkKey)
            audioFileDuration = document.file.duration
            fileUrl = document.url

            _ = fileUrl?.startAccessingSecurityScopedResource()

            let width = UIScreen.main.bounds.size.width
            updateWaveformImage(url: document.url, size: CGSize(width: width, height: width/3))

            stop()
        } catch {
            logger.log(.error, "Failed to load file \(url.absoluteString)", error: error)
            unloadPlayer()
        }
    }

    func unloadPlayer() {
        stop()
        fileUrl?.stopAccessingSecurityScopedResource()
        fileUrl = nil
        audioFileDuration = nil
        lastBufferCache = nil
        image = nil
        playPositionRange = 0.0...1.0
        playTimeRange = nil
        state = .awaitingFile
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

            if lastBufferCache?.timeRange == playTimeRange, let buffer = lastBufferCache?.buffer {
                playBuffer(buffer, looping: loop)
            } else if let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCapacity) {
                try file.read(into: buffer)

                let start = AVAudioFramePosition(playPositionRange.lowerBound * Double(file.length))
                let end = AVAudioFramePosition(playPositionRange.upperBound * Double(file.length))
                if let segment = buffer.segment(from: start, to: end) {
                    playBuffer(segment, looping: loop)

                    if let playTimeRange = playTimeRange {
                        lastBufferCache = (buffer: segment, timeRange: playTimeRange)
                    } else {
                        lastBufferCache = nil
                    }
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
        fileUrl?.stopAccessingSecurityScopedResource()
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

    private func timeRange(forPositionRange positionRange: ClosedRange<Double>,
                           fromDuration duration: TimeInterval?) -> ClosedRange<TimeInterval>? {
        guard let duration = duration else { return nil }
        let timesBounds = [duration * positionRange.lowerBound,
                           duration * positionRange.upperBound]

        let startTime = timesBounds.min() ?? 0
        let endTime = timesBounds.max() ?? duration

        return startTime...endTime
    }
}
