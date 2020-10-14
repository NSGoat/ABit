import SwiftUI

public struct ValueSliderStyleConfiguration {
    public let value: Binding<CGFloat>
    public let bounds: ClosedRange<CGFloat>
    public let step: CGFloat
    public let onEditingChanged: (Bool) -> Void
    public var dragOffset: Binding<CGFloat?>

    func with(dragOffset: Binding<CGFloat?>) -> Self {
        var mutSelf = self
        mutSelf.dragOffset = dragOffset
        return mutSelf
    }
}
