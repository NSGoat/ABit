import AVFoundation
import Foundation

class AppController: NSObject {

    @Inject var audioManager: AudioManager
    @Inject var logger: Logger
    @Inject var redundantVolumeIncrementReporter: RedundantVolumeIncrementReporter

    func toggleChannelOnRedundantVolumeIncrement(_ enable: Bool) {
        if enable {
            redundantVolumeIncrementReporter.startObservingRedundantVolumeIncrements {
                self.audioManager.selectedChannel?.selectNext()

                let selectedChannel = String(describing: self.audioManager.selectedChannel?.rawValue)
                self.logger.log(.info, "Redundant volume increment switched to channel: \(selectedChannel))")
            }
        } else {
            redundantVolumeIncrementReporter.stopObservingRedundantVolumeIncrements()
        }
    }
}
