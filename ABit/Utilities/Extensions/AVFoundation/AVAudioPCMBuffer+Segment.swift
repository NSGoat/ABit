import CoreAudio
import AVFoundation

extension AVAudioPCMBuffer {

    func segment(from startFrame: AVAudioFramePosition, to endFrame: AVAudioFramePosition) -> AVAudioPCMBuffer? {
        let framesToCopy = AVAudioFrameCount(endFrame - startFrame)
        guard let segment = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: framesToCopy) else { return nil }

        let sampleSize = format.streamDescription.pointee.mBytesPerFrame

        let sourcePointer = UnsafeMutableAudioBufferListPointer(mutableAudioBufferList)
        let destinationPointer = UnsafeMutableAudioBufferListPointer(segment.mutableAudioBufferList)
        for (source, destination) in zip(sourcePointer, destinationPointer) {
            memcpy(destination.mData,
                   source.mData?.advanced(by: Int(startFrame) * Int(sampleSize)),
                   Int(framesToCopy) * Int(sampleSize))
        }

        segment.frameLength = framesToCopy
        return segment
    }
}
