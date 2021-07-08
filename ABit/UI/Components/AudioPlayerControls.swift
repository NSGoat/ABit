import SwiftUI

struct AudioPlayerControls: View {

    @ObservedObject var player: AudioFilePlayer

    var showDocumentPicker: Binding<Bool>

    private let accentColor: Color

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, showDocumentPicker: Binding<Bool>) {
        self.player = audioFilePlayer
        self.accentColor = accentColor
        self.showDocumentPicker = showDocumentPicker
    }

    var body: some View {
        HStack(spacing: 16) {
            Spacer(minLength: 12)
            playPauseButton
            stopButton
            loopButton
            ejectButton
        }
    }

    private var playPauseButton: some View {
        Button(action: {
            switch player.state {
            case .awaitingFile:
                self.showDocumentPicker.wrappedValue.toggle()
            case .loading:
                break
            case .stopped:
                player.play()
            case .paused:
                player.unpause()
            case .playing:
                player.pause()
            }
        }, label: {
            Image(systemName: player.isPlaying ? "pause" : "play")
                .font(.system(size: 20, weight: .medium))
        })
        .accessibility(identifier: "play_pause_player_button")
        .accessibility(value: Text(player.isPlaying ? "play" : "pause"))
    }

    private var stopButton: some View {
        Button(action: {
            player.stop()
        }, label: {
            Image(systemName: "stop")
                .font(.system(size: 20, weight: player.isPlaying ? .medium : .light))
        })
        .accessibility(identifier: "stop_button")
    }

    private var loopButton: some View {
        Button(action: {
            player.loop.toggle()
        }, label: {
            Image(systemName: "repeat")
                .font(.system(size: 20, weight: player.loop ? .medium : .light))
        })
        .accessibility(identifier: "loop_button")
    }

    private var ejectButton: some View {
        Button(action: {
            player.unloadPlayer()
        }, label: {
            Image(systemName: "eject")
                .font(.system(size: 20, weight: .light))
        })
        .accessibility(identifier: "eject_button")
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
