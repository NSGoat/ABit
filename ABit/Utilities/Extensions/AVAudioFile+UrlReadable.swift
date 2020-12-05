import AVFoundation

extension AVAudioFile: UrlReadable { }

protocol UrlReadable: class {
    init(forReading: URL) throws
}
