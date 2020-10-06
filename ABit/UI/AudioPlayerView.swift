import SwiftUI

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showDocumentPicker = false

    init(audioFilePlayer: AudioFilePlayer) {
        self.audioFilePlayer = audioFilePlayer
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                documentPickerButton
                    .padding(.horizontal)
                Spacer()
                playPauseButton
                stopButton
                loopButton
            }
            playerInfoView(playTimeRange: $audioFilePlayer.playTimeRange.wrappedValue)
            loopRangeSlider
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

            if let fileName = audioFilePlayer.loadedFileUrl?.lastPathComponent {
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
        RangeSlider(range: $audioFilePlayer.playPositionRange)
            .rangeSliderStyle(
                HorizontalRangeSliderStyle(track: Capsule().foregroundColor(.accentColor).frame(height: 8),
                                           lowerThumb: Capsule().foregroundColor(.primary),
                                           upperThumb: Capsule().foregroundColor(.primary),
                                           lowerThumbSize: CGSize(width: 4, height: 32),
                                           upperThumbSize: CGSize(width: 4, height: 32),
                                           options: .forceAdjacentValue
                )
            ).frame(height: 32)
    }

    func playerInfoView(playTimeRange: ClosedRange<Double>?) -> some View {
        HStack {
            if let playheadTime = $audioFilePlayer.playheadTime.wrappedValue {
                let minutes = playheadTime/60
                let seconds = playheadTime.truncatingRemainder(dividingBy: 60)
                let playTimeString = String(format: "%2.0f:%2.3f", minutes, seconds)

                Text(playTimeString)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }
            Spacer()
            if let playTimeRange = playTimeRange {
                let startMinutes = playTimeRange.lowerBound/60
                let startSeconds = playTimeRange.lowerBound.truncatingRemainder(dividingBy: 60)
                let startString = String(format: "%2.0f:%2.1f", startMinutes, startSeconds)

                let endMinutes = playTimeRange.upperBound/60
                let endSeconds = playTimeRange.upperBound.truncatingRemainder(dividingBy: 60)
                let endString = String(format: "%2.0f:%2.1fs", endMinutes, endSeconds)

                HStack(spacing: 4) {
                    Image(systemName: "repeat").font(.system(size: 12, weight: .light))
                    Text("\(startString) -\(endString)")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.light)
                }.foregroundColor(.accentColor)
            }
        }
    }
}

extension AudioPlayerView: AudioFilePickerDelegate {
    func audioFilePicker(_ picker: AudioFilePicker, didPickAudioFileAt url: URL) {
        audioFilePlayer.loadAudioFile(url: url)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(audioFilePlayer: AudioManager().audioFilePlayer(channel: .a))
    }
}
