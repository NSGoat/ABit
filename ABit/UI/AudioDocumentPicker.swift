import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct AudioDocumentPicker: UIViewControllerRepresentable {

    @Binding var url: URL?

    class Coordinator: NSObject, UIDocumentPickerDelegate {

        var parent: AudioDocumentPicker

        init(parent: AudioDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.url = urls.first
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            parent.url = url
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
