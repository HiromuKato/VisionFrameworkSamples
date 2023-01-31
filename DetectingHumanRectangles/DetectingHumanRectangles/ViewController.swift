//
//  ViewController.swift
//  DetectingHumanRectangles
//
//  Created by hiromu on 2023/01/31.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    @IBOutlet weak private var previewView: UIView!
    private let session = AVCaptureSession()
    // カメラデバイスからのビデオを表示するコアアニメーションレイヤー
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    // ビデオを記録し、処理のためにビデオフレームへのアクセスを提供するキャプチャ出力
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // 新しいビデオフレームが書き込まれたことをデリゲートに通知する
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // サブクラスで実装する
    }
    
    // ビデオフレームが破棄されたことをデリゲートに通知する
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
         //print("frame dropped")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 再作成できるすべてのリソースを破棄する
    }
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // ビデオデバイス(背面の広角ビデオカメラ)を選択し、入力を行う
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        // 出力の品質レベルまたはビットレートを示すプリセット値
        session.sessionPreset = .vga640x480
        
        // セッションにビデオ入力を追加する
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        // セッションにビデオデータ出力を追加する
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // 既存のフレームを処理するディスパッチキューがブロックされている間にキャプチャされたフレームを破棄する
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            // 出力の圧縮設定
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            // コールバックを呼び出すためのサンプルバッファデリゲートとキューを設定する
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        // 指定されたメディアタイプの入力ポートとの最初の接続を返す
        let captureConnection = videoDataOutput.connection(with: .video)
        print("orientation: \(String(describing: captureConnection?.videoOrientation.rawValue))") // AVCaptureVideoOrientation.landscapeRight
        print("isVideoMirrored: \(String(describing: captureConnection?.isVideoMirrored))") // false
        print("automaticallyAdjustsVideoMirroring: \(String(describing: captureConnection?.automaticallyAdjustsVideoMirroring))") // false
        captureConnection?.videoOrientation = .portrait
        //print("available formats: \(String(describing: videoDevice?.formats))")
        
        // 常にフレームを処理する
        captureConnection?.isEnabled = true
        do {
            // デバイスのハードウェアプロパティを構成するための排他的アクセスを要求する
            try  videoDevice!.lockForConfiguration()
            // ビデオのサイズをエンコードされたピクセルで返す
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.height)
            bufferSize.height = CGFloat(dimensions.width)
            // デバイスのハードウェアプロパティに対する排他制御を解放する
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        
        // レイヤーをキャプチャセッションに接続する
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        // レイヤーがその境界内でビデオコンテンツを表示する方法を示す
        // resizeAspectFill : ビデオは縦横比を維持し、レイヤーの bounds を埋める
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    // キャプチャを開始する
    func startCaptureSession() {
        session.startRunning()
    }
    
    // キャプチャ設定をクリーンアップする
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
    // 画面の回転をロックする
    override var shouldAutorotate: Bool {
        return false
    }
    
    // ポートレイト表示に固定する
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

