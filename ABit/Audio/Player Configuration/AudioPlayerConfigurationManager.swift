import AVFoundation
import Foundation
import UIKit

extension AVAudioFile: UrlReadable { }

class AudioPlayerConfigurationManager: DocumentFileManager<AVAudioFile> {

    func store(configuration: AudioPlayerConfiguration, withKey key: String) {
        if let encoded = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func recallConfiguration(forKey key: String) -> AudioPlayerConfiguration?  {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else { return nil }

        return try? JSONDecoder().decode(AudioPlayerConfiguration.self, from: data)
    }

    func clearPlayerConfiguration(forUserDefaultsKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
