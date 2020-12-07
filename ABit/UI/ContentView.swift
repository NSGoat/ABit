import SwiftUI

struct ContentView: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .a),
                            accentColor: AudioChannel.a.color)
                .accentColor(AudioChannel.a.color)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .b),
                            accentColor: AudioChannel.b.color)
                .accentColor(AudioChannel.b.color)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            AudioMasterControls(audioManager: audioManager)
        }
        .padding(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioManager: AudioManager(audioFileManager: DependencyManager.shared.audioFileManager))
    }
}
