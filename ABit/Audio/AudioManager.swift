import AudioKit
import Combine
import Foundation

final class AudioManager: ObservableObject {

    enum Channel: String, CaseIterable {
        case a = "A"
        case b = "B"

        mutating func selectNext() {
            self = self.next()
        }
    }

    let engine = AudioKit.AudioEngine()
    let mixer: Mixer = Mixer()
    var audioFilePlayers = [Channel: AudioFilePlayer]()

    @Published var selectedChannel: Channel = .a {
        didSet {
            solo(channel: selectedChannel)
        }
    }

    init() {
        engine.output = mixer

        try? engine.start()
    }

    func audioFilePlayer(channel: Channel) -> AudioFilePlayer {
        if let audioFilePlayer = audioFilePlayers[channel] {
            return audioFilePlayer
        } else {
            let audioFilePlayer = AudioFilePlayer(name: channel.rawValue)
            audioFilePlayers[channel] = audioFilePlayer
            mixer.addInput(audioFilePlayer.audioPlayer)
            return audioFilePlayer
        }
    }

    func solo(channel: Channel) {
        audioFilePlayers.forEach { (playerChannel, player) in
            player.muted = playerChannel != channel
        }
    }
}
}
