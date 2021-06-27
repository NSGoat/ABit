import SwiftUI

struct AudioPlayerControls: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    var showDocumentPicker: Binding<Bool>

    private let accentColor: Color

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, showDocumentPicker: Binding<Bool>) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
        self.showDocumentPicker = showDocumentPicker
    }

    var body: some View {
        HStack(spacing: 16) {
            Spacer(minLength: 12)
            playPauseButton
            stopButton
            loopButton
        }
    }

    private var playPauseButton: some View {
        Button(action: {
            switch audioFilePlayer.state {
            case .awaitingFile:
                self.showDocumentPicker.wrappedValue.toggle()
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

    private var stopButton: some View {
        Button(action: {
            audioFilePlayer.stop()
        }, label: {
            Image(systemName: "stop")
                .font(.system(size: 16, weight: audioFilePlayer.state == .playing ? .bold : .light))
        })
    }

    private var loopButton: some View {
        Button(action: {
            audioFilePlayer.loop.toggle()
        }, label: {
            Image(systemName: "repeat")
                .font(.system(size: 16, weight: audioFilePlayer.loop ? .bold : .light))
        })
    }
}

struct AudioPlayerControls_Previews: PreviewProvider {

    @State static var showDocumentPicker: Bool = false

    static var previews: some View {
        let audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "Conf")
        let audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)

        AudioPlayerControls(
            audioFilePlayer: audioManager.audioFilePlayer(channel: .a),
            accentColor: .accentColor,
            showDocumentPicker: $showDocumentPicker
        )
    }
}
