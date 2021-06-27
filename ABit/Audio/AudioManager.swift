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

    var audioPlayerConfigurationManager: AudioPlayerConfigurationManager

    private let audioEngine = AVAudioEngine()

    var audioFilePlayers = [AudioChannel: AudioFilePlayer]()

    @Published var anyPlayerPlaying: Bool = false

    var allPlayersPlaying: Bool { audioFilePlayers.values.allSatisfy { $0.state == .playing } }

    @Published var selectedChannel: AudioChannel? {
        didSet {
            if let selectedChannel = selectedChannel {
                solo(channel: selectedChannel)
            } else {
                muteAll()
            }
        }
    }

    init(audioPlayerConfigurationManager: AudioPlayerConfigurationManager) {
        self.audioPlayerConfigurationManager = audioPlayerConfigurationManager

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            let mixer = audioEngine.mainMixerNode

            try audioEngine.start()
            audioEngine.prepare()

            let playerA = configureNewAudioFilePlayer(channel: .a, fallbackUrl: nil)
            let playerB = configureNewAudioFilePlayer(channel: .b, fallbackUrl: nil)
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
        let key = defaultsKey(channel: channel)
        let audioFilePlayer = AudioFilePlayer(audioFileManager: audioPlayerConfigurationManager, cacheKey: key)
        audioFilePlayers[channel] = audioFilePlayer

        audioEngine.attach(audioFilePlayer.audioPlayerNode)
        audioEngine.connect(audioFilePlayer.audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)

        if let playerConfiguration = audioPlayerConfigurationManager.playerConfiguration(userDefaultsKey: key) {
            audioFilePlayer.configure(playerConfiguration)
        }

        return audioFilePlayer
    }

    private func defaultsKey(channel: AudioChannel) -> String {
        "AudioPlayerConfiguration_Channel_\(channel.rawValue)"
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

    func muteAll() {
        audioFilePlayers.forEach { (playerChannel, player) in
            player.mute = true
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

    func saveAllConfigurations() {
        audioFilePlayers.values.forEach { player in
            player.saveConfiguration()
        }
    }
}
