import SwiftUI

struct ContentView: View {
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .a))
                .accentColor(.green)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .b))
                .accentColor(.orange)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            channelSwitchButton
        }
        .padding(.bottom)
    }

    var channelSwitchButton: some View {
        let channel = audioManager.selectedChannel
        let color = channelColor(channel)

        return Button(action: {
            audioManager.selectedChannel.selectNext()
        }, label: {
            Group {
                Text("A")
                    .font(.title)
                    .fontWeight(channel == .a ? .bold : .light)
                    .foregroundColor(channel == .a ? color : .secondary) +
                Text("/")
                    .font(.title)
                    .foregroundColor(color) +
                Text("B")
                    .font(.title)
                    .fontWeight(channel == .b ? .bold : .light)
                    .foregroundColor(channel == .b ? color : .secondary)
            }
        })
    }

    func channelColor(_ channel: AudioManager.Channel) -> Color {
        switch channel {
        case .a:
            return .green
        case .b:
            return .orange
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioManager: AudioManager())
    }
}
