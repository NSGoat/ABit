import SwiftUI

struct ContentView: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image("HeaderIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    audioManager.selectedChannel?.selectNext()
                }
            Spacer()
            audioPlayerView(channel: .a)
            audioPlayerView(channel: .b)
            AudioMasterControls(audioManager: audioManager)
        }
        .padding(.bottom)
    }

    func audioPlayerView(channel: AudioChannel) -> some View {
        AudioPlayerView(
            audioFilePlayer: audioManager.audioFilePlayer(channel: channel),
            accentColor: channel.color,
            tapAction: {
                audioManager.selectedChannel = channel
            })
            .accentColor(channel.color)
            .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioManager: AudioManager(playConfigurationManager: DependencyManager.shared.playConfigurationManager))
    }
}
