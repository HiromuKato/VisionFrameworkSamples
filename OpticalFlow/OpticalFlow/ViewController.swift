//
//  ViewController.swift
//  OpticalFlow
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import Vision
import MetalKit
import AVFoundation
import CoreImage.CIFilterBuiltins
import VideoToolbox

final class ViewController: UIViewController {
    
    // The Vision requests and the handler to perform them.
    private let requestHandler = VNSequenceRequestHandler()
    private var opticalFlowRequest: VNGenerateOpticalFlowRequest!
    
    // A structure that contains RGB color intensity values.
    private var colors: AngleColors?
    
    var bufferSwap = false
    var imageBuffer1: CVPixelBuffer!
    var imageBuffer2: CVPixelBuffer!
    
    @IBOutlet weak var cameraView: MTKView! {
        didSet {
            guard metalDevice == nil else { return }
            setupMetal()
            setupCoreImage()
            setupCaptureSession()
        }
    }
    
    // The Metal pipeline.
    public var metalDevice: MTLDevice!
    public var metalCommandQueue: MTLCommandQueue!
    
    // The Core Image pipeline.
    public var ciContext: CIContext!
    public var currentCIImage: CIImage? {
        didSet {
            cameraView.draw()
        }
    }
    
    // The capture session that provides video frames.
    public var session: AVCaptureSession?
    
    // MARK: - ViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        session?.stopRunning()
    }
    
    // MARK: - Perform Requests
    
    private func processVideoFrame(_ beforeFramePixelBuffer: CVPixelBuffer, _ afterFramePixelBuffer: CVPixelBuffer) {
        
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(afterFramePixelBuffer, options: nil, imageOut: &cgImage)
        // オプティカルフローを生成するリクエストの作成
        opticalFlowRequest = VNGenerateOpticalFlowRequest(targetedCGImage: cgImage!, options: [:]) // 後画像
        // オプティカルフローを計算するための精度レベル
        opticalFlowRequest.computationAccuracy = VNGenerateOpticalFlowRequest.ComputationAccuracy.medium
        // 出力バッファのピクセル形式
        opticalFlowRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
        // 機械学習ネットワークからの raw ピクセルバッファーを保持するかどうかを示すブール値
        opticalFlowRequest.keepNetworkOutput = true
        
        // リクエストを実行する
        try? requestHandler.perform([opticalFlowRequest], on: beforeFramePixelBuffer) // 前画像
        
        // 結果の pixel buffer を取得する
        guard let resultPixelBuffer = opticalFlowRequest.results?.first?.pixelBuffer else { return }
        
        // 画像の表示
        currentCIImage = CIImage(cvPixelBuffer: resultPixelBuffer)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Grab the pixelbuffer frame from the camera output
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        bufferSwap = !bufferSwap
        
        // 1フレーム前のカメラ画像をバッファに保持する
        if(bufferSwap) {
            imageBuffer1 = pixelBuffer
            guard (imageBuffer1 != nil), (imageBuffer2 != nil) else { return }
            processVideoFrame(imageBuffer2, pixelBuffer)
        } else {
            imageBuffer2 = pixelBuffer
            guard (imageBuffer1 != nil), (imageBuffer2 != nil) else { return }
            processVideoFrame(imageBuffer1, pixelBuffer)
        }
    }
}
