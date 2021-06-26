import AVFoundation
import Foundation
import UIKit

extension AVAudioFile: UrlReadable { }

class AudioPlayConfigurationManager: DocumentFileManager<AVAudioFile> {

    func savePlayConfiguration(_ configuration: PlayConfiguration, userDefaultsKey: String) {
        UserDefaults.standard.set(configuration.plistDictionary, forKey: userDefaultsKey)
    }

    func playConfiguration(userDefaultsKey: String) -> PlayConfiguration? {
        guard let dict = UserDefaults.standard.value(forKey: userDefaultsKey) as? [String: Any] else { return nil }
        return PlayConfiguration(plistDictionary: dict)
    }

    func clearPlayConfiguration(forUserDefaultsKey userDefaultsKey: String) {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

struct PlayConfiguration {

    private let audioFileUrlKey = "document_retrieval_key"
    private let positionRangeLowerBoundKey = "position_range_lower_bound"
    private let positionRangeUpperBoundKey = "position_range_upper_bound"
    private let loopEnabledKey = "loop_enabled"

    var fileUrl: URL

    @UnitIntervalRange var positionRange: ClosedRange<Double>

    let loop: Bool

    var plistDictionary: [String: Any] {
        [audioFileUrlKey: fileUrl.absoluteString,
         positionRangeLowerBoundKey: NSNumber(value: positionRange.lowerBound),
         positionRangeUpperBoundKey: NSNumber(value: positionRange.upperBound),
         loopEnabledKey: NSNumber(value: loop)]
    }

    init(audioFileUrl: URL, positionRange: ClosedRange<Double>, loop loopEnabled: Bool) {
        self.fileUrl = audioFileUrl
        self.positionRange = positionRange.clamped(to: 0...1)
        self.loop = loopEnabled
    }

    init?(plistDictionary dictionary: [String: Any]) {
        guard let audioFileUrlString = dictionary[audioFileUrlKey] as? String else { return nil }
        guard let audioFileUrl = URL(string: audioFileUrlString) else { return nil }
        guard let positionRangeLowerBound = dictionary[positionRangeLowerBoundKey] as? Double else { return nil }
        guard let positionRangeUpperBound = dictionary[positionRangeUpperBoundKey] as? Double else { return nil }
        guard let loopEnabled = dictionary[loopEnabledKey] as? Bool else { return nil }

        fileUrl = audioFileUrl
        positionRange = (positionRangeLowerBound...positionRangeUpperBound).clamped(to: 0...1)
        loop = loopEnabled

    }
}
