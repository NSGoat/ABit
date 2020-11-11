import AVFoundation

extension AVAudioFile {
    public var duration: TimeInterval {
        Double(length) / fileFormat.sampleRate
    }
}
