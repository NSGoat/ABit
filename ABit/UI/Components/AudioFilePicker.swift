import SwiftUI
import UIKit
import UniformTypeIdentifiers

protocol AudioFilePickerDelegate {
    func audioFilePicker(_ picker: AudioFilePicker, didPickAudioFileAt url: URL)
}

final class AudioFilePicker: UIViewControllerRepresentable {

    var delegate: AudioFilePickerDelegate?

    init(delegate: AudioFilePickerDelegate?) {
        self.delegate = delegate
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {

        var parent: AudioFilePicker

        init(parent: AudioFilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.delegate?.audioFilePicker(parent, didPickAudioFileAt: url)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        viewController.delegate = context.coordinator
        return viewController
    }

    var viewController: UIDocumentPickerViewController = {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: copyFile)
        documentPicker.shouldShowFileExtensions = true
        return documentPicker
    }()

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) { }

    private static var copyFile: Bool {
        #if targetEnvironment(macCatalyst)
        return false
        #else
        return true
        #endif
    }
}
