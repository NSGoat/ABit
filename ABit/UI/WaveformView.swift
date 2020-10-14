import AudioKit
import SwiftUI
import UIKit

struct WaveformView: UIViewControllerRepresentable {

    @Inject var renderer: AudioFileGraphicsRenderer

    var audioFile: AKAudioFile
    var color: UIColor

    let viewController = UIViewController()
    var imageView = UIImageView()
    var progressView = UIView()

    init(audioFile: AKAudioFile, color: Color, contentMode: UIImageView.ContentMode = .scaleToFill) {
        self.audioFile = audioFile
        self.color = UIColor(color)

        imageView.backgroundColor = .red
        progressView.backgroundColor = .green

        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        progressView.backgroundColor = .lightGray
        progressView.layer.cornerRadius = 4
    }

    func makeUIViewController(context: Context) -> UIViewController {
        for view in [imageView, progressView] {
            viewController.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        imageView.image = nil
        imageView.isHidden = true

        startLoadingAnimation()

        let size = viewController.view.frame.size
        renderer.renderWaveformImage(audioFile: audioFile, size: size, color: color) { image in
            DispatchQueue.main.async {
                imageView.image = image
                imageView.isHidden = false
                stopLoadingAnimation()
            }
        }
    }

    private func startLoadingAnimation() {
        progressView.alpha = 0.0
        progressView.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .curveEaseInOut, .repeat], animations: {
            progressView.alpha = 0.2
        }, completion: { _ in
            progressView.alpha = 0.0
        })
    }

    private func stopLoadingAnimation() {
        progressView.layer.removeAllAnimations()
        progressView.alpha = 0.0
        progressView.isHidden = true
    }
}
