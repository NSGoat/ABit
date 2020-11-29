import AVFoundation
import UIKit

class WaveformViewController: UIViewController {

    @Inject var renderer: AudioFileGraphicsRenderer

    var audioFile: AVAudioFile?

    var color: UIColor

    var imageView = UIImageView()
    var progressView = UIView()

    init(color: UIColor) {
        self.color = color

        super.init(nibName: nil, bundle: nil)

        imageView.isHidden = true
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.tintColor = color
        progressView.isHidden = true
        progressView.backgroundColor = color
        progressView.layer.cornerRadius = 6

        for subview in [imageView, progressView] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }

        if let audioFile = audioFile {
            updateAudioFile(audioFile)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startLoadingAnimation() {
        progressView.alpha = 0.0
        progressView.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .curveEaseInOut, .repeat], animations: {
            self.progressView.alpha = 0.1
        }, completion: { _ in
            self.progressView.alpha = 0.0
        })
    }

    func stopLoadingAnimation() {
        progressView.layer.removeAllAnimations()
        progressView.alpha = 0.0
        progressView.isHidden = true
    }

    func updateAudioFile(_ newAudioFile: AVAudioFile?) {
        guard
            let newAudioFile = newAudioFile
        else {
            audioFile = nil
            return
        }
        guard audioFile != newAudioFile else { return }

        audioFile = newAudioFile
        imageView.image = nil
        imageView.isHidden = true

        startLoadingAnimation()

//        let maxDimension = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
//        let size = CGSize(width: maxDimension, height: 150)
        let size = view.bounds.size
        renderer.renderWaveform(audioFile: newAudioFile, size: size) { image in
            DispatchQueue.main.async {
                self.imageView.image = image?.withRenderingMode(.alwaysTemplate)
                self.imageView.isHidden = false
                self.stopLoadingAnimation()
            }
        }
    }
}
