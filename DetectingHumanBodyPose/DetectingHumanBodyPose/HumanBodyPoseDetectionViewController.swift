//
//  HumanBodyPoseDetectionViewController.swift
//  DetectingHumanBodyPose
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import AVFoundation
import Vision

class HumanBodyPoseDetectionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    private var request = VNDetectHumanBodyPoseRequest()
    
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
        // 人体検出のリクエスト内容設定
        request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
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
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // 全ての古い認識されたオブジェクトを削除する
        detectionOverlay.sublayers = nil
        
        // 各観測を処理して、認識された体のポーズポイントを見つける
        observations.forEach { processObservation($0) } // $0はクロージャの第一引数を表す
        
        CATransaction.commit()
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        
        // 全てのポイントを取得する
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return }
        
        // 正規化された x, y 座標から CGPoints を取得する
        let imagePoints: [CGPoint] = observation.availableJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            // ポイントを正規化座標から画像座標に変換する
            return VNImagePointForNormalizedPoint(point.location,
                                                  Int(bufferSize.width),
                                                  Int(bufferSize.height))
        }
        
        drawCircle(points: imagePoints)
        drawLine(points: recognizedPoints)
    }
    
    // ジョイント位置に円を描画する
    private func drawCircle(points: [CGPoint])
    {
        for point in points {
            let layer = CAShapeLayer()
            let size = 10
            layer.path = UIBezierPath(ovalIn: CGRect(x: Int(point.x) - size/2,
                                                     y: Int(point.y) - size/2,
                                                     width: size,
                                                     height: size)).cgPath
            layer.fillColor = UIColor.green.cgColor
            detectionOverlay.addSublayer(layer)
        }
    }
    
    // ジョイント間に線を描画する
    private func drawLine(points: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        // 不正な線の描画を防止
        for point in points {
            //print(point.value.x, point.value.y)
            if point.value.confidence < 0 || (point.value.x == 0.0 && point.value.y == 1.0) {
                return
            }
        }
        
        let xScale =  bufferSize.width
        let yScale =  bufferSize.height
        let lineWidth: CGFloat = 3.0
        
        // 左腕
        let leftArmLayer = CAShapeLayer()
        leftArmLayer.lineWidth = lineWidth
        let leftArmLine = UIBezierPath();
        leftArmLine.move(to: CGPoint(x: points[.neck]!.x * xScale, y: points[.neck]!.y * yScale));
        leftArmLine.addLine(to: CGPoint(x: points[.leftShoulder]!.x * xScale, y: points[.leftShoulder]!.y * yScale));
        leftArmLine.addLine(to: CGPoint(x: points[.leftElbow]!.x * xScale, y: points[.leftElbow]!.y * yScale));
        leftArmLine.addLine(to: CGPoint(x: points[.leftWrist]!.x * xScale, y: points[.leftWrist]!.y * yScale));
        leftArmLayer.strokeColor = UIColor.white.cgColor
        leftArmLayer.fillColor = UIColor.clear.cgColor
        leftArmLayer.path = leftArmLine.cgPath
        detectionOverlay.addSublayer(leftArmLayer)
        
        // 右腕
        let rightArmLayer = CAShapeLayer()
        rightArmLayer.lineWidth = lineWidth
        let rightArmLine = UIBezierPath();
        rightArmLine.move(to: CGPoint(x: points[.neck]!.x * xScale, y: points[.neck]!.y * yScale));
        rightArmLine.addLine(to: CGPoint(x: points[.rightShoulder]!.x * xScale, y: points[.rightShoulder]!.y * yScale));
        rightArmLine.addLine(to: CGPoint(x: points[.rightElbow]!.x * xScale, y: points[.rightElbow]!.y * yScale));
        rightArmLine.addLine(to: CGPoint(x: points[.rightWrist]!.x * xScale, y: points[.rightWrist]!.y * yScale));
        rightArmLayer.strokeColor = UIColor.white.cgColor
        rightArmLayer.fillColor = UIColor.clear.cgColor
        rightArmLayer.path = rightArmLine.cgPath
        detectionOverlay.addSublayer(rightArmLayer)
        
        // 左脚
        let leftLegLayer = CAShapeLayer()
        leftLegLayer.lineWidth = lineWidth
        let leftLegLine = UIBezierPath();
        leftLegLine.move(to: CGPoint(x: points[.root]!.x * xScale, y: points[.root]!.y * yScale));
        leftLegLine.addLine(to: CGPoint(x: points[.leftHip]!.x * xScale, y: points[.leftHip]!.y * yScale));
        leftLegLine.addLine(to: CGPoint(x: points[.leftKnee]!.x * xScale, y: points[.leftKnee]!.y * yScale));
        leftLegLine.addLine(to: CGPoint(x: points[.leftAnkle]!.x * xScale, y: points[.leftAnkle]!.y * yScale));
        leftLegLayer.strokeColor = UIColor.white.cgColor
        leftLegLayer.fillColor = UIColor.clear.cgColor
        leftLegLayer.path = leftLegLine.cgPath
        detectionOverlay.addSublayer(leftLegLayer)
        
        // 右脚
        let rightLegLayer = CAShapeLayer()
        rightLegLayer.lineWidth = lineWidth
        let rightLegLine = UIBezierPath();
        rightLegLine.move(to: CGPoint(x: points[.root]!.x * xScale, y: points[.root]!.y * yScale));
        rightLegLine.addLine(to: CGPoint(x: points[.rightHip]!.x * xScale, y: points[.rightHip]!.y * yScale));
        rightLegLine.addLine(to: CGPoint(x: points[.rightKnee]!.x * xScale, y: points[.rightKnee]!.y * yScale));
        rightLegLine.addLine(to: CGPoint(x: points[.rightAnkle]!.x * xScale, y: points[.rightAnkle]!.y * yScale));
        rightLegLayer.strokeColor = UIColor.white.cgColor
        rightLegLayer.fillColor = UIColor.clear.cgColor
        rightLegLayer.path = rightLegLine.cgPath
        detectionOverlay.addSublayer(rightLegLayer)
        
        // 体
        let bodyLayer = CAShapeLayer()
        bodyLayer.lineWidth = lineWidth
        let bodyLine = UIBezierPath();
        bodyLine.move(to: CGPoint(x: points[.root]!.x * xScale, y: points[.root]!.y * yScale));
        bodyLine.addLine(to: CGPoint(x: points[.neck]!.x * xScale, y: points[.neck]!.y * yScale));
        bodyLine.addLine(to: CGPoint(x: points[.nose]!.x * xScale, y: points[.nose]!.y * yScale));
        bodyLayer.strokeColor = UIColor.white.cgColor
        bodyLayer.fillColor = UIColor.clear.cgColor
        bodyLayer.path = bodyLine.cgPath
        detectionOverlay.addSublayer(bodyLayer)
    }
    
}
