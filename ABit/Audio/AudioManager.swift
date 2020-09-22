import AudioKit
import AVFoundation
import Combine
import Foundation

enum AudioChannel: String, CaseIterable {
    case a = "A"
    case b = "B"

    mutating func selectNext() {
        self = self.next()
    }
}

final class AudioManager: ObservableObject {

    let engine = AudioKit.AudioEngine()
    let mixer: Mixer = Mixer()
    var audioFilePlayers = [AudioChannel: AudioFilePlayer]()

    @Published var selectedChannel: AudioChannel = .a {
        didSet {
            solo(channel: selectedChannel)
        }
    }

    init() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        _ = audioFilePlayer(channel: .a)
        _ = audioFilePlayer(channel: .b)
        selectedChannel = .a

        engine.output = mixer

        try? engine.start()
    }

    func audioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        if let audioFilePlayer = audioFilePlayers[channel] {
            return audioFilePlayer
        } else {
            let audioFilePlayer = AudioFilePlayer(name: channel.rawValue)
            audioFilePlayers[channel] = audioFilePlayer
            mixer.addInput(audioFilePlayer.audioPlayer)
            return audioFilePlayer
        }
    }

    func solo(channel: AudioChannel) {
        audioFilePlayers.forEach { (playerChannel, player) in
            player.muted = playerChannel != channel
        }
    }
}
