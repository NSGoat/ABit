import SwiftUI

struct ContentView: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        Spacer()
        VStack {
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .a))
                .accentColor(.green)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .b))
                .accentColor(.orange)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
        .padding(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioManager: AudioManager())
    }
}
