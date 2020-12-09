import AVFoundation
import Foundation
import UIKit

extension AVAudioFile: UrlReadable { }

class AudioFileManager: DocumentFileManager<AVAudioFile> { }
