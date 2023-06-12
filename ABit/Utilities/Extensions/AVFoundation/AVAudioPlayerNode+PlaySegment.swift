import AVFoundation

extension AVAudioPlayerNode {

    @discardableResult
    func scheduleSegment(fromBuffer buffer: AVAudioPCMBuffer,
                         range: ClosedRange<Double>,
                         looping: Bool) -> (buffer: AVAudioPCMBuffer, timeRange: ClosedRange<TimeInterval>)? {

        let start = AVAudioFramePosition(range.lowerBound * Double(buffer.frameLength))
        let end = AVAudioFramePosition(range.upperBound * Double(buffer.frameLength))
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
