//
//  ContoursDetectionViewController.swift
//  DetectingContours
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import AVFoundation
import Vision

class ContoursDetectionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    private var request = VNDetectContoursRequest()
    
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
        
        // レイヤーのスケーリングとミラーリングを行う
        detectionOverlay.setAffineTransform(CGAffineTransform(scaleX: scale, y: -scale))
        
        // レイヤーを中央に配置
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // 現在のトランザクション中に行われたすべての変更をコミットする
        CATransaction.commit()
    }
    
    func setupVision() {
        // 輪郭検出のリクエスト内容設定
        request = VNDetectContoursRequest(completionHandler: contoursHandler)
        request.contrastAdjustment = 1.0 // 画像のコントラストを調整する量
        request.contrastPivot = 0.5 // コントラストのピボットとして使用するピクセル値
        request.detectsDarkOnLight = true // 明るい背景にある暗いオブジェクトを検出する
        request.maximumImageDimension = 200 // 輪郭検出に使用する画像の最大寸法
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
    
    // 輪郭検出時の処理
    func contoursHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNContoursObservation] else {
            return
        }
        
        drawContours(observations)
    }
    
    // 輪郭の描画処理
    func drawContours(_ observations: [VNContoursObservation])
    {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // 全ての古い認識されたオブジェクトを削除する
        detectionOverlay.sublayers = nil
        
        for observation in observations {
            for contours in observation.topLevelContours {
                // 検出された輪郭のCGPathは左下が(0, 0)、右上が(1, 1) という座標系になっているが、
                // detectionOverlay を調整済みのためノーマライズされた値のスケール処理のみで良い
                let path = contours.normalizedPath
                let xSize:CGFloat = bufferSize.width
                let ySize:CGFloat = bufferSize.height
                var transform = CGAffineTransform(scaleX: xSize, y: ySize)
                let transPath = path.copy(using: &transform)
                
                // パスの描画
                let pathLayer = CAShapeLayer()
                var frame = self.view.bounds
                frame.origin.x = 0
                frame.origin.y = 0
                frame.size.width = xSize
                frame.size.height = ySize
                pathLayer.frame = frame
                pathLayer.path = transPath
                pathLayer.strokeColor = UIColor.red.cgColor
                pathLayer.lineWidth = 3
                pathLayer.fillColor = UIColor.clear.cgColor
                
                detectionOverlay.addSublayer(pathLayer)
            }
        }
        
        CATransaction.commit()
    }
}
