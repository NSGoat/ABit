import Foundation
import AVFoundation
import UIKit
import CoreGraphics

public typealias ImageCompletion = (_ image: UIImage?) -> Void

public class AudioGraphicsRenderer {

    @Inject var logger: Logger

    static let shared = AudioGraphicsRenderer()

    public func renderWaveformImage(audioAssetURL: URL,
                                    configuration: WaveformConfiguration,
                                    qos: DispatchQoS.QoSClass = .userInitiated,
                                    completion: @escaping ImageCompletion) {

        let scaledSize = CGSize(width: configuration.size.width * configuration.scale,
                                height: configuration.size.height * configuration.scale)
        let scaledConfiguration = WaveformConfiguration(size: scaledSize,
                                                        color: configuration.color,
                                                        backgroundColor: configuration.backgroundColor,
                                                        style: configuration.style,
                                                        position: configuration.position,
                                                        scale: configuration.scale,
                                                        paddingFactor: configuration.paddingFactor)
        guard let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: audioAssetURL) else {
            completion(nil)
            return
        }
        renderWaveformImage(withAnalyser: waveformAnalyzer,
                            configuration: scaledConfiguration,
                            qos: qos,
                            completion: completion)
    }

    public func renderWaveformImage(audioFileUrl audioAssetURL: URL,
                                    size: CGSize,
                                    color: UIColor = UIColor.black,
                                    backgroundColor: UIColor = UIColor.clear,
                                    style: WaveformStyle = .gradient,
                                    position: WaveformPosition = .middle,
                                    scale: CGFloat = UIScreen.main.scale,
                                    paddingFactor: CGFloat? = nil,
                                    qos: DispatchQoS.QoSClass = .userInitiated,
                                    completion: @escaping ImageCompletion) {

        let configuration = WaveformConfiguration(size: size,
                                                  color: color,
                                                  backgroundColor: backgroundColor,
                                                  style: style,
                                                  position: position,
                                                  scale: scale,
                                                  paddingFactor: paddingFactor)

        renderWaveformImage(audioAssetURL: audioAssetURL, configuration: configuration, completion: completion)
    }
}

private extension AudioGraphicsRenderer {

    func renderWaveformImage(withAnalyser waveformAnalyzer: WaveformAnalyzer,
                             configuration: WaveformConfiguration,
                             qos: DispatchQoS.QoSClass,
                             completion: @escaping ImageCompletion) {

        let sampleCount = Int(configuration.size.width * configuration.scale)
        waveformAnalyzer.samples(count: sampleCount, qos: qos) { samples in
            guard let samples = samples else {
                completion(nil)
                return
            }
            completion(self.graphImage(from: samples, with: configuration))
        }
    }

    private func graphImage(from samples: [Float], with configuration: WaveformConfiguration) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = configuration.scale
        let renderer = UIGraphicsImageRenderer(size: configuration.size, format: format)

        return renderer.image { renderContext in
            draw(onContext: renderContext.cgContext, from: samples, configuration: configuration)
        }
    }

    private func draw(onContext context: CGContext, from samples: [Float], configuration: WaveformConfiguration) {
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)

        drawGraph(samples: samples, onContext: context, configuration: configuration)
    }

    private func drawGraph(samples: [Float], onContext context: CGContext, configuration: WaveformConfiguration) {
        let graphRect = CGRect(origin: CGPoint.zero, size: configuration.size)
        let positionAdjustedGraphCenter = CGFloat(configuration.position.value()) * graphRect.size.height
        let verticalPaddingDivisorFallback = CGFloat(configuration.position.value() == 0.5 ? 2.5 : 1.5)
        let verticalPaddingDivisor = configuration.paddingFactor ?? verticalPaddingDivisorFallback
        let drawMappingFactor = graphRect.size.height / verticalPaddingDivisor
        let minimumGraphAmplitude: CGFloat = 1 // we want to see at least a 1pt line for silence

        let path = CGMutablePath()
        var maxAmplitude: CGFloat = 0.0 // we know 1 is our max in normalized data, but we keep it 'generic'
        context.setLineWidth(1.0 / configuration.scale)
        for (x, sample) in samples.enumerated() {
            let xPos = CGFloat(x) / configuration.scale
            let invertedDbSample = 1 - CGFloat(sample) // sample is in dB, linearly normalized to [0, 1] (1 -> -50 dB)
            let drawingAmplitude = max(minimumGraphAmplitude, invertedDbSample * drawMappingFactor)
            let drawingAmplitudeUp = positionAdjustedGraphCenter - drawingAmplitude
            let drawingAmplitudeDown = positionAdjustedGraphCenter + drawingAmplitude
            maxAmplitude = max(drawingAmplitude, maxAmplitude)

            if configuration.style == .striped && (Int(xPos) % 5 != 0) { continue }

            path.move(to: CGPoint(x: xPos, y: drawingAmplitudeUp))
            path.addLine(to: CGPoint(x: xPos, y: drawingAmplitudeDown))
        }
        context.addPath(path)

        switch configuration.style {
        case .filled, .striped:
            context.setStrokeColor(configuration.color.cgColor)
            context.strokePath()
        case .gradient:
            context.replacePathWithStrokedPath()
            context.clip()
            let colors = NSArray(array: [
                configuration.color.cgColor,
                configuration.color.highlighted(brightnessAdjustment: 0.5).cgColor
            ]) as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: 0, y: positionAdjustedGraphCenter - maxAmplitude),
                                       end: CGPoint(x: 0, y: positionAdjustedGraphCenter + maxAmplitude),
                                       options: .drawsAfterEndLocation)
        }
    }
}
