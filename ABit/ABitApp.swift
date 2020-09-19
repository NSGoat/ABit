import SwiftUI

@main
struct ABitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(audioManager: AudioManager())
        }
    }
}


struct ABitApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioManager: AudioManager())
    }
}
