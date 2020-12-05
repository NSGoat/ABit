import Foundation

class DocumentFileManager<T: UrlReadable> {

    enum DocumentFileManagerError: Error {
        case documentFolderNotFound
    }

    private let directoryName: String

    lazy private var fileManager = FileManager.default

    init(directoryName: String) {
        self.directoryName = directoryName
    }

    func writeAudioFileToDocuments(sourceUrl: URL) throws -> URL {
        guard let directoryUrl = directoryUrl else { throw DocumentFileManagerError.documentFolderNotFound }
        let sourceData = try Data(contentsOf: sourceUrl, options: [])
        let fileUrl = directoryUrl.appendingPathComponent(sourceUrl.lastPathComponent)

        try createDirectoryIfNeeded(directoryUrl: directoryUrl)
        try? sourceData.write(to: fileUrl)
        _ = try T(forReading: fileUrl)

        return fileUrl
    }

    /// Mark: - Helpers

    private var directoryUrl: URL? {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentDirectory?.appendingPathComponent(directoryName)
    }

    private func createDirectoryIfNeeded(directoryUrl: URL) throws {
        if !fileManager.fileExists(atPath: directoryUrl.absoluteString) {
            try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
        }
    }

    private func deleteDirectory(url: URL) throws {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.absoluteString, isDirectory: &isDirectory), isDirectory.boolValue {
            try fileManager.removeItem(at: url)
        }
    }
}
