import SwiftUI

struct AudioPlayerInfoView: View {

    @ObservedObject var audioFilePlayer: AudioFilePlayer
    private let tapAction: TapAction
    private let accentColor: Color

    init(audioFilePlayer: AudioFilePlayer, accentColor: Color, tapAction: @escaping TapAction) {
        self.audioFilePlayer = audioFilePlayer
        self.accentColor = accentColor
        self.tapAction = tapAction
    }

    var body: some View {
        VStack {
            HStack {
                playTimeText
                Spacer()
                loopTimeRangeText
            }
            WaveformView(audioFilePlayer: audioFilePlayer, accentColor: accentColor, tapAction: tapAction)
        }
    }

    private var playTimeText: some View {
        if let playheadTime = $audioFilePlayer.playheadTime.wrappedValue {
            let minutes = playheadTime/60
            let seconds = playheadTime.truncatingRemainder(dividingBy: 60)
            let playTimeString = String(format: "%2.0f:%2.3f", minutes, seconds)

            return AnyView(Text(playTimeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.accentColor))
        } else {
            return AnyView(EmptyView())
        }
    }

    private var loopTimeRangeText: some View {
        if let playTimeRange = $audioFilePlayer.playTimeRange.wrappedValue {
            let startMinutes = playTimeRange.lowerBound/60
            let startSeconds = playTimeRange.lowerBound.truncatingRemainder(dividingBy: 60)
            let startString = String(format: "%2.0f:%2.1f", startMinutes, startSeconds)

            let endMinutes = playTimeRange.upperBound/60
            let endSeconds = playTimeRange.upperBound.truncatingRemainder(dividingBy: 60)
            let endString = String(format: "%2.0f:%2.1fs", endMinutes, endSeconds)

            return AnyView(HStack(spacing: 4) {
                Image(systemName: "repeat").font(.system(size: 12, weight: .light))
                Text("\(startString) -\(endString)")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.light)
            }.foregroundColor(.accentColor))
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct AudioPlayerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let audioPlayerConfigurationManager = AudioPlayerConfigurationManager(directoryName: "Conf")
        let audioManager = AudioManager(audioPlayerConfigurationManager: audioPlayerConfigurationManager)

        AudioPlayerInfoView(
            audioFilePlayer: audioManager.audioFilePlayer(channel: .a),
            accentColor: .accentColor,
            tapAction: { })
    }
}
