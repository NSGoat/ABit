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

    var audioFilePlayers = [AudioChannel: AudioFilePlayer]()

    @Published var selectedChannel: AudioChannel = .a {
        didSet {
            solo(channel: selectedChannel)
        }
    }

    let audioEngine = AVAudioEngine()

    init() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        let mixer = audioEngine.mainMixerNode
        try? audioEngine.start()
        audioEngine.prepare()

        let playerA = configureNewAudioFilePlayer(channel: .a)
        audioEngine.attach(playerA.audioPlayerNode)
        audioEngine.connect(playerA.audioPlayerNode, to: mixer, format: nil)

        let playerB = configureNewAudioFilePlayer(channel: .b)
        audioEngine.attach(playerB.audioPlayerNode)
        audioEngine.connect(playerB.audioPlayerNode, to: mixer, format: nil)
        selectedChannel = .a

        let url = Bundle.main.url(forResource: "Winstons - Amen, Brother", withExtension: "aif")
        let countUrl = Bundle.main.url(forResource: "1, 2, 3, 4", withExtension: "mp3")
        audioFilePlayer(channel: .a).loadAudioFile(url: url)
        audioFilePlayer(channel: .b).loadAudioFile(url: countUrl)
    }

    func audioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        return audioFilePlayers[channel] ?? configureNewAudioFilePlayer(channel: channel)
    }

    @discardableResult
    private func configureNewAudioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        let audioFilePlayer = AudioFilePlayer(name: channel.rawValue)
        audioFilePlayers[channel] = audioFilePlayer
        return audioFilePlayer
    }

    func solo(channel: AudioChannel) {
        audioFilePlayers.forEach { (playerChannel, player) in
            player.mute = playerChannel != channel
        }
    }
}
