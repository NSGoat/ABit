import SwiftUI
import UIKit
import UniformTypeIdentifiers

protocol AudioFilePickerDelegate {
    func audioFilePicker(_ picker: AudioFilePicker, didPickAudioFileAt url: URL)
}

struct AudioFilePicker: UIViewControllerRepresentable {

    var delegate: AudioFilePickerDelegate?

    class Coordinator: NSObject, UIDocumentPickerDelegate {

        var parent: AudioFilePicker

        init(parent: AudioFilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            parent.delegate?.audioFilePicker(parent, didPickAudioFileAt: url)
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            parent.delegate?.audioFilePicker(parent, didPickAudioFileAt: url)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    var viewController: UIDocumentPickerViewController = {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)

        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }()

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        viewController.delegate = context.coordinator

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) { }
}
