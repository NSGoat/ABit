//  Created by Ed Rutter on 19/09/2020.

import UIKit

import AudioKit
import AVFoundation

final class AudioManager: ObservableObject {

    enum Channel: String {
        case a = "A"
        case b = "B"
    }

    let engine = AudioKit.AudioEngine()
    var mixer: Mixer = Mixer()
    var audioFilePlayers = [Channel: AudioFilePlayer]()

    init() {
        audioFilePlayers = [.a : AudioFilePlayer(name: Channel.a.rawValue),
                            .b : AudioFilePlayer(name: Channel.b.rawValue)]

        let mixerNodes = audioFilePlayers.values.map { $0.audioPlayer }
        mixer = AudioKit.Mixer(mixerNodes)
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
}
