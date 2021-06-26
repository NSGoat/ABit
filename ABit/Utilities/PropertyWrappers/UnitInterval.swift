import Foundation

/// Clamp in range 0.0 to 1.0
@propertyWrapper
struct UnitInterval {

    init(wrappedValue: Double) {
        self.wrappedValue = wrappedValue
    }

    var wrappedValue: Double {
        didSet {
            wrappedValue = min(max(0.0, wrappedValue), 1.0)
        }
    }
}

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

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension FloatingPoint {
    static var one: Self {
        Self(1)
    }

    func clampedUnitInterval() -> Self {
        clamped(to: Self.zero...Self.one)
    }
}

struct UnitIntervalRangeB<Bound> where Bound: FloatingPoint {
    init(_ value: ClosedRange<Bound>) {

    }
}
