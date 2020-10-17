import AudioKit
import SwiftUI
import UIKit

struct WaveformView: UIViewControllerRepresentable {

    var audioFile: AKAudioFile? {
        didSet {
            if let audioFile = audioFile {
                updateAudioFile(audioFile: audioFile)
            }
        }
    }

    let viewController: WaveformViewController

    init(audioFile: AKAudioFile? = nil, color: Color) {
        self.audioFile = audioFile
        viewController = WaveformViewController(audioFile: audioFile, color: UIColor(color))
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let waveformViewController = uiViewController as? WaveformViewController else { return }
        waveformViewController.updateAudioFile(audioFile)
    }

    func updateAudioFile(audioFile: AKAudioFile?) {
        viewController.updateAudioFile(audioFile)
    }
}
