import SwiftUI
import Combine

class RenderData: ObservableObject {
    @Published var bgColor = [Double]([0.0, 0.0, 0.0])
}

var renderData = RenderData()

@main
struct SwiftMetal1App: App {
    var controlsView = ControlsView()
    var metalView = MetalView()
    
    var body: some Scene {
        WindowGroup {
            HStack {
                controlsView.environmentObject(renderData)
                metalView.environmentObject(renderData)
            }
        }
    }
}
