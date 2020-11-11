import AudioKit
import AVFoundation
import Foundation
import UIKit

public class AudioFileGraphicsRenderer {

    enum RenderingStyle {
        case block
        case line
        case bars
    }

    static let shared = AudioFileGraphicsRenderer()

    @Inject var logger: Logger

    func renderWaveformImage(audioFile: AVAudioFile, size: CGSize,
                             style: RenderingStyle = .line,
                             color: UIColor,
                             completion: @escaping (UIImage?) -> Void) {

        DispatchQueue.global(qos: .utility).async { [weak self, weak audioFile] in
            guard let audioFile = audioFile else { return }

            if let image = self?.renderAudioFileGraphics(audioFile, size: size, style: style, color: color) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    private func renderAudioFileGraphics(_ audioFile: AVAudioFile,
                                         size: CGSize,
                                         style: RenderingStyle,
                                         color: UIColor) -> UIImage {
        switch style {
        case .line:
            return renderWaveformLine(audioFile, size: size, color: color, oversampling: 8)
        case .block:
            return UIImage()
        case .bars:
            return renderWaveformBars(audioFile, size: size, color: color)
        }
    }

    private func renderWaveformBars(_ audioFile: AVAudioFile,
                                    size: CGSize,
                                    color: UIColor) -> UIImage {

        logger.log(.info, "Began audio file graphics rendering")

        let oversampling = 1.0
        let startTime = Date()
        guard
            let table = Table(file: audioFile)
        else {
            return UIImage()
        }
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
            let width = Double(max(size.width, CGFloat(table.count))) * oversampling
            let height = Double(size.height) / 2.0

            logger.log(.verbose, "Create bezier path")
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0.0, y: (1.0 - Double(table[0]) / absmax) * height))

            let strideWidth: Int = table.count / Int(width)

            // TODO: Implement binning
            for i in stride(from: table.startIndex, to: table.endIndex-1, by: strideWidth) {
                let x = Double(i) / Double(strideWidth) / oversampling
//                let y = (1.0 - table[i] / absmax) * height

//                let rangeEnd = min(i+strideWidth, table.lastIndex ?? 0)
//                let range = i..<rangeEnd
//                let rangeAverage = averageValue(inRange: range, forTable: table)
//                let y = (1.0 - rangeAverage / absmax) * height

                let rangeEnd = min(i+strideWidth, table.lastIndex ?? 0)
                let range = i..<rangeEnd
                let rangeAverage = Double(averageValue(inRange: range, forTable: table))
                let y = (1.0 - rangeAverage / absmax) * height

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

    private func renderWaveformLine(_ audioFile: AVAudioFile,
                                    size: CGSize,
                                    color: UIColor,
                                    oversampling: Double) -> UIImage {

        logger.log(.info, "Began audio file graphics rendering")

        let startTime = Date()

        guard
            let table = Table(file: audioFile)
        else {
            return UIImage()
        }

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
            bezierPath.move(to: CGPoint(x: 0.0, y: (1.0 - Double(table[0]) / absmax) * height))

            let strideWidth: Int = table.count / Int(width)

            guard let lastIndex = table.lastIndex else { return }

            for i in stride(from: table.startIndex, to: lastIndex, by: max(strideWidth, 1)) {
                let x = Double(i) / Double(strideWidth) / oversampling
                let y = (1.0 - Double(table[i]) / absmax) * height

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

    private func averageValue(inRange range: Range<Int>, forTable table: Table) -> Float {
        let sum = table[range].reduce(0.0, +)
        return sum / Float(range.count)
    }

    private func averageAbsoluteValue(inRange range: Range<Int>, forTable table: Table) -> Float {
        let sum = table[range]
            .map {
                abs($0)
            }.reduce(0.0, +)

        return sum / Float(range.count)
    }
}
