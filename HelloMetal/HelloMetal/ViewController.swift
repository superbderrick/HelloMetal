//
//  ViewController.swift
//  HelloMetal
//
//  Created by derrick on 2017. 3. 2..
//  Copyright © 2017년 Superbderrick. All rights reserved.
//

import UIKit
import Metal
import QuartzCore


class ViewController: UIViewController {
	
	var device: MTLDevice! = nil
	var vertexBuffer: MTLBuffer! = nil
	var pipelineState: MTLRenderPipelineState! = nil
	var commandQueue: MTLCommandQueue! = nil
	var metalLayer: CAMetalLayer! = nil
	var timer: CADisplayLink! = nil
	
	let vertexData:[Float] = [
		0.0 , 1.0 , 0.0 ,
	   -1.0 ,-1.0 , 0.0 ,
	    1.0 ,-1.0 , 0.0 ]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		device = MTLCreateSystemDefaultDevice()
		
		metalLayer = CAMetalLayer()           // 1
		metalLayer.device = device            // 2
		metalLayer.pixelFormat = .bgra8Unorm  // 3
		metalLayer.framebufferOnly = true     // 4
		metalLayer.frame = view.layer.frame   // 5
		view.layer.addSublayer(metalLayer)    // 6
		

		let dataSize = vertexData.count * sizeof(vertexData[0])
		vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
	
		// 1
		let defaultLibrary = device.newDefaultLibrary()
		let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
		let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")

		// 2
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = vertexProgram
		pipelineStateDescriptor.fragmentFunction = fragmentProgram
		
		// 3
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

		do {
			try self.pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
		} catch let pipelineError as NSError {
			print("Failed to create pipeline state, error \(pipelineError)")
		}
		commandQueue = device.makeCommandQueue()
		
		timer = CADisplayLink(target: self, selector: #selector(gameloop))
		timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
		
	}
	
	func gameloop() {
		autoreleasepool {
			self.render()
		}
	}
	
	func render() {
		
		let drawable = metalLayer.nextDrawable()!
		
		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = drawable.texture
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
		
		let commandBuffer = commandQueue.makeCommandBuffer()
		
		let renderEncoderOpt = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
		
		renderEncoderOpt.setRenderPipelineState(pipelineState)
		renderEncoderOpt.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
		renderEncoderOpt.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
		renderEncoderOpt.endEncoding()
		
		commandBuffer.present(drawable)
		commandBuffer.commit()
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}

