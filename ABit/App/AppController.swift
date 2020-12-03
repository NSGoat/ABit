import AVFoundation
import Foundation

class AppController: NSObject {

    static var shared = AppController()

    lazy var lastAudioLevel = AVAudioSession.sharedInstance().outputVolume

    @Inject var audioManager: AudioManager
    @Inject var volumeListener: SystemVolumeChangeListener
    @Inject var logger: Logger

    private let maxVolume: Float = 1.0

    func switchChannedlOnRedundantVolumeUpPress(enabled: Bool) {
        volumeListener.startVolumeObservation { [weak self] volume in
            guard let self = self else { return }

            if self.lastAudioLevel == self.maxVolume, volume == self.maxVolume {
                self.audioManager.selectedChannel.selectNext()
                Logger.log(.info, changeToChannelMessage(self.audioManager.selectedChannel))
            }
        }
    }
}

private func changeToChannelMessage(_ channel: AudioChannel) -> String {
    return "Switched to channel \(channel.rawValue) on redundant volume up press"
}
