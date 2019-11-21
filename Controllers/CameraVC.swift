//
//  CameraVC.swift
//  CocoaPodsManager
//
//  Created by Sunrise on 2019/11/21.
//  Copyright © 2019 ANSO. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: class {
    
    func didOutput(_ code:String)
    
    func didReceiveError(_ error: Error)
}

/// 相机功能页面
public class CameraVC: UIViewController {
    
    weak var delegate:CameraViewControllerDelegate?
    
    lazy var animationImage = UIImage()
    
    /// 动画样式
    var animationStyle:ScanAnimationStyle = .default {
        
        didSet{
            
            if animationStyle == .default {
                
                animationImage = imageNamed("ScanLine")
                
            }else {
                
                animationImage = imageNamed("ScanNet")
            }
        }
    }
    
    lazy var scannerColor:UIColor = .red
    
    public lazy var flashBtn: UIButton = .init(type: .custom)
    
    private var torchMode:TorchMode = .off {
        
        didSet{
            
            guard let captureDevice = captureDevice, captureDevice.hasFlash else {
                
                return
            }
            
            guard captureDevice.isTorchModeSupported(torchMode.captureTorchMode) else {
                
                return
            }
            
            do {
                
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = torchMode.captureTorchMode
                captureDevice.unlockForConfiguration()
                
            }catch{}
            
            flashBtn.setImage(torchMode.image, for: .normal)
        }
    }
    
    /// `AVCaptureMetadataOutput` metadata object types.
    var metadata = [AVMetadataObject.ObjectType]()
    
    // MARK: - Video
    
    /// Video preview layer.
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    /// Video capture device. This may be nil when running in Simulator.
    private lazy var captureDevice = AVCaptureDevice.default(for: .video)
    
    /// Capture session.
    private lazy var captureSession = AVCaptureSession()
    
    lazy var scanView = ScanView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    
    /// 镜头的缩放变焦(digital zoom) 最多可达5x倍率
    private var zoomPinchGestureRecognizer = UIPinchGestureRecognizer()
    private var zoomTapGestureRecognizer = UITapGestureRecognizer()
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        scanView.startAnimation()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        scanView.stopAnimation()
    }
}

// MARK: - CustomMethod
extension CameraVC {
    
