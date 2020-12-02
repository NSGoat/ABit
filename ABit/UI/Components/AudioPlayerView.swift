import Sliders
import SwiftUI

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showDocumentPicker = false

    private let sliderThumbWidth: CGFloat = 4
    private let waveformHeight: CGFloat = 120
    private let accentColor: Color

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                documentPickerButton
                    .padding(.horizontal)
                Spacer()
                playPauseButton
                stopButton
                loopButton
            }
            playerInfoView(playTimeRange: $audioFilePlayer.playTimeRange.wrappedValue)
        }
    }

    var documentPickerButton: some View {
        Button(action: {
            self.showDocumentPicker.toggle()
            #if targetEnvironment(macCatalyst)
            let viewController = UIApplication.shared.windows[0].rootViewController!
            let picker = AudioDocumentPicker(url: $url)
            viewController.present(picker.viewController, animated: true)
            #endif
        }, label: {

            if let fileName = audioFilePlayer.fileUrl?.lastPathComponent {
                Text(fileName)
            } else {
                Image(systemName: "folder")
            }
        })
        .sheet(isPresented: self.$showDocumentPicker) {
            AudioFilePicker(delegate: self)
        }
    }

    var playPauseButton: some View {
        Button(action: {
            switch audioFilePlayer.playerState {
            case .awaitingFile:
                self.showDocumentPicker.toggle()
            case .stopped:
                audioFilePlayer.play()
            case .paused:
                audioFilePlayer.unpause()
            case .playing:
                audioFilePlayer.pause()
            }
        }, label: {
            Image(systemName: audioFilePlayer.playerState == .playing ? "pause" : "play")
                .font(.system(size: 16, weight: .bold))
        })
    }

    var stopButton: some View {
        Button(action: {
            audioFilePlayer.stop()
        }, label: {
            Image(systemName: "stop")
                .font(.system(size: 16, weight: audioFilePlayer.playerState == .playing ? .bold : .light))
        })
    }

    var loopButton: some View {
        Button(action: {
            audioFilePlayer.loop.toggle()
        }, label: {
            Image(systemName: "repeat")
                .font(.system(size: 16, weight: audioFilePlayer.loop ? .bold : .light))
        })
    }

    var loopRangeSlider: some View {
        let thumbSize = CGSize(width: sliderThumbWidth, height: waveformHeight)
        let thumb = Rectangle().foregroundColor(.primary)
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

    func playerInfoView(playTimeRange: ClosedRange<Double>?) -> some View {
        VStack {
            HStack {
                playTimeText
                Spacer()
                loopTimeRangeText
            }
            ZStack {
                if let image = audioFilePlayer.image {
                    GeometryReader { geo in
                        Image(uiImage: image)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(accentColor)
                            .frame(width: geo.size.width - sliderThumbWidth * 2)
                            .padding(.horizontal, sliderThumbWidth)
                            .disabled(true)
                        }
                }
                if audioFilePlayer.renderingImage {
                    Rectangle()
                        .fill(accentColor)
                        .cornerRadius(4)
                        .opacity(0.2)
//                        .opacity(loadingAnimation ? 0.2 : 0.0)
//                        .animation(Animation.easeInOut(duration: 0.5).repeatForever())
                }
                playheadView
                    .padding(.horizontal, sliderThumbWidth)
                loopRangeSlider
            }
            .frame(height: waveformHeight)
            .scaledToFill()
//            .onAppear {
//                loadingAnimation = true
//            }
        }
    }

    @State private var loadingAnimation = false

    var playTimeText: some View {
        if let playheadTime = $audioFilePlayer.playheadTime.wrappedValue {
            let minutes = playheadTime/60
            let seconds = playheadTime.truncatingRemainder(dividingBy: 60)
            let playTimeString = String(format: "%2.0f:%2.3f", minutes, seconds)

            return AnyView(Text(playTimeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.accentColor))
        } else {
            return AnyView(EmptyView())
        }
    }

    var loopTimeRangeText: some View {
        if let playTimeRange = $audioFilePlayer.playTimeRange.wrappedValue {
            let startMinutes = playTimeRange.lowerBound/60
            let startSeconds = playTimeRange.lowerBound.truncatingRemainder(dividingBy: 60)
            let startString = String(format: "%2.0f:%2.1f", startMinutes, startSeconds)

            let endMinutes = playTimeRange.upperBound/60
            let endSeconds = playTimeRange.upperBound.truncatingRemainder(dividingBy: 60)
            let endString = String(format: "%2.0f:%2.1fs", endMinutes, endSeconds)

            return AnyView(HStack(spacing: 4) {
                Image(systemName: "repeat").font(.system(size: 12, weight: .light))
                Text("\(startString) -\(endString)")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.light)
            }.foregroundColor(.accentColor))
        } else {
            return AnyView(EmptyView())
        }
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
        let thumb = Capsule().foregroundColor(.primary).opacity(0.7).frame(height: waveformHeight)
        let thumbSize = CGSize(width: 1, height: waveformHeight)

        return ValueSlider(value: playheadPosition)
            .valueSliderStyle(
                HorizontalValueSliderStyle(track: EmptyView(), thumb: thumb, thumbSize: thumbSize))
            .disabled(true)
    }
}

extension AudioPlayerView: AudioFilePickerDelegate {
    func audioFilePicker(_ picker: AudioFilePicker, didPickAudioFileAt url: URL) {
        audioFilePlayer.loadAudioFile(url: url)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(audioFilePlayer: AudioManager().audioFilePlayer(channel: .a), accentColor: .accentColor)
    }
}