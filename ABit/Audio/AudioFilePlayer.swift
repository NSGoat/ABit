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

    var loadedFileUrl: URL?

    @Published var loop: Bool = false {
        didSet {
            audioPlayer?.looping = loop
        }
    }

    @Published var muted: Bool = false {
        didSet {
            audioPlayer?.volume = muted ? 0 : 1
        }
    }

    var audioPlayer: AKAudioPlayer?

    var name: String

    var file: AKAudioFile?
    @Published var playback =  PlaybackSettings(startPosition: 0, endPosition: nil, loop: false)

    init(name: String) {
        self.name = name
        if let audioFile = try? AKAudioFile(createFileFromFloats: [[]]) {
            self.audioPlayer = try? AKAudioPlayer(file: audioFile)
        }

        let observation = self.audioPlayer?.observe(\AKAudioPlayer.looping, changeHandler: { [weak self] (player, change) in
            if let value = change.newValue, change.newValue != change.oldValue {
                self?.loop = value
            }
        })
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

        if let file = file {
            try? audioPlayer?.replace(file: file)
            audioPlayer?.looping = loop

            DispatchQueue.main.async { [weak self] in
                self?.audioPlayer?.play(from: startTime, to: endTime)
            }
        }
    }

    @discardableResult func loadAudioFile(url: URL?) -> AKAudioFile? {
        guard let url = url else { return nil }

        do {
            file = try AKAudioFile(forReading: url)
            loadedFileUrl = url
            return file

        } catch {
            print(error)
            return nil
        }
    }

    func pause() {
        audioPlayer?.pause()
    }

    func stop() {
        audioPlayer?.stop()
    }
}
