import SwiftUI

struct RangeSliderView: View {
    @ObservedObject var slider: RangeSlider

    var body: some View {
        RoundedRectangle(cornerRadius: slider.height)
            .fill(Color.gray.opacity(0.2))
            .frame(width: slider.width, height: slider.height)
            .overlay(
                ZStack {
                    SliderPathBetweenView(slider: slider)

                    SliderHandleView(handle: slider.lowHandle)
                        .highPriorityGesture(slider.lowHandle.sliderDragGesture)

                    SliderHandleView(handle: slider.highHandle)
                        .highPriorityGesture(slider.highHandle.sliderDragGesture)
                }
            )
    }
}

struct SliderHandleView: View {
    @ObservedObject var handle: SliderHandle

    var body: some View {

        Rectangle()
            .frame(width: 4, height: handle.height)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
            .scaleEffect(handle.onDrag ? 1.3 : 1)
            .contentShape(Rectangle())
            .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
            .cornerRadius(2)
    }
}

struct SliderPathBetweenView: View {
    @ObservedObject var slider: RangeSlider

    var body: some View {
        Path { path in
            path.move(to: slider.lowHandle.currentLocation)
            path.addLine(to: slider.highHandle.currentLocation)
        }
        .stroke(Color.accentColor, lineWidth: slider.height)
    }
}
