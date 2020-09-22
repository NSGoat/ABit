import SwiftUI

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showDocumentPicker = false

    @State var url: URL?

    @ObservedObject var slider: RangeSlider

    init(audioFilePlayer: AudioFilePlayer) {
        self.audioFilePlayer = audioFilePlayer

        slider = RangeSlider(lowValue: audioFilePlayer.playback.startPosition,
                             highValue: audioFilePlayer.playback.endPosition ?? 1)
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                documentPickerButton
                    .padding(.horizontal)
                Spacer()
                playButton
                stopButton
                loopButton
            }
            RangeSliderView(slider: slider)
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
            if let fileName = url?.lastPathComponent {
                Text(fileName)
            } else {
                Image(systemName: "folder")
            }
        })
        .sheet(isPresented: self.$showDocumentPicker) {
            AudioDocumentPicker(url: $url)
        }
    }

    var playButton: Button<Image> {
        Button(action: {
            let playbackSettings = PlaybackSettings(startPosition: slider.lowHandle.currentValue,
                                                    endPosition: slider.highHandle.currentValue,
                                                    loop: audioFilePlayer.playback.loop)
            audioFilePlayer.playAudioFile(url: url, settings: playbackSettings)
        }, label: {
            Image(systemName: "play")
        })
    }

    var stopButton: Button<Image> {
        Button(action: {
            audioFilePlayer.stop()
        }, label: {
            Image(systemName: "stop")
        })
    }

    var loopButton: some View {
        Button(action: {
            audioFilePlayer.playback.loop.toggle()
        }, label: {
            Image(systemName: "repeat")
                .font(.system(size: 16, weight: audioFilePlayer.playback.loop ? .bold : .ultraLight))
        })
    }

    var muteButton: some View {
        Button(action: {
            audioFilePlayer.muted.toggle()
        }, label: {
            Text(audioFilePlayer.name.uppercased())
                .font(.title)
                .fontWeight(audioFilePlayer.muted ? .ultraLight : .bold)
        })
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(audioFilePlayer: AudioManager().audioFilePlayer(channel: .a))
    }
}
