import Foundation

extension Collection where Index: BinaryInteger {
    var lastIndex: Self.Index? {
        let index = endIndex-1
        return index >= 0 ? index : nil
    }
}
