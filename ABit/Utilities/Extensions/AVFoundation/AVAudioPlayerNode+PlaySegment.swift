import AVFoundation

extension AVAudioPlayerNode {

    @discardableResult
    func playSegment(fromBuffer buffer: AVAudioPCMBuffer,
                     segmentRange: ClosedRange<Double>,
                     looping: Bool) -> (bufferSegment: AVAudioPCMBuffer, timeRange: ClosedRange<TimeInterval>)? {

        let start = AVAudioFramePosition(segmentRange.lowerBound * Double(buffer.frameLength))
        let end = AVAudioFramePosition(segmentRange.upperBound * Double(buffer.frameLength))
        if let bufferSegment = buffer.segment(from: start, to: end) {

            if looping {
                scheduleBuffer(bufferSegment, at: nil, options: [.loops, .interrupts])
            } else {
                scheduleBuffer(bufferSegment, at: nil, options: [.interrupts]) {
                    DispatchQueue.main.async { [weak self] in
                        self?.stop()
                    }
                }
            }

            return (bufferSegment, TimeInterval(start)...TimeInterval(end))
        }

        return nil
    }
}
