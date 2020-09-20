import SwiftUI

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
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = context.coordinator
        documentPicker.shouldShowFileExtensions = true

        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {

    }
}
