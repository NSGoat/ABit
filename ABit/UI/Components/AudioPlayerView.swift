import Foundation
import Sliders
import SwiftUI

typealias TapAction = () -> Void

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showDocumentPicker = false

    private let sliderThumbWidth: CGFloat = 16
    private let waveformHeight: CGFloat = 120
    private let accentColor: Color
    private let tapAction: TapAction

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, tapAction: @escaping TapAction) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
        self.tapAction = tapAction
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                documentPickerButton
                Spacer(minLength: 12)
                playPauseButton
                stopButton
                loopButton
            }
            playerInfoView(playTimeRange: $audioFilePlayer.playTimeRange.wrappedValue)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            tapAction()
            if audioFilePlayer.state == .awaitingFile {
                self.showDocumentPicker.toggle()
            }
        }
        .sheet(isPresented: self.$showDocumentPicker) {
            AudioFilePicker(delegate: self)
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
    }

    var playPauseButton: some View {
        Button(action: {
            switch audioFilePlayer.state {
            case .awaitingFile:
                self.showDocumentPicker.toggle()
            case .loading:
                break
            case .stopped:
                audioFilePlayer.play()
            case .paused:
                audioFilePlayer.unpause()
            case .playing:
                audioFilePlayer.pause()
            }
        }, label: {
            Image(systemName: audioFilePlayer.state == .playing ? "pause" : "play")
                .font(.system(size: 16, weight: .bold))
        })
    }

    var stopButton: some View {
        Button(action: {
            audioFilePlayer.stop()
        }, label: {
            Image(systemName: "stop")
                .font(.system(size: 16, weight: audioFilePlayer.state == .playing ? .bold : .light))
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

    func playerInfoView(playTimeRange: ClosedRange<Double>?) -> some View {
        let highlightPlayer = audioFilePlayer.mute && audioFilePlayer.state != .awaitingFile

        return VStack {
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
                            .foregroundColor(highlightPlayer ? accentColor : .black)
                            .frame(width: geo.size.width - sliderThumbWidth * 2)
                            .padding(.horizontal, sliderThumbWidth)
                            .disabled(true)
                    }
                }
                if audioFilePlayer.renderingImage {
                    Rectangle()
                        .fill(accentColor)
                        .cornerRadius(4)
                        .opacity(loadingAnimation ? 0.2 : 0.0)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever())
                }
                playheadView
                    .padding(.horizontal, sliderThumbWidth)
                loopRangeSlider
            }
            .background(accentColor.opacity(highlightPlayer ? 0.0 : 0.15))
            .cornerRadius(sliderThumbWidth/2.0)
            .frame(height: waveformHeight)
            .scaledToFill()
            .onAppear {
                loadingAnimation = true
            }
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
        let thumb = Capsule().foregroundColor(accentColor).frame(height: waveformHeight)
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
        let audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "Conf")
        let audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)
        AudioPlayerView(
            audioFilePlayer: audioManager.audioFilePlayer(channel: .a),
            accentColor: .accentColor,
            tapAction: { })
    }
}
