import MetalKit

class Renderer : NSObject, MTKViewDelegate {
    var parent: MetalView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    
    var vertices: [Float] = [
        0, 1, 0,
        -1, -1, 0,
        1, -1, 0
    ]
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    init(_ parent: MetalView, device: MTLDevice) {
        self.parent = parent
        self.device = device
        commandQueue = device.makeCommandQueue()
        super.init()
        buildModel()
        buildPipelineState()
    }
    
    private func buildModel() {
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Float>.size,
            options: []
        )
    }
    
    private func buildPipelineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func draw(in view: MTKView) {
        let drawable = view.currentDrawable
        let pipelineState = pipelineState
        let descriptor = view.currentRenderPassDescriptor
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        view.clearColor = MTLClearColor(
            red: parent.renderData.bgColor[0],
            green: parent.renderData.bgColor[1],
            blue: parent.renderData.bgColor[2],
            alpha: 1
        )
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor!)
        
        commandEncoder?.setRenderPipelineState(pipelineState!)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        commandEncoder?.endEncoding()
        commandBuffer!.present(drawable!)
        commandBuffer?.commit()
    }
}