    func setupUI() {
        
        view.backgroundColor = .black
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        
        videoPreviewLayer?.frame = view.layer.bounds
        
        guard let videoPreviewLayer = videoPreviewLayer else {
            
            return
        }
        
        view.layer.addSublayer(videoPreviewLayer)
        
        scanView.scanAnimationImage = animationImage
        
        scanView.scanAnimationStyle = animationStyle
        
        scanView.cornerColor = scannerColor
        
        view.addSubview(scanView)
        
        setupCamera()
        
        setupTorch()
        
        // 捏合手势
        zoomPinchGestureRecognizer.addTarget(self, action: #selector(zoomPinch(_:)))
        view.addGestureRecognizer(zoomPinchGestureRecognizer)
        
        // 双击手势
        zoomTapGestureRecognizer.numberOfTapsRequired = 2
        zoomTapGestureRecognizer.addTarget(self, action: #selector(zoomTap))
        view.addGestureRecognizer(zoomTapGestureRecognizer)
    }
    
    /// 创建手电筒按钮
    func setupTorch() {
        
        let buttonSize:CGFloat = 37
        
        flashBtn.frame = CGRect(x: screenWidth - 20 - buttonSize, y: statusHeight + 44 + 20, width: buttonSize, height: buttonSize)
        
        flashBtn.addTarget(self, action: #selector(flashBtnClick), for: .touchUpInside)
        
        flashBtn.isHidden = true
        
        view.addSubview(flashBtn)
        
        view.bringSubviewToFront(flashBtn)
        
        torchMode = .off
    }
    
    // 设置相机
    func setupCamera() {
        
        setupSessionInput()
        
        setupSessionOutput()
    }
    
    // 捕获设备输入流
    private  func setupSessionInput() {
        
        guard !Platform.isSimulator else {
            
            return
        }
        
        guard let device = captureDevice else {
            
            return
        }
        
        do {
            
            let newInput = try AVCaptureDeviceInput(device: device)
            
            captureSession.beginConfiguration()
            
            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
                
                captureSession.removeInput(currentInput)
            }
            
            captureSession.addInput(newInput)
            
            captureSession.commitConfiguration()
            
        }catch {
            
            delegate?.didReceiveError(error)
        }
    }
    
    // 捕获元数据输出流
    private func setupSessionOutput() {
        
        guard !Platform.isSimulator else {
            
            return
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        captureSession.addOutput(videoDataOutput)
        
        let output = AVCaptureMetadataOutput()
        
        captureSession.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        for type in metadata {
            
            if !output.availableMetadataObjectTypes.contains(type) {
                
                return
            }
        }
        
        output.metadataObjectTypes = metadata
        
        videoPreviewLayer?.session = captureSession
        
        view.setNeedsLayout()
    }
    
    /// 开始扫描
    func startCapturing() {
        
        guard !Platform.isSimulator else {
            
            return
        }
        
        captureSession.startRunning()
    }
    
    /// 停止扫描
    func stopCapturing() {
        
        guard !Platform.isSimulator else {
            
            return
        }
        
        captureSession.stopRunning()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension CameraVC:AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        stopCapturing()
        
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            
            return
        }
        
        delegate?.didOutput(object.stringValue ?? "")
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraVC:AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil,target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        guard let metadata = metadataDict as? [String:Any],
            let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [String:Any],
            let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else {
                
                return
        }
        
        // 判断光线强弱
        if brightnessValue > -1.0 {
            
            flashBtn.isHidden = false
            
        }else{
            
            if torchMode == .on {
                
                flashBtn.isHidden = false
                
            }else{
                
                flashBtn.isHidden = true
            }
        }
    }
}

// MARK: - 手势操作
extension CameraVC {
    
    // 捏合手势触发响应
    @objc func zoomPinch(_ pinchTap:UIPinchGestureRecognizer) {
        
        let currentScale:CGFloat = pinchTap.scale > 1 ? pinchTap.scale-1 : -pinchTap.scale
        
        // 改变相机装置镜头缩放程度
        if let zoomFactor = captureDevice?.videoZoomFactor {
            
            var newZoomFactor = zoomFactor + currentScale
            
            if newZoomFactor <= 1.0 {
                
                newZoomFactor = 1.0
                
            }else if newZoomFactor >= 5.0 {
                
                newZoomFactor = 5.0
            }
            
            do {
                
                // 缩放前先获取装置的锁
                try captureDevice?.lockForConfiguration()
                // 让不同缩放因子能够平滑转换
                captureDevice!.ramp(toVideoZoomFactor: newZoomFactor, withRate: 3.0)
                // 新的缩放因子来完成缩放效果之后,解锁
                captureDevice?.unlockForConfiguration()
                
            }catch{
                
                print(error)
            }
        }
    }
    
    // 双击手势响应
    @objc func zoomTap() {
        
        let zoomFactor = captureDevice!.videoZoomFactor
        
        var newZoomFactor = zoomFactor
        
        if zoomFactor >= 3.0 {
            
            newZoomFactor = 1.0
            
        }else {
            
            newZoomFactor = 5.0
        }
        
        do {
            
            // 缩放前先获取装置的锁
            try captureDevice?.lockForConfiguration()
            // 让不同缩放因子能够平滑转换
            captureDevice!.ramp(toVideoZoomFactor: newZoomFactor, withRate: 3.0)
            // 新的缩放因子来完成缩放效果之后,解锁
            captureDevice?.unlockForConfiguration()
            
        }catch{
            
            print(error)
        }
    }
}

// MARK: - Click
extension CameraVC {
    
    @objc func flashBtnClick(sender:UIButton) {
        
        torchMode = torchMode.next
    }
}

