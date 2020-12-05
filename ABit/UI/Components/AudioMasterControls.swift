import SwiftUI

struct AudioMasterControls: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            playAllButton
            stopAllButton
            Spacer()
            channelSwitchButton
            Spacer()
        }
    }

    private var playAllButton: some View {
        return Button(action: {
            if audioManager.anyPlayerPlaying {
                audioManager.pauseAll()
            } else {
                audioManager.playAll()
            }

        }, label: {
            Image(systemName: audioManager.anyPlayerPlaying ? "pause" : "play")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
        })
    }

    private var stopAllButton: some View {
        return Button(action: {
            audioManager.stopAll()
        }, label: {
            Image(systemName: "stop")
                .font(.system(size: 20, weight: audioManager.anyPlayerPlaying ? .bold : .light))
                .foregroundColor(.primary)
        })
    }

    private var channelSwitchButton: some View {
        let channel = audioManager.selectedChannel
        let color = channel.color

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
}

struct AudioMasterControls_Previews: PreviewProvider {
    static var previews: some View {
        AudioMasterControls(audioManager: AudioManager(dependencyManager: DependencyManager.shared))
    }
}
