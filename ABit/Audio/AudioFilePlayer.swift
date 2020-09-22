import AudioKit
import AVFoundation

class PlaybackSettings {
    @Published var startPosition: Double = 0
    @Published var endPosition: Double?
    @Published var loop: Bool = false

    init(startPosition: Double,
         endPosition: Double?,
         loop: Bool) {
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.loop = loop
    }
}

final class AudioFilePlayer: ObservableObject {

    @Published var loadedFileUrl: URL?

    @Published var muted: Bool = false {
        didSet {
            audioPlayer.mixerNode.volume = muted ? 0 : 1
        }
    }

    let audioPlayer: AudioPlayer = AudioPlayer()
    var name: String

    var file: AVAudioFile?
    @Published var playback =  PlaybackSettings(startPosition: 0, endPosition: nil, loop: false)

    init(name: String) {
        self.name = name
    }

    func playAudioFile(url: URL?, settings playbackSettings: PlaybackSettings) {

        playback = playbackSettings

        guard
            let audioFile = loadAudioFile(url: url)
        else {
            file = nil
            loadedFileUrl = nil
            return
        }

        playAudioFile(audioFile: audioFile,
                      startPosition: playback.startPosition,
                      endPosition: playback.endPosition,
                      loop: playback.loop)
    }

    private func playAudioFile(audioFile: AVAudioFile,
                               startPosition: Double,
                               endPosition: Double? = nil,
                               loop: Bool = false) {

        var startTime = audioFile.duration * startPosition
        var endTime = audioFile.duration * (endPosition ?? 1)

        if startTime > endTime {
            let swap = startTime
            startTime = endTime
            endTime = swap
        }

        let sampleRate = audioFile.fileFormat.sampleRate
        let duration = endTime - startTime

        let startFrame = AVAudioFramePosition(sampleRate * startTime)
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        audioPlayer.playerNode.scheduleSegment(audioFile,
                                               startingFrame: startFrame,
                                               frameCount: frameCount,
                                               at: nil,
                                               completionCallbackType: .dataPlayedBack) { [weak self] _ in
            if loop {
                self?.playAudioFile(audioFile: audioFile,
                                    startPosition: startPosition,
                                    endPosition: endPosition,
                                    loop: loop)
            }
        }
        audioPlayer.play()
    }

    @discardableResult func loadAudioFile(url: URL?) -> AVAudioFile? {
        guard let url = url else { return nil }

        do {
            file = try AVAudioFile(forReading: url)
            loadedFileUrl = url
            return file

        } catch {
            print(error)
            return nil
        }
    }

    func pause() {
        audioPlayer.pause()
    }

    func stop() {
        audioPlayer.stop()
    }

    var gain: Float {
        get { audioPlayer.mixerNode.outputVolume }
        set { audioPlayer.mixerNode.outputVolume = newValue }
    }
}
