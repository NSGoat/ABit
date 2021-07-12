import SwiftUI

struct LogoToggleButton: View {

    @ObservedObject var audioManager: AudioManager

    var body: some View {
        GeometryReader { geo in
            ZStack {
                WaveBars(geo: geo, selected: audioManager.primarySelected)
                    .zIndex(Z.top)
                    .scaleEffect(0.7)
                Semicircle(selected: audioManager.primarySelected, color: AudioChannel.a.color, rotationAngle: 135)
                    .zIndex(audioManager.primarySelected ? Z.middle : Z.bottom)
                Semicircle(selected: !audioManager.primarySelected, color: AudioChannel.b.color, rotationAngle: 315)
                    .zIndex(audioManager.primarySelected ? Z.bottom : Z.middle)
            }
            .animation(.easeInOut(duration: 0.1))
            .onTapGesture {
                audioManager.selectedChannel?.selectNext()
            }
        }
        .accessibility(identifier: "ab_logo_toggle")
        .accessibility(addTraits: .isButton)
        .accessibility(value: Text(audioManager.primarySelected ? "Primary selected" : "Secondary selected"))
    }

    // MARK: Constants

    private struct Z {
        static let top = 3.0
        static let middle = 2.0
        static let bottom = 1.0
    }

    // MARK: Views

    private struct WaveBars: View {
        var geo: GeometryProxy
        var barToSpaceRatio: CGFloat = 1
        var barHeightScales: [CGFloat] = [0.3, 0.6, 0.9, 0.5, 0.7, 0.4] //.map { $0 * 0.7 }
        var selected: Bool

        private var minDimension: CGFloat { min(geo.size.width, geo.size.height) }
        private var elements: Int { (2 * barHeightScales.count) + 1 }
        private var barProportion: CGFloat { barToSpaceRatio / CGFloat(elements) }
        private var spaceProportion: CGFloat { 1 / barToSpaceRatio / CGFloat(elements) }
        private var barWidth: CGFloat { minDimension * barProportion }
        private var spacing: CGFloat { minDimension * spaceProportion }
        private var barHeights: [CGFloat] { barHeightScales.map { $0 * minDimension } }

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: spacing, content: {
                    ForEach(0..<barHeightScales.endIndex, id: \.self) {
                        let heights = selected ? barHeights : barHeights.reversed()
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(barWidth/2.0)
                            .frame(width: barWidth, height: heights[$0])
                            .shadow(radius: 3)
                    }
                })
            }
        }
    }

    private struct Semicircle: View {
        var selected: Bool
        var color: Color
        var rotationAngle: Double
        var unselectedScale: CGFloat = 0.98

        var body: some View {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .rotation(.degrees(rotationAngle))
                .foregroundColor(color)
                .shadow(color: Color.black.opacity(0.5), radius: selected ? 5 : 1, x: 0.0, y: 0.0)
                .scaleEffect(selected ? .one : unselectedScale)
        }
    }
}

struct Logo_Previews: PreviewProvider {
    static var previews: some View {
        let audioManager = DependencyManager().audioManager
        LogoToggleButton(audioManager: audioManager).scaledToFit()
    }
}
