import AVFoundation
import Combine
import Foundation
import SwiftUI

enum AudioChannel: String, CaseIterable {
    case a = "A"
    case b = "B"

    mutating func selectNext() {
        self = self.next()
    }
}

final class AudioManager: ObservableObject {

    static let shared = AudioManager()

    private let audioEngine = AVAudioEngine()

    var audioFilePlayers = [AudioChannel: AudioFilePlayer]()

    @Published var anyPlayerPlaying: Bool = false

    var allPlayersPlaying: Bool { audioFilePlayers.values.allSatisfy { $0.state == .playing } }

    @Published var selectedChannel: AudioChannel = .a {
        didSet {
            solo(channel: selectedChannel)
        }
    }

    init() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        let mixer = audioEngine.mainMixerNode

        #if DEBUG
        mixer.outputVolume = 0.01
        #endif

        try? audioEngine.start()
        audioEngine.prepare()

        let playerA = configureNewAudioFilePlayer(channel: .a)
        audioEngine.attach(playerA.audioPlayerNode)
        audioEngine.connect(playerA.audioPlayerNode, to: mixer, format: nil)
        playerA.loadAudioFile(url: Bundle.main.url(forResource: "Winstons - Amen, Brother", withExtension: "aif"))

        let playerB = configureNewAudioFilePlayer(channel: .b)
        audioEngine.attach(playerB.audioPlayerNode)
        audioEngine.connect(playerB.audioPlayerNode, to: mixer, format: nil)
        playerB.loadAudioFile(url: Bundle.main.url(forResource: "1, 2, 3, 4", withExtension: "mp3"))

        selectedChannel = .a

        setupAnyPlayerPlayingPublisher(playerA: playerA, playerB: playerB)
    }

    func audioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        return audioFilePlayers[channel] ?? configureNewAudioFilePlayer(channel: channel)
    }

    @discardableResult
    private func configureNewAudioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        let audioFilePlayer = AudioFilePlayer()
        audioFilePlayers[channel] = audioFilePlayer
        return audioFilePlayer
    }

    private var cancellableSet: Set<AnyCancellable> = []

    private func setupAnyPlayerPlayingPublisher(playerA: AudioFilePlayer, playerB: AudioFilePlayer) {
        Publishers.CombineLatest(playerA.$state, playerB.$state)
            .map { playerStateA, playerStateB -> Bool in
                playerStateA == .playing || playerStateB == .playing
            }
            .assign(to: \.anyPlayerPlaying, on: self)
            .store(in: &cancellableSet)
    }
}

extension AudioManager {

    func solo(channel: AudioChannel) {
        audioFilePlayers.forEach { (playerChannel, player) in
            player.mute = playerChannel != channel
        }
    }

    func playAll() {
        audioFilePlayers.values.forEach { player in
            player.play()
        }
    }

    func stopAll() {
        audioFilePlayers.values.forEach { player in
            player.stop()
        }
    }

    func pauseAll() {
        audioFilePlayers.values.forEach { player in
            player.pause()
        }
    }

    func unpauseAll() {
        audioFilePlayers.values.forEach { player in
            player.unpause()
        }
    }

    func setAllPlayPositionRanges(_ playPositionRange: ClosedRange<Double>) {
        audioFilePlayers.values.forEach { player in
            player.playPositionRange = playPositionRange
        }
    }
}
