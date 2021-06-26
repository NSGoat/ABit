import Foundation

protocol DocumentFileManagerDelegate: class {
    func documentFileManager<T: UrlReadable>(_ documentFileManager: DocumentFileManager<T>, didLoadFileAtUrl url: URL)
    func documentFileManager<T: UrlReadable>(_ documentFileManager: DocumentFileManager<T>, failedToLoadFileAtUrl url: URL)
}

enum DocumentFileManagerError: Error {
    case documentFolderNotFound
    case bookmarkNotFound
    case bookmarkedUrlStale
}

class DocumentFileManager<T: UrlReadable>: NSObject {

    struct Document {
        let file: T
        let url: URL
    }

    private let directoryName: String?

    lazy private var fileManager = FileManager.default

    init(directoryName: String? = nil) {
        self.directoryName = directoryName
    }

    func storeFileAsDocument(sourceUrl: URL, bookmarkedWithKey userDefaultsKey: String?) throws -> Document {
        let url = try storeFileInDocuments(sourceUrl: sourceUrl)
        let file = try T(forReading: url)

        if let userDefaultsKey = userDefaultsKey {
            try storeUrlBookmark(url, userDefaultsKey: userDefaultsKey)
        }

        return Document(file: file, url: url)
    }

    func retrieveDocument(userDefaultsKey key: String) throws -> Document {
        let url = try retrieveBookmarkedUrl(userDefaultsKey: key)
        let file = try T(forReading: url)
        return Document(file: file, url: url)
    }

    /// Mark: - Helpers

    private func storeFileInDocuments(sourceUrl: URL) throws -> URL {
        guard let directoryUrl = directoryUrl else { throw DocumentFileManagerError.documentFolderNotFound }
        let sourceData = try Data(contentsOf: sourceUrl, options: [])
        let fileUrl = directoryUrl.appendingPathComponent(sourceUrl.lastPathComponent)

        try createDirectoryIfNeeded(directoryUrl: directoryUrl)
        try sourceData.write(to: fileUrl)
        _ = try T(forReading: fileUrl)

        return fileUrl
    }

    private func storeUrlBookmark(_ url: URL, userDefaultsKey: String) throws {
        let bookmarkData = try url.bookmarkData()
        UserDefaults.standard.setValue(bookmarkData, forKey: userDefaultsKey)
    }

    private func retrieveBookmarkedUrl(userDefaultsKey key: String) throws -> URL {
        guard let bookmarkData = UserDefaults.standard.value(forKey: key) as? Data else {
            throw DocumentFileManagerError.bookmarkNotFound
        }

        var isStale: Bool = false
        let url = try URL.init(resolvingBookmarkData: bookmarkData, options: [], bookmarkDataIsStale: &isStale)

        if isStale {
            throw DocumentFileManagerError.bookmarkedUrlStale
        } else {
            return url
        }
    }

    private var directoryUrl: URL? {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let directoryName = directoryName else { return documentDirectory }
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
