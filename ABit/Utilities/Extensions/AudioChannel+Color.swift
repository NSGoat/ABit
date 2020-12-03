import SwiftUI

extension AudioChannel {
    var color: Color {
        switch self {
        case .a:
            return Color(red: 0, green: 172/255, blue: 84/255)
        case .b:
            return Color(red: 253/255, green: 141/255, blue: 15/255)
        }
    }
}
