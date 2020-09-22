import SwiftUI

struct ContentView: View {
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .a))
                .accentColor(channelColor(.a))
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            AudioPlayerView(audioFilePlayer: audioManager.audioFilePlayer(channel: .b))
                .accentColor(channelColor(.b))
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

    func channelColor(_ channel: AudioChannel) -> Color {
        switch channel {
        case .a:
            return Color(red: 0, green: 172/255, blue: 84/255)
        case .b:
            return Color(red: 253/255, green: 141/255, blue: 15/255)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioManager: AudioManager())
    }
}
