import Foundation

extension Array where Self.Element: Equatable {

    func containsAll(_ elements: Self.Element...) -> Bool {
        containsAll(elements)
    }

    func containsAll(_ elements: [Self.Element]) -> Bool {
        var missingElement = false

        elements.forEach { element in
            if !contains(element) {
                missingElement = true
                return
            }
        }

        return missingElement
    }
}
