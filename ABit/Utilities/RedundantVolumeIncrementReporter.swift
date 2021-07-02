import Foundation

class RedundantVolumeIncrementReporter {

    lazy var volumeObserver =  SystemVolumeChangeObserver()

    func startObservingRedundantVolumeIncrements(handler: @escaping () -> Void) {
        volumeObserver.startObserving { [weak self] newVolume in
            guard let self = self else { return }

            let isMaxVolume = self.volumeObserver.lastAudioLevel == SystemVolumeChangeObserver.maxVolume
            let willChangeToMaxVolume = newVolume == SystemVolumeChangeObserver.maxVolume

            if isMaxVolume, willChangeToMaxVolume {
                handler()
            }
        }
    }

    func stopObservingRedundantVolumeIncrements() {
        volumeObserver.stopObserving()
    }
}
