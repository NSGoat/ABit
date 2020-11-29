import AVFoundation

extension AVAudioFile {
    
    var duration: TimeInterval {
        Double(length) / fileFormat.sampleRate
    }

    public func timeRange(positionRange: ClosedRange<Double>) -> ClosedRange<TimeInterval>? {
        let timesBounds = [duration * positionRange.lowerBound,
                           duration * positionRange.upperBound]

        let startTime = timesBounds.min() ?? 0
        let endTime = timesBounds.max() ?? duration

        return startTime...endTime
    }
}
