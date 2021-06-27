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
            AudioPlayerControls(audioFilePlayer: audioFilePlayer,
                                accentColor: accentColor,
                                showDocumentPicker: $showDocumentPicker)
            AudioPlayerInfoView(audioFilePlayer: audioFilePlayer,
                                accentColor: accentColor,
                                tapAction: tapAction)
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
