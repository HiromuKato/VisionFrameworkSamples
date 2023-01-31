//
//  HumanRectanglesDetectionViewController.swift
//  DetectingHumanRectangles
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import AVFoundation
import Vision

class HumanRectanglesDetectionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    private var request = VNDetectHumanRectanglesRequest()
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    func setupLayers() {
        // 観測結果のすべてのレンダリングを含むコンテナレイヤー
        detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        // レイヤーの領域
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        // スーパーレイヤーの座標空間におけるレイヤーの位置
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.width
        let yScale: CGFloat = bounds.size.height / bufferSize.height
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        
        // 現在のスレッドの新しいトランザクションを開始する
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // スケーリング
        detectionOverlay.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        // レイヤーを中央に配置
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // 現在のトランザクション中に行われたすべての変更をコミットする
        CATransaction.commit()
    }
    
    func setupVision() {
        // 人体検出のリクエスト内容設定
        request = VNDetectHumanRectanglesRequest(completionHandler: humanRectanglesHandler)
        // 要求が結果を生成するために全身または上半身のみを検出する必要があるかどうかを示すブール値
        request.upperBodyOnly = false
    }
    
    // カメラ画像を取得した時の処理
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        //let exifOrientation = exifOrientationFromDeviceOrientation() // 端末の回転に対応しないためコメント
        let exifOrientation: CGImagePropertyOrientation = .up
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    // 人体検出時の処理
    func humanRectanglesHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanObservation] else {
            return
        }
        
        drawResults(observations)
    }
    
    // 結果の描画処理
    func drawResults(_ observations: [VNHumanObservation])
    {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // 全ての古い認識されたオブジェクトを削除する
        detectionOverlay.sublayers = nil
        
        for observation in observations {
            let bounds = CGRect(x: 0, y: 0, width: bufferSize.width, height: bufferSize.height)
            let rectBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let rectLayer = shapeLayer(color: .blue, frame: rectBox)
            
            detectionOverlay.addSublayer(rectLayer)
        }
        
        CATransaction.commit()
    }
    
    fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
    fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
        // Create a new layer.
        let layer = CAShapeLayer()
        
        // Configure layer's appearance.
        layer.fillColor = nil // No fill to show boxed object
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.borderWidth = 2
        
        // Vary the line color according to input.
        layer.borderColor = color.cgColor
        
        // Locate the layer.
        layer.anchorPoint = .zero
        layer.frame = frame
        layer.masksToBounds = true
        
        // Transform the layer to have same coordinate system as the imageView underneath it.
        layer.transform = CATransform3DMakeScale(1, -1, 1)
        
        return layer
    }
}
