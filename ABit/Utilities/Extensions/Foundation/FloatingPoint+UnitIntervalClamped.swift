import Foundation

extension FloatingPoint {
    static var one: Self {
        Self(1)
    }

    func unitIntervalClamped() -> Self {
        clamped(to: Self.zero...Self.one)
    }
}
