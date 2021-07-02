import AVFoundation
import Foundation

class AppController: NSObject {

    static var shared = AppController()

    @Inject var audioManager: AudioManager
    @Inject var logger: Logger

    lazy var lastAudioLevel = AVAudioSession.sharedInstance().outputVolume

    var volumeObserver =  SystemVolumeChangeObserver()

    private let maxVolume: Float = 1.0

    func switchChannedlOnRedundantVolumeUpPress(enabled: Bool) {
        if enabled {
            volumeObserver.startObserving { [weak self] volume in
                guard let self = self else { return }
                self.handleVolumeChange(volume)
            }
        } else {
            volumeObserver.stopObserving()
        }
    }

    private func handleVolumeChange(_ volume: Float) {
        if volume == self.maxVolume,
           self.lastAudioLevel == self.maxVolume,
           self.audioManager.allPlayersPlaying {
            self.audioManager.selectedChannel?.selectNext()
            Logger.log(.info, changeToChannelMessage(self.audioManager.selectedChannel))
        }
        self.lastAudioLevel = volume
    }
}

private func changeToChannelMessage(_ channel: AudioChannel?) -> String {
    return "Switched to channel \(String(describing: channel?.rawValue.description)) on redundant volume increment"
}
