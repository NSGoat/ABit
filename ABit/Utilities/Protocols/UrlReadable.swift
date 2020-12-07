import AVFoundation

protocol UrlReadable: class {
    init(forReading: URL) throws
}
