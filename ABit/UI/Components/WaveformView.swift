import Sliders
import SwiftUI

struct WaveformView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer
    @State private var loadingAnimation = false

    private let sliderThumbWidth: CGFloat = 16
    private let waveformHeight: CGFloat = 120
    private let accentColor: Color
    private let tapAction: TapAction
    private var highlightPlayer: Bool { audioFilePlayer.state != .awaitingFile && !audioFilePlayer.mute }
    private var playtimeRange: ClosedRange<Double> { audioFilePlayer.playPositionRange }

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, tapAction: @escaping TapAction) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
        self.tapAction = tapAction
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if let image = audioFilePlayer.image {
                    loopRangeRectangle(geometry: geometry, sliderThumbWidth: sliderThumbWidth, selectedRange: playtimeRange)
                    waveformImage(uiImage: image, color: highlightPlayer ? .black : accentColor)
                        .frame(width: geometry.size.width - sliderThumbWidth * 2)
                        .padding(.horizontal, sliderThumbWidth)

                }
                if audioFilePlayer.renderingImage {
                    Rectangle()
                        .fill(accentColor)
                        .cornerRadius(4)
                        .opacity(loadingAnimation ? 0.2 : 0.0)
                        .animation(Animation.easeInOut(duration: 0.2).repeatForever())
                } else if audioFilePlayer.image != nil && audioFilePlayer.state != .awaitingFile {
                    playheadView
                        .padding(.horizontal, sliderThumbWidth)
                    loopRangeSlider
                }
            }
        }
        .background(accentColor.opacity(0.1))
        .cornerRadius(sliderThumbWidth/2.0)
        .frame(height: waveformHeight)
        .scaledToFill()
        .onAppear {
            loadingAnimation = true
        }
    }

    private func loopRangeRectangle(geometry: GeometryProxy,
                                    sliderThumbWidth: CGFloat,
                                    selectedRange: ClosedRange<Double>) -> some View {
        Rectangle()
            .fill(accentColor)
            .opacity(highlightPlayer ? 0.3 : 0.0)
            .padding(horizontalInsets(dimension: geometry.size.width - sliderThumbWidth,
                                      scaledByRange: selectedRange))
            .disabled(true)
    }
    private func waveformImage(uiImage: UIImage, color: Color) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(color)
            .disabled(true)
    }

    private var loopRangeSlider: some View {
        let thumbSize = CGSize(width: sliderThumbWidth, height: waveformHeight)
        let thumb = Rectangle().foregroundColor(accentColor)
        let lowerThumb = thumb.cornerRadius(sliderThumbWidth, corners: [.topLeft, .bottomLeft])
        let upperThumb = thumb.cornerRadius(sliderThumbWidth, corners: [.topRight, .bottomRight])

        return RangeSlider(range: $audioFilePlayer.playPositionRange)
            .rangeSliderStyle(
                HorizontalRangeSliderStyle(track: Rectangle().hidden(),
                                           lowerThumb: lowerThumb,
                                           upperThumb: upperThumb,
                                           lowerThumbSize: thumbSize,
                                           upperThumbSize: thumbSize,
                                           options: .forceAdjacentValue
                )
            )
    }

    private var playheadView: some View {
        if let playheadPositionBinding = Binding($audioFilePlayer.playheadPosition) {
            return AnyView(playheadView(playheadPosition: playheadPositionBinding,
                                        waveformHeight: waveformHeight,
                                        thumbSize: CGSize(width: 1, height: waveformHeight)))
        } else {
            return AnyView(EmptyView())
        }
    }

    private func playheadView(playheadPosition: Binding<Double>, waveformHeight: CGFloat, thumbSize: CGSize) -> some View {
        let thumb = Capsule().foregroundColor(accentColor).frame(height: waveformHeight)
        let thumbSize = CGSize(width: 1, height: waveformHeight)

        return ValueSlider(value: playheadPosition)
            .valueSliderStyle(
                HorizontalValueSliderStyle(track: EmptyView(), thumb: thumb, thumbSize: thumbSize))
            .disabled(true)
    }

    private func horizontalInsets(dimension: CGFloat, scaledByRange range: ClosedRange<Double>) -> EdgeInsets {
        EdgeInsets(top: 0,
                   leading: dimension * CGFloat(range.lowerBound),
                   bottom: 0,
                   trailing: dimension * CGFloat(1 - range.upperBound))
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        let audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "Conf")
        let audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)
        WaveformView(
            audioFilePlayer: audioManager.audioFilePlayer(channel: .a),
            accentColor: .accentColor,
            tapAction: { })
    }
}
