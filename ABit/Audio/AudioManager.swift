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

    static let shared = AudioManager()

    let engine = AKManager.engine
    let mixer: AKMixer = AKMixer()
    var audioFilePlayers = [AudioChannel: AudioFilePlayer]()

    @Published var selectedChannel: AudioChannel = .a {
        didSet {
            solo(channel: selectedChannel)
        }
    }

    init() {
        AKManager.output = mixer
        try? AKManager.start()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        configureNewAudioFilerPlayer(channel: .a)
        configureNewAudioFilerPlayer(channel: .b)
        selectedChannel = .a
    }

    deinit {
        try? AKManager.stop()
    }

    func audioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        return audioFilePlayers[channel] ?? configureNewAudioFilerPlayer(channel: channel)
    }

    @discardableResult
    private func configureNewAudioFilerPlayer(channel: AudioChannel) -> AudioFilePlayer {
        let audioFilePlayer = AudioFilePlayer(name: channel.rawValue)
        audioFilePlayers[channel] = audioFilePlayer
        mixer.connect(input: audioFilePlayer.audioPlayer)
        return audioFilePlayer
    }

    func solo(channel: AudioChannel) {
        audioFilePlayers.forEach { (playerChannel, player) in
            player.mute = playerChannel != channel
        }
    }
}
