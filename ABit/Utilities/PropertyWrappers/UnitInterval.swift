import Foundation

/// Clamp value to 0.0 to 1.0
@propertyWrapper
struct UnitInterval<Type> where Type: FloatingPoint {

    init(wrappedValue: Type) {
        self.wrappedValue = wrappedValue
    }

    var wrappedValue: Type {
        didSet {
            wrappedValue = wrappedValue.unitIntervalClamped()
        }
    }
}

/// Clamp range to 0.0 to 1.0
@propertyWrapper
struct UnitIntervalRange<Bound> where Bound: FloatingPoint {

    init(wrappedValue: ClosedRange<Bound>) {
        self.wrappedValue = wrappedValue
    }

    var wrappedValue: ClosedRange<Bound> {
        didSet {
            wrappedValue = wrappedValue.clamped(to: Bound.zero...Bound.one)
        }
    }
}

extension UnitIntervalRange: Codable where Bound == Double {

    enum CodingKeys: String, CodingKey {
        case upperBound
        case lowerBound
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wrappedValue.lowerBound, forKey: .lowerBound)
        try container.encode(wrappedValue.upperBound, forKey: .upperBound)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lowerBound = try values.decode(Double.self, forKey: .lowerBound)
        let upperBound = try values.decode(Double.self, forKey: .upperBound)

        wrappedValue = lowerBound...upperBound
    }
}
