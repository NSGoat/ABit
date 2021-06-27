import Sliders
import SwiftUI

struct WaveformView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State private var loadingAnimation = false

    private let sliderThumbWidth: CGFloat = 16
    private let waveformHeight: CGFloat = 120
    private let accentColor: Color
    private let tapAction: TapAction

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, tapAction: @escaping TapAction) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
        self.tapAction = tapAction
    }

    var highlightPlayer: Bool { audioFilePlayer.mute && audioFilePlayer.state != .awaitingFile }
    var playtimeRange: ClosedRange<Double> { audioFilePlayer.playPositionRange }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Rectangle()
                    .fill(accentColor)
                    .opacity(highlightPlayer ? 0.0 : 0.3)
                    .padding(horizontalInsets(dimension: geometry.size.width - sliderThumbWidth,
                                              scaledByRange: audioFilePlayer.playPositionRange))
                    .disabled(true)
            }
            if let image = audioFilePlayer.image {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(highlightPlayer ? accentColor : .black)
                        .frame(width: geometry.size.width - sliderThumbWidth * 2)
                        .padding(.horizontal, sliderThumbWidth)
                        .disabled(true)
//                    Image(uiImage: image)
//                        .resizable()
//                        .renderingMode(.template)
//                        .foregroundColor(.black)
//                        .frame(width: geometry.size.width - sliderThumbWidth * 2)
//                        .padding(horizontalInsets(dimension: geometry.size.width - sliderThumbWidth,
//                                                  scaledByRange: audioFilePlayer.playPositionRange))
//                        .disabled(true)
                }
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
        .background(accentColor.opacity(0.1))
        .cornerRadius(sliderThumbWidth/2.0)
        .frame(height: waveformHeight)
        .scaledToFill()
        .onAppear {
            loadingAnimation = true
        }
    }

    var loopRangeSlider: some View {
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

    var playheadView: some View {
        if let playheadPositionBinding = Binding($audioFilePlayer.playheadPosition) {
            return AnyView(playheadView(playheadPosition: playheadPositionBinding,
                                        waveformHeight: waveformHeight,
                                        thumbSize: CGSize(width: 1, height: waveformHeight)))
        } else {
            return AnyView(EmptyView())
        }
    }

    func playheadView(playheadPosition: Binding<Double>, waveformHeight: CGFloat, thumbSize: CGSize) -> some View {
        let thumb = Capsule().foregroundColor(accentColor).frame(height: waveformHeight)
        let thumbSize = CGSize(width: 1, height: waveformHeight)

        return ValueSlider(value: playheadPosition)
            .valueSliderStyle(
                HorizontalValueSliderStyle(track: EmptyView(), thumb: thumb, thumbSize: thumbSize))
            .disabled(true)
    }

    func horizontalInsets(dimension: CGFloat, scaledByRange range: ClosedRange<Double>) -> EdgeInsets {
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
