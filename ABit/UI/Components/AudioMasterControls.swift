import SwiftUI

struct AudioMasterControls: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            playAllButton
            stopAllButton
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
        Button(action: {
            audioManager.stopAll()
        }, label: {
            Image(systemName: "stop")
                .font(.system(size: 20, weight: audioManager.anyPlayerPlaying ? .bold : .light))
                .foregroundColor(.primary)
        })
    }
}

struct AudioMasterControls_Previews: PreviewProvider {
    static var previews: some View {
        let audioPlayerConfigurationManager = DependencyManager().audioPlayerConfigurationManager
        let audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)
        AudioMasterControls(audioManager: audioManager)
    }
}
