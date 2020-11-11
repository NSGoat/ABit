import Foundation

extension Hasher {
    static func hashObject(combining hashables: AnyHashable...) -> AnyObject {
        let hashValue = hash(combining: hashables)
        return NSNumber(value: hashValue)
    }

    static func hash(combining hashables: AnyHashable...) -> Int {
        var hasher = Hasher()

        hashables.forEach {
            hasher.combine($0)
        }

        return hasher.finalize()
    }
}
