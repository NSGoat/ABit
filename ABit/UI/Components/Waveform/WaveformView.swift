import AudioKit
import SwiftUI
import UIKit

struct WaveformView: UIViewControllerRepresentable {

    let viewController: WaveformViewController

    init(color: Color) {
        viewController = WaveformViewController(color: UIColor(color))
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

    func updateAudioFile(audioFile: AKAudioFile?) {
        viewController.updateAudioFile(audioFile)
    }
}
