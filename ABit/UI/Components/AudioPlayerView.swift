import Foundation
import Sliders
import SwiftUI

typealias TapAction = () -> Void

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showDocumentPicker = false

    private let accentColor: Color
    private let tapAction: TapAction

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, tapAction: @escaping TapAction) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
        self.tapAction = tapAction
    }

    var body: some View {
        VStack {
            HStack {
                playTimeText
                Spacer(minLength: 16)
                AudioPlayerControls(audioFilePlayer: audioFilePlayer,
                                    accentColor: accentColor,
                                    showDocumentPicker: $showDocumentPicker)
            }
            WaveformView(audioFilePlayer: audioFilePlayer, accentColor: accentColor, tapAction: tapAction)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            print("WaveformView tapped")
                            if audioFilePlayer.state == .awaitingFile {
                                self.showDocumentPicker.toggle()
                            }
                        }
                )
            documentPickerButton
        }
        .contentShape(Rectangle())
        .sheet(isPresented: self.$showDocumentPicker) {
            AudioFilePicker(delegate: self)
        }
    }

    private var documentPickerButton: some View {
        Button(action: {
            self.$showDocumentPicker.wrappedValue.toggle()
        }, label: {
            if let fileName = audioFilePlayer.bookmarkUrl?.lastPathComponent {
                Text(fileName)
                    .allowsTightening(true)
            }
        })
    }

    private var playTimeText: Text {
        if [.paused, .playing, .stopped].contains(audioFilePlayer.state) {
            let playheadTime = $audioFilePlayer.playheadTime.wrappedValue ?? 0
            let minutes = playheadTime/60
            let seconds = playheadTime.truncatingRemainder(dividingBy: 60)
            let playTimeString = String(format: "%2.0f:%2.2f", minutes, seconds)

            return Text(playTimeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        } else {
            return Text("")
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
        let audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "Conf")
        let audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)

        AudioPlayerView(
            audioFilePlayer: audioManager.audioFilePlayer(channel: .a),
            accentColor: .accentColor,
            tapAction: { })
    }
}
