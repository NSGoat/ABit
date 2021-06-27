import Foundation

extension ClosedRange where Bound: FloatingPoint {

    var size: Bound {
        return upperBound - lowerBound
    }
}
