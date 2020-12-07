import AVFoundation
import Foundation
import UIKit

extension AVAudioFile: UrlReadable { }

class AudioFileManager: DocumentFileManager<AVAudioFile>, UIDocumentPickerDelegate {

    weak var delegate: DocumentFileManagerDelegate?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        do {
            let documentUrl = try storeFileInDocuments(sourceUrl: url)
            _ = try AVAudioFile(forReading: documentUrl)
            delegate?.documentFileManager(self, didLoadFileAtUrl: documentUrl)
        } catch {
            delegate?.documentFileManager(self, failedToLoadFileAtUrl: url)
        }
    }
}
