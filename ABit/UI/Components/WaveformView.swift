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
        GeometryReader { geometry in
            if audioFilePlayer.state == .loading {
                loadingView
            } else if let image = audioFilePlayer.image, audioFilePlayer.state != .awaitingFile {
                let color = highlightPlayer ? .primary : accentColor
                audioView(geometry: geometry, waveformImage: image, waveformColor: color)
                    .animation(.easeInOut(duration: 0.1))
            } else {
                folderImage
            }
        }
        .background(accentColor.opacity(0.1))
        .cornerRadius(sliderThumbWidth/2.0)
        .frame(height: waveformHeight)
        .onAppear {
            loadingAnimation = true
        }
    }

    fileprivate func audioView(geometry: GeometryProxy, waveformImage: UIImage, waveformColor: Color) -> some View {
        ZStack {
            loopRangeRectangle(geometry: geometry, sliderThumbWidth: sliderThumbWidth, selectedRange: playtimeRange)
            Image(uiImage: waveformImage)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(waveformColor)
                .frame(width: geometry.size.width - sliderThumbWidth * 2)
                .padding(.horizontal, sliderThumbWidth)
                .disabled(true)
                .accessibility(identifier: "audio_waveform_image")
                .accessibility(addTraits: .isButton)
                .onTapGesture {
                    tapAction()
                }
            playheadView
                .padding(.horizontal, sliderThumbWidth)
            loopRangeSlider
        }
    }

    private var loadingView: some View {
        Rectangle()
            .fill(accentColor)
            .cornerRadius(4)
            .opacity(loadingAnimation ? 0.2 : 0.0)
            .animation(Animation.easeInOut(duration: 0.5).repeatForever())
    }

    private var folderImage: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "folder")
                    .renderingMode(.template)
                    .foregroundColor(accentColor)
                Spacer()
            }
            Spacer()
        }
        .accessibility(identifier: "load_folder_image")
    }

    private var loopRangeSlider: some View {
        let thumbSize = CGSize(width: sliderThumbWidth, height: waveformHeight)
        let thumb = Rectangle().foregroundColor(accentColor)
        let lowerThumb = thumb.cornerRadius(sliderThumbWidth, corners: [.topLeft, .bottomLeft])
            .accessibility(identifier: "start_position_slider_thumb")
        let upperThumb = thumb.cornerRadius(sliderThumbWidth, corners: [.topRight, .bottomRight])
            .accessibility(identifier: "end_position_slider_thumb")

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
            .accessibility(identifier: "play_range_slider")
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
