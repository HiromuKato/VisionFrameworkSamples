//
//  AnimalsRecognitionViewController.swift
//  RecognizingAnimals
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import AVFoundation
import Vision

class AnimalsRecognitionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    private var request = VNRecognizeAnimalsRequest()
    
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
        detectionOverlay.setAffineTransform(CGAffineTransform(scaleX: scale, y: -scale))
        // レイヤーを中央に配置
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // 現在のトランザクション中に行われたすべての変更をコミットする
        CATransaction.commit()
    }
    
    func setupVision() {
        // 動物認識のリクエスト内容設定
        request = VNRecognizeAnimalsRequest(completionHandler: animalHandler)
        // サポートされている識別子
        // VNAnimalIdentifier(https://developer.apple.com/documentation/vision/vnanimalidentifier)
        print(try! request.supportedIdentifiers())
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
    
    // 動物認識処理
    func animalHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedObjectObservation] else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // 全ての古い認識されたオブジェクトを削除する
        detectionOverlay.sublayers = nil
        
        draw(observations)
        
        CATransaction.commit()
    }
    
    private func draw(_ observations: [VNRecognizedObjectObservation])
    {
        for observation in observations {
            let objectBounds = VNImageRectForNormalizedRect(observation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            let topLabelObservation = observation.labels[0]
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        //textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width - 10, height: bounds.size.height - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // ミラー処理
        textLayer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: -1.0))
        return textLayer
    }
    
}
