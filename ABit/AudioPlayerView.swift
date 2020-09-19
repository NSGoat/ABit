import SwiftUI

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showPicker = false

    @State var mute = false

    @State var url: URL?

    let weightFont = Font.title.weight(.semibold)

    var body: some View {
        return HStack {
            muteButton
            Spacer()
            documentPickerButton
            Spacer()
            playButton
            stopButton
        }
    }

    var documentPickerButton: some View {
        Button {
            self.showPicker.toggle()
        } label: {
            if let fileName = url?.lastPathComponent {
                Text(fileName)
            } else {
                Image(systemName: "folder")
            }
        }
        .sheet(isPresented: self.$showPicker) {
            AudioDocumentPicker(url: $url)
        }
    }

    var playButton: Button<Image> {
        Button(action: {
            audioFilePlayer.playAudioFile(url: url)
        }) {
            Image(systemName: "play")
        }
    }

    var stopButton: Button<Image> {
        Button(action: {
            audioFilePlayer.stop()
        }) {
            Image(systemName: "stop")
        }
    }

    var muteButton: some View {
        Button(action: {
            audioFilePlayer.muted = !audioFilePlayer.muted
        }) {
            Text(audioFilePlayer.name.uppercased())
                .font(.title)
                .fontWeight(audioFilePlayer.muted ? .regular : .bold)
        }

    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(audioFilePlayer: AudioManager().audioFilePlayer(channel: .a))
    }
}
