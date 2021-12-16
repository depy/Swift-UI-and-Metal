import MetalKit

class Renderer : NSObject, MTKViewDelegate {
    struct Constants {
        var animateBy: Float = 0
    }
    
    var parent: MetalView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var constants = Constants()
    var time: Float = 0
    
    var vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-0.5,  0.5, 0), color: SIMD4<Float>(1, 0, 0, 1)),
        Vertex(position: SIMD3<Float>(-0.5, -0.5, 0), color: SIMD4<Float>(0, 1, 0, 1)),
        Vertex(position: SIMD3<Float>( 0.5, -0.5, 0), color: SIMD4<Float>(0, 0, 1, 1)),
        Vertex(position: SIMD3<Float>( 0.5,  0.5, 0), color: SIMD4<Float>(1, 0, 1, 1))
    ]
    
    var indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
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
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: indices,
            length: indices.count * MemoryLayout<UInt16>.size,
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
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
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
        
        time += 1 / Float(view.preferredFramesPerSecond)
        
        let animateBy = abs(sin(time)/2 + 0.5)
        constants.animateBy = animateBy
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor!)
        
        commandEncoder?.setRenderPipelineState(pipelineState!)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer!,
            indexBufferOffset: 0
        )
        
        commandEncoder?.endEncoding()
        commandBuffer!.present(drawable!)
        commandBuffer?.commit()
    }
}
