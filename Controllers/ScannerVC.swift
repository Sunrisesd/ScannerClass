//
//  ScannerVC.swift
//  CocoaPodsManager
//
//  Created by Sunrise on 2019/11/21.
//  Copyright © 2019 ANSO. All rights reserved.
//

import UIKit
import AVFoundation

/// 扫描主页面
public class ScannerVC: UIViewController {
    
    public lazy var headerViewController:HeaderVC = .init()
    
    public lazy var cameraViewController:CameraVC = .init()
    
    /// 动画样式
    public var animationStyle:ScanAnimationStyle = .default {
        
        didSet{
            
            cameraViewController.animationStyle = animationStyle
        }
    }
    
    // 扫描框颜色
    public var scannerColor:UIColor = .red {
        
        didSet{
            
            cameraViewController.scannerColor = scannerColor
        }
    }
    
    public var scannerTips:String = "" {
        
        didSet{
            
           cameraViewController.scanView.tips = scannerTips
        }
    }
    
    /// `AVCaptureMetadataOutput` metadata object types.
    public var metadata = AVMetadataObject.ObjectType.metadata {
        
        didSet{
            
            cameraViewController.metadata = metadata
        }
    }
    
    public var successBlock:((String)->())?
    
    public var errorBlock:((Error)->())?
    
    /// 设置标题
    public override var title: String?{
        
        didSet{
            
            if navigationController == nil {
                
                headerViewController.title = title
            }
        }
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        cameraViewController.startCapturing()
    }
}

// MARK: - CustomMethod
extension ScannerVC {
    
    func setupUI() {
        
        if title == nil {
            
            title = "扫一扫"
        }
        
        view.backgroundColor = .black
        
        headerViewController.delegate = self
        
        cameraViewController.metadata = metadata
        
        cameraViewController.animationStyle = animationStyle
        
        cameraViewController.delegate = self
        
        add(cameraViewController)
        
        add(headerViewController)
    }
    
    /// 扫描页面
    /// - Parameters:
    ///   - title: 标题
    ///   - color: 扫描框颜色
    ///   - style: 扫描框样式
    ///   - tips: 提示文字
    ///   - success: 闭包回调
    public func setupScanner(_ title:String? = nil, _ color:UIColor? = nil, _ style:ScanAnimationStyle? = nil, _ tips:String? = nil, _ success:@escaping ((String)->())) {
        
        if title != nil {
            
            self.title = title
        }
        
        if color != nil {
            
            scannerColor = color!
        }
        
        if style != nil {
            
            animationStyle = style!
        }
        
        if tips != nil {
            
            scannerTips = tips!
        }
        
        successBlock = success
    }
    
}

// MARK: - HeaderViewControllerDelegate
extension ScannerVC:HeaderViewControllerDelegate {
    
    /// 点击关闭
    public func didClickedCloseButton() {
        
        if navigationController != nil {
            
            self.navigationController?.popViewController(animated: true)
            
            return
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 点击相册图片
    public func didClickedImageButton(_ valueString: String) {
        
        successBlock?(valueString)
    }
}

// MARK: - CameraViewControllerDelegate
extension ScannerVC:CameraViewControllerDelegate {
    
    func didOutput(_ code: String) {
        
        successBlock?(code)
    }
    
    func didReceiveError(_ error: Error) {
        
        errorBlock?(error)
    }
}
