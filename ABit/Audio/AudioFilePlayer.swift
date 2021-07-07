import AVFoundation
import UIKit
import CoreMedia

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

    private var audioPlayerConfigurationManager: AudioPlayerConfigurationManager

    @Published var state: AudioFilePlayerState = .awaitingFile

    @Published var playheadPosition: Double?

    @Published var playheadTime: Double?

    @Published var loop: Bool = true

    @Published var mute: Bool = true {
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

    var bookmarkUrl: URL?
    var bookmarkKey: String
    lazy var audioPlayerNode = AVAudioPlayerNode()
    private lazy var playheadUpdater = AudioFilePlayerPlayheadTracker(audioFilePlayer: self)
    private var lastBufferCache: (buffer: AVAudioPCMBuffer, timeRange: ClosedRange<TimeInterval>)?

    init(audioFileManager: AudioPlayerConfigurationManager, cacheKey: String) {
        self.bookmarkKey = cacheKey
        self.audioPlayerConfigurationManager = audioFileManager

        if let configuration = audioFileManager.playerConfiguration(userDefaultsKey: cacheKey) {
            configure(configuration)
        }
    }

    deinit {
        unloadPlayer()
    }
}

extension AudioFilePlayer {

    func configure(_ playerConfiguration: AudioPlayerConfiguration) {
        loadAudioFile(url: playerConfiguration.bookmarkUrl)
        playPositionRange = playerConfiguration.triggers.first?.positionRange ?? 0...1
        loop = playerConfiguration.triggers.first?.loop ?? true
    }

    func saveConfiguration() {
        if let url = bookmarkUrl {
            let trigger = AudioPlayerConfiguration.Trigger(mode: .cue, loop: loop, positionRange: playPositionRange)
            let configuration = AudioPlayerConfiguration(bookmarkUrl: url, triggers: [trigger])
            audioPlayerConfigurationManager.savePlayerConfiguration(configuration, userDefaultsKey: bookmarkKey)
        } else {
            audioPlayerConfigurationManager.clearPlayerConfiguration(forUserDefaultsKey: bookmarkKey)
        }
    }

    func loadAudioFile(url: URL?) {
        guard let url = url else { return }
        unloadPlayer()
        state = .loading

        do {
            let document = try audioPlayerConfigurationManager.storeFileAsDocument(sourceUrl: url,
                                                                                   bookmarkedWithKey: bookmarkKey)
            audioFileDuration = document.file.duration
            bookmarkUrl = document.url

            _ = bookmarkUrl?.startAccessingSecurityScopedResource()

            let width = UIScreen.main.bounds.size.width
            updateWaveformImage(url: url, size: CGSize(width: width, height: width/3))
        } catch {
            logger.log(.error, "Failed to load file \(url.absoluteString)", error: error)
            unloadPlayer()
        }
    }

    func unloadPlayer() {
        stop()
        bookmarkUrl?.stopAccessingSecurityScopedResource()
        bookmarkUrl = nil
        audioFileDuration = nil
        lastBufferCache = nil
        image = nil
        playPositionRange = 0.0...1.0
        playTimeRange = nil
        state = .awaitingFile
    }

    func play() {
        guard let bookmarkUrl = bookmarkUrl else { return }
        guard playPositionRange.size > 0 else { return }

        do {
            let file = try AVAudioFile(forReading: bookmarkUrl)
            guard file.length > 0, file.fileFormat.channelCount > 0 else { return }
            // TODO: Investigate why we have to load load the audio file from the url here
            // guard let file = audioFile else { return }

            // Reconnect AVAudioPlayerNode setting the AVAudioFormat to ensure playback at correct sampling rate
            guard let audioEngine = audioPlayerNode.engine else { return }
            let format = file.processingFormat
            audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: file.processingFormat)

            let frameCapacity = AVAudioFrameCount(file.length)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return }
            try file.read(into: buffer)

            if let buffer = lastBufferCache?.buffer, lastBufferCache?.timeRange == playTimeRange {
                audioPlayerNode.scheduleSegment(fromBuffer: buffer, range: playPositionRange, looping: loop)
            } else {
                let segmentRange = playPositionRange
                lastBufferCache = audioPlayerNode.scheduleSegment(fromBuffer: buffer, range: segmentRange, looping: loop)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard self.audioPlayerNode.startEngineIfNeeded() else { return }

                self.audioPlayerNode.play()
                self.state = .playing
                self.startPlayheadUpdates()
            }

        } catch {
            logger.log(.error, "Failed to play file \(bookmarkUrl.absoluteString)", error: error)
        }
    }

    func stop() {
        audioPlayerNode.stop()
        saveConfiguration()
        bookmarkUrl?.stopAccessingSecurityScopedResource()
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

    ///MARK: – Private Functions

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
                guard let self = self else { return }
                self.image = image
                self.renderingImage = false
                self.state = self.audioPlayerNode.isPlaying ? .playing : .stopped
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
