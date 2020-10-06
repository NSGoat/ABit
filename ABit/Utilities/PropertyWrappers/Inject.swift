import Foundation

protocol Injectable {}

@propertyWrapper
struct Inject<T: Injectable> {
    let wrappedValue: T

    init() {
        wrappedValue = Resolver.shared.resolve()
    }
}

class Resolver {

    private var storage = [String: Injectable]()

    static let shared = Resolver()
    private init() {}

    func add<T: Injectable>(_ injectable: T) {
        let key = String(reflecting: injectable)
        storage[key] = injectable
    }

    func resolve<T: Injectable>() -> T {
        let key = String(reflecting: T.self)

        guard let injectable = storage[key] as? T else {
            fatalError("\(key) has not been added as an injectable object.")
        }

        return injectable
    }
}
