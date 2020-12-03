import Foundation
import MediaPlayer

typealias VolumeChangeHandler = (_ volume: Float) -> Void

class SystemVolumeChangeListener {

    static var shared = SystemVolumeChangeListener()

    private let systemVolumeChangeNotificationName =
        NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")

    private var mpVolumeView = MPVolumeView(frame: CGRect.zero)

    var volumeChangeHandler: VolumeChangeHandler?

    func startVolumeObservation(handler: VolumeChangeHandler?) {

        self.volumeChangeHandler = handler

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(volumeChanged(_:)),
                                               name: systemVolumeChangeNotificationName,
                                               object: nil)
    }

    @objc
    private func volumeChanged(_ notification: NSNotification) {
        let volumeInfoKey = "AVSystemController_AudioVolumeNotificationParameter"

        if let volume = notification.userInfo?[volumeInfoKey] as? Float {
            self.volumeChangeHandler?(volume)
            Logger.log(.verbose, "Volume level change observed \(volume)")
        }
    }
}
