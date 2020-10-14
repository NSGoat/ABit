import AudioKit
import Foundation
import UIKit

public class AudioFileGraphicsRenderer {

    static let shared = AudioFileGraphicsRenderer()

    @Inject var logger: Logger

    @Published var waveformImage: UIImage?

    private class ImageCacheKey {
        let sourceFileHash: Int
        let imageSize: CGSize

        init(sourceFileHash: Int, size: CGSize) {
            self.sourceFileHash = sourceFileHash
            self.imageSize = size
        }
    }

    private var cache: NSCache<ImageCacheKey, UIImage> = NSCache()

    func renderWaveformImage(audioFile: AKAudioFile,
                             size: CGSize,
                             color: UIColor,
                             completion: @escaping (UIImage?) -> Void) {

        let cacheKey = ImageCacheKey(sourceFileHash: audioFile.hash, size: size)

        if let image = cache.object(forKey: cacheKey) {
            completion(image)
            return
        } else {

            DispatchQueue.global(qos: .utility).async { [weak self, weak audioFile] in
                guard let audioFile = audioFile else { return }

                if let image = self?.renderAudioFileGraphics(audioFile, size: size, color: color) {
                    self?.cache.setObject(image, forKey: cacheKey, cost: Int(audioFile.samplesCount))

                    DispatchQueue.main.async {
                        self?.waveformImage = image
                        completion(image)
                    }
                }
            }
        }
    }

    private func renderAudioFileGraphics(_ audioFile: AKAudioFile,
                                         size: CGSize,
                                         color: UIColor,
                                         oversampling: Double = 2) -> UIImage {

        logger.log(.info, "Began audio file graphics rendering")

        let startTime = Date()
        let table = AKTable(file: audioFile)
        let maxAmplitude = Double(table.max() ?? 1.0)
        let minAmplitude = Double(table.min() ?? -1.0)
        let absmax: Double = [maxAmplitude, abs(minAmplitude)].max() ?? 1.0
        logger.log(.verbose, "Table loaded")

        logger.log(.verbose, "Initialising UIGraphicsImageRenderer")
        let graphicsImageRenderer = UIGraphicsImageRenderer(size: size)
        logger.log(.verbose, "Initialised UIGraphicsImageRenderer")

        return graphicsImageRenderer.image { context in
            logger.log(.verbose, "Get CoreGraphicsContext")
            let coreGraphicsContext = context.cgContext
            let width = Double(size.width) * oversampling
            let height = Double(size.height) / 2.0

            logger.log(.verbose, "Create bezier path")
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0.0, y: (1.0 - table[0] / absmax) * height))

            let strideWidth: Int = table.count / Int(width)

            // TODO: Implement binning
            for i in stride(from: table.startIndex, to: table.endIndex-1, by: strideWidth) {
                let x = Double(i) / Double(strideWidth) / oversampling
                let y = (1.0 - table[i] / absmax) * height

                bezierPath.addLine(to: CGPoint(x: x, y: y))
            }

            logger.log(.verbose, "Render audio path")

            coreGraphicsContext.addPath(bezierPath.cgPath)
            coreGraphicsContext.setStrokeColor(color.cgColor)
            coreGraphicsContext.strokePath()

            let renderTime = String(format: "%.1f s", Date().timeIntervalSince(startTime))
            logger.log(.info, "Completed audio rendering in \(renderTime)")
        }
    }
}
