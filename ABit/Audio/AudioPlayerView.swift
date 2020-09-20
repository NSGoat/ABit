import SwiftUI

struct AudioPlayerView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer

    @State var showDocumentPicker = false

    @State var url: URL?

    var body: some View {
        return HStack {
            muteButton
            Spacer()
            documentPickerButton
                .padding(.horizontal)
            Spacer()
            playButton
            stopButton
        }
    }

    var documentPickerButton: some View {
        Button(action: {
            self.showDocumentPicker.toggle()
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
            audioFilePlayer.playAudioFile(url: url)
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
