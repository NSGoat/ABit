//  Created by Ed Rutter on 19/09/2020.

import UIKit

import AudioKit
import AVFoundation

final class AudioFilePlayer: ObservableObject {

    @Published var loadedFileUrl: URL?

    @Published var muted: Bool {
        didSet {
            audioPlayer.mixerNode.volume = muted ? 0 : 1
        }
    }

    let audioPlayer: AudioPlayer = AudioPlayer()
    var name: String
    var audioFile: AVAudioFile?

    init(name: String) {
        self.name = name
        self.muted = false
    }

    func playAudioFile(url: URL?) {
        guard let url = url else {
            loadedFileUrl = nil
            return
        }
        loadAudioFile(url: url)
        play()
    }

    func loadAudioFile(url: URL) {
        do {
            audioFile = try AVAudioFile(forReading: url)
            loadedFileUrl = url

        } catch {
            print(error)
        }
    }

    func play() {
        guard let audioFile = audioFile else { return }

        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }

        audioPlayer.scheduleFile(audioFile, at: AVAudioTime(hostTime: 3000))
        audioPlayer.play()
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
