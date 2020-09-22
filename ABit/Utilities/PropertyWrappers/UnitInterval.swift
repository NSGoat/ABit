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
