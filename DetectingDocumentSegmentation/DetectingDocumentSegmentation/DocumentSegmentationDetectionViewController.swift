//
//  DocumentSegmentationDetectionViewController.swift
//  DetectingDocumentSegmentation
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import AVFoundation
import Vision

class DocumentSegmentationDetectionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    private var request = VNDetectDocumentSegmentationRequest()
    
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
        // 書類検出のリクエスト内容設定
        request = VNDetectDocumentSegmentationRequest(completionHandler: documentSegmentationHandler)
        
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
    
    // 書類検出時の処理
    func documentSegmentationHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRectangleObservation] else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // 全ての古い認識されたオブジェクトを削除する
        detectionOverlay.sublayers = nil
        
        drawResults(observations)
        
        CATransaction.commit()
    }
    
    // 結果の描画処理
    public func drawResults(_ observations: [VNRectangleObservation])
    {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // 全ての古い認識されたオブジェクトを削除する
        detectionOverlay.sublayers = nil
        
        for observation in observations {
            // バウンディングボックスの描画
            let bounds = CGRect(x: 0, y: 0, width: bufferSize.width, height: bufferSize.height)
            let rectBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let rectLayer = shapeLayer(color: .red, frame: rectBox)
            detectionOverlay.addSublayer(rectLayer)
            
            // 書類部分の描画
            let xScale =  bufferSize.width
            let yScale =  bufferSize.height
            let lineLayer = CAShapeLayer()
            let line = UIBezierPath();
            line.move(to: CGPoint(x: observation.topLeft.x * xScale, y: observation.topLeft.y * yScale));
            line.addLine(to: CGPoint(x: observation.topRight.x * xScale, y: observation.topRight.y * yScale));
            line.addLine(to: CGPoint(x: observation.bottomRight.x * xScale, y: observation.bottomRight.y * yScale));
            line.addLine(to: CGPoint(x: observation.bottomLeft.x * xScale, y: observation.bottomLeft.y * yScale));
            line.close()
            lineLayer.strokeColor = UIColor.green.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 4;
            lineLayer.path = line.cgPath
            var transform = CGAffineTransform(scaleX: 1, y: -1)
            transform = transform.concatenating(CGAffineTransform(translationX: 0, y: yScale))
            lineLayer.setAffineTransform(transform)
            detectionOverlay.addSublayer(lineLayer)
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
        layer.borderWidth = 4
        
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
