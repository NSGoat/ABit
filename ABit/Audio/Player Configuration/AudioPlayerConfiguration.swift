import Foundation

struct AudioPlayerConfiguration: Codable {

    struct Trigger: Codable {
        enum Mode: String, Codable {
            case sync
            case cue
        }

        var mode: Mode = .cue
        var loop: Bool = true

        @UnitIntervalRange
        var positionRange: ClosedRange<Double> = 0...1 {
            didSet {
                positionRange = positionRange.clamped(to: 0...1)
            }
        }
    }

    var fileUrl: URL
    var triggers: [Trigger]
}
