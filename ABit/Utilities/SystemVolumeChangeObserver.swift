import Foundation
import MediaPlayer

typealias VolumeChangeHandler = (_ volume: Float) -> Void

class SystemVolumeChangeObserver {

    static var shared = SystemVolumeChangeObserver()

    static var maxVolume = Float.one

    lazy var lastAudioLevel = AVAudioSession.sharedInstance().outputVolume

    private var mpVolumeView = MPVolumeView(frame: CGRect.zero)

    private let name = NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")

    var volumeChangeHandler: VolumeChangeHandler?

    func startObserving(handler: VolumeChangeHandler?) {
        self.volumeChangeHandler = handler

        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
            if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
                self?.volumeChangeHandler?(volume)
                self?.lastAudioLevel = volume
                Logger.log(.verbose, "Volume level change observed \(volume)")
            }
        }
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        self.volumeChangeHandler = nil
    }
}
