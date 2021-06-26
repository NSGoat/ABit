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

    var audioFileManager: AudioFileManager

    private let audioEngine = AVAudioEngine()

    var audioFilePlayers = [AudioChannel: AudioFilePlayer]()

    @Published var anyPlayerPlaying: Bool = false

    var allPlayersPlaying: Bool { audioFilePlayers.values.allSatisfy { $0.state == .playing } }

    @Published var selectedChannel: AudioChannel = .a {
        didSet {
            solo(channel: selectedChannel)
        }
    }

    init(audioFileManager: AudioFileManager) {
        self.audioFileManager = audioFileManager

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            let mixer = audioEngine.mainMixerNode

#if DEBUG
            mixer.outputVolume = 0.01
#endif

            try audioEngine.start()
            audioEngine.prepare()

            let fallbackUrlA = Bundle.main.url(forResource: "Winstons - Amen, Brother", withExtension: "aif")
            let playerA = configureNewAudioFilePlayer(channel: .a, fallbackUrl: fallbackUrlA)

            let fallbackUrlB = Bundle.main.url(forResource: "1, 2, 3, 4", withExtension: "mp3")
            let playerB = configureNewAudioFilePlayer(channel: .b, fallbackUrl: fallbackUrlB)

            selectedChannel = .a

            setupAnyPlayerPlayingPublisher(playerA: playerA, playerB: playerB)

        } catch {
            Logger.log(.error, "Failed to initialise AudioManager", error: error)
        }
    }

    func audioFilePlayer(channel: AudioChannel) -> AudioFilePlayer {
        return audioFilePlayers[channel] ?? configureNewAudioFilePlayer(channel: channel)
    }

    @discardableResult
    private func configureNewAudioFilePlayer(channel: AudioChannel, fallbackUrl: URL? = nil) -> AudioFilePlayer {
        let audioFilePlayer = AudioFilePlayer(audioFileManager: audioFileManager, cacheKey: channel.rawValue)
        audioFilePlayers[channel] = audioFilePlayer

        audioEngine.attach(audioFilePlayer.audioPlayerNode)
        audioEngine.connect(audioFilePlayer.audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)

        let url = try? audioFileManager.retrieveDocument(userDefaultsKey: channel.rawValue).url
        audioFilePlayer.loadAudioFile(url: url ?? fallbackUrl)

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
