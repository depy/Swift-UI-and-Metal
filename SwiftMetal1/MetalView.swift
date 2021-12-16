import SwiftUI
import MetalKit

extension MetalView : NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
}

struct MetalView {
    @EnvironmentObject var renderData: RenderData
    
    func makeCoordinator() -> Renderer {
        let metalDevice = MTLCreateSystemDefaultDevice()
        return Renderer(self, device: metalDevice!)
    }
    
    func makeMTKView(_ context: MetalView.Context) -> MTKView {
        let mtkView = MTKView()
        
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        
        print("renderData \(renderData.bgColor)")
        
        return mtkView
    }
}
