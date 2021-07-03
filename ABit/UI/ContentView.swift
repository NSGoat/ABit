import SwiftUI

struct ContentView: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            LogoToggleButton(audioManager: audioManager)
                .frame(minWidth: 80, maxWidth: 300, minHeight: 80, maxHeight: 300, alignment: .center)
            audioPlayerView(channel: .a)
            audioPlayerView(channel: .b)
            AudioMasterControls(audioManager: audioManager)
            Spacer()
        }
        .padding(.bottom, 16)
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
        let audioPlayerConfigurationManager = DependencyManager.shared.audioPlayerConfigurationManager
        ContentView(audioManager: AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager))
    }
}
