import SwiftUI
import Combine

class SliderHandle: ObservableObject {

    let width: CGFloat = 320
    let height: CGFloat = 8

    let minimumValue: Double
    let valueRange: Double

    var startLocation: CGPoint

    @Published var onDrag: Bool
    @Published var currentLocation: CGPoint
    @Published var currentPercentage: UnitInterval

    var currentValue: Double {
        return minimumValue + currentPercentage.wrappedValue * valueRange
    }

    init(startValue: Double,
         endValue: Double,
         startPercentage: UnitInterval) {

        self.minimumValue = startValue
        self.valueRange = endValue - startValue

        let startLocation = CGPoint(x: (CGFloat(startPercentage.wrappedValue)/1.0)*width, y: height/2)
        self.startLocation = startLocation
        self.currentLocation = startLocation
        self.currentPercentage = startPercentage

        self.onDrag = false
    }

    lazy var sliderDragGesture: _EndedGesture<_ChangedGesture<DragGesture>>  = DragGesture()
        .onChanged { value in
            self.onDrag = true

            let dragLocation = value.location

            // Restrict possible drag area
            self.constrainDragArea(dragLocation)

            //Get current value
            self.currentPercentage.wrappedValue = Double(self.currentLocation.x / self.width)

        }.onEnded { _ in
            self.onDrag = false
        }

    private func constrainDragArea(_ dragLocation: CGPoint) {
        //On Slider Width
        if dragLocation.x > CGPoint.zero.x && dragLocation.x < width {
            currentLocation = currentLocation(forDragLocation: dragLocation)
        }
    }

    private func currentLocation(forDragLocation dragLocation: CGPoint) -> CGPoint {
        if dragLocation.y != height/2 {
            return CGPoint(x: dragLocation.x, y: height/2)
        } else {
            return dragLocation
        }
    }
}

class RangeSlider: ObservableObject {

    final let minimum: Double = 0
    final let maximum: Double = 1

    let width: CGFloat = 320
    let height: CGFloat = 8

    @Published var highHandle: SliderHandle
    @Published var lowHandle: SliderHandle

    @UnitInterval var lowHandleStartPercentage = 0.0
    @UnitInterval var highHandleStartPercentage = 1.0

    final var anyCancellableLow: AnyCancellable?
    final var anyCancellableHigh: AnyCancellable?

    init(lowValue: Double, highValue: Double) {
        lowHandleStartPercentage = lowValue
        highHandleStartPercentage = highValue

        lowHandle = SliderHandle(startValue: minimum, endValue: maximum, startPercentage: _lowHandleStartPercentage)
        highHandle = SliderHandle(startValue: minimum, endValue: maximum, startPercentage: _highHandleStartPercentage)

        anyCancellableLow = lowHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }
}
