//
//  Renderer.swift
//  cgol
//
//  Created by Kane Sweet on 9/6/23.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var dynamicUniformBuffer: MTLBuffer
    var pipelineState: MTLRenderPipelineState

    // Buffer
    var uniformBufferOffset = 0
    var uniformBufferIndex = 0
    var uniforms: UnsafeMutablePointer<Uniforms>

    var vertices: [Vertex]!
    var vertexBuffer: MTLBuffer!

    var timer: Timer!
    var needsUpdate = false

    struct Vertex {
        var position: SIMD4<Float>
        var color: SIMD4<Float>
    }
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else { return nil }
        self.commandQueue = queue

        // Buffer
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        guard let buffer = self.device.makeBuffer(length:uniformBufferSize, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        dynamicUniformBuffer = buffer
        self.dynamicUniformBuffer.label = "UniformBuffer"
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to:Uniforms.self, capacity:1)

        // MTKView
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        metalKitView.sampleCount = 1

        do {
            pipelineState = try Renderer.buildRenderPipelineWithDevice(
                device: device,
                metalKitView: metalKitView
            )
        } catch {
            print("Unable to compile render pipeline state.  Error info: \(error)")
            return nil
        }
        
        super.init()
        createGrid()
        startColorUpdateTimer()
    }
    
    class func buildMetalVertexDescriptor() -> MTLVertexDescriptor {
        /// Build a vertex descripter object

        let vertexDescriptor = MTLVertexDescriptor()

        // Specify the position attribute
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        // Set the size of each vertex in bytes
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride
        return vertexDescriptor
    }
    
    class func buildRenderPipelineWithDevice(
        device: MTLDevice,
        metalKitView: MTKView
    ) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertex_main"),
              let fragmentFunction = library.makeFunction(name: "fragment_main") else {
            fatalError("Shaders not found.")
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = Renderer.buildMetalVertexDescriptor()
        //pipelineDescriptor.rasterSampleCount = metalKitView.sampleCount
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    

    
    class func loadTexture(device: MTLDevice,
                           textureName: String) throws -> MTLTexture {
        /// Load texture data with optimal parameters for sampling
        
        let textureLoader = MTKTextureLoader(device: device)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        
        return try textureLoader.newTexture(
            name: textureName,
            scaleFactor: 1.0,
            bundle: nil,
            options: textureLoaderOptions
        )
        
    }
    
    private func updateDynamicBufferState() {
        /// Update the state of our uniform buffers before rendering
        
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        
        uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to:Uniforms.self, capacity:1)
    }
    
    private func updateGameState() {
        /// Update any game state before rendering
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
    }



    func randomColor() -> SIMD4<Float> {
        return SIMD4<Float>(Float.random(in: 0...1),
                            Float.random(in: 0...1),
                            Float.random(in: 0...1),
                            1.0)
    }

    func startColorUpdateTimer() {
        // Update colors every second (or adjust the interval as needed)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.needsUpdate = true
        }
    }

    func draw(in view: MTKView) {

        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()

        if needsUpdate {
            updateBoard()
            renderBoard()
            needsUpdate = false
        }
    }

    func createGrid() {
        initBoard()
        let squareHeight: Float = 2 / Float(gridHeight)
        let squareWidth: Float = 2 / Float(gridWidth)
        vertices = []

        for i in 0..<gridWidth {
            for j in 0..<gridHeight {
                let x = Float(i) * squareWidth - 1
                let y = Float(j) * squareHeight - 1

                let color = board[i][j] ? randomColor() : deadColor

                let topLeft = Vertex(position: SIMD4<Float>(x, y + squareHeight, 0, 1), color: color)
                let bottomLeft = Vertex(position: SIMD4<Float>(x, y, 0, 1), color: color)
                let topRight = Vertex(position: SIMD4<Float>(x + squareWidth, y + squareHeight, 0, 1), color: color)
                let bottomRight = Vertex(position: SIMD4<Float>(x + squareWidth, y, 0, 1), color: color)

                vertices += [topLeft, bottomLeft, topRight]
                vertices += [bottomLeft, bottomRight, topRight]
            }
        }

        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Vertex>.stride,
                                         options: [])
    }

    // CGOl logic
    let gridWidth  = 40
    let gridHeight = 40
    var board: [[Bool]] = []

    func initBoard() {
        for i in 0..<gridHeight {
            var row: [Bool] = []
            for j in 0..<gridWidth {
                row += [Int.random(in: 0...1) == 0]
            }
            board += [row]
        }
    }

    func updateBoard() {
        var newBoard: [[Bool]] = []
        for i in 0..<gridHeight {
            var row: [Bool] = []
            for j in 0..<gridWidth {
                row += [updateCell(row: i, col: j)]
            }
            newBoard += [row]
        }
        board = newBoard
    }

    let nbrs = [[-1,-1],[-1,0],[-1,1],
               [0,-1],         [0,1],
               [1,-1],  [1,0], [1,1]]

    func updateCell(row: Int, col: Int) -> Bool {
        let numLivingNbrs = nbrs.compactMap { nbr in
            let nbrRow = (row+nbr[0]) %% gridHeight
            let nbrCol = (col+nbr[1]) %% gridWidth
            return board[nbrRow][nbrCol] ? 1 : nil
        }.count

        if board[row][col] {
            return 4 <= numLivingNbrs && numLivingNbrs <= 5
        }
        else {
            return numLivingNbrs == 2 || (
                numLivingNbrs == 0 && Int.random(in: 0...1000) == 0
            )
        }
    }

    func renderBoard() {
        var color = randomColor()
        for i in 0..<vertices.count {
            if (i % 6 == 0) {
                let row = (i / 6) % gridHeight
                let col = (i / 6) / gridHeight
                color = board[row][col] ? randomColor() : deadColor
            }
            vertices[i].color = color
        }

        vertexBuffer.contents().copyMemory(from: vertices,
                                           byteCount: vertices.count * MemoryLayout<Vertex>.stride)
    }

    let aliveColor = SIMD4<Float>(Float(1),Float(1),Float(1),1.0)
    let deadColor  = SIMD4<Float>(Float(0),Float(0),Float(0),1.0)

    func neighbors(i: Int) {

    }
}

infix operator %%

extension Int {
    static func %% (_ left: Int, _ right: Int) -> Int {
        if left >= 0 { return left % right }
        if left >= -right { return (left+right) }
        return ((left % right)+right)%right
    }
}
