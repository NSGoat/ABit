import AVFoundation
import SwiftUI
import UIKit

struct WaveformView: UIViewControllerRepresentable {

    let viewController: WaveformViewController

    let audioFile: AVAudioFile?

    init(color: Color, audioFile: AVAudioFile?) {
        viewController = WaveformViewController(color: UIColor(color))
        self.audioFile = audioFile
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

    func updateAudioFile(audioFile: AVAudioFile?) {
        viewController.updateAudioFile(audioFile)
    }
}
