import AVFoundation

protocol UrlReadable: AnyObject {
    init(forReading: URL) throws
}
