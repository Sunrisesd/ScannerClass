//
//  HeaderVC.swift
//  CocoaPodsManager
//
//  Created by Sunrise on 2019/11/21.
//  Copyright © 2019 ANSO. All rights reserved.
//

import UIKit

public protocol HeaderViewControllerDelegate: class {
    
    func didClickedCloseButton()
    
    func didClickedImageButton(_ valueString:String)
}

/// 头部视图
public class HeaderVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 设置导航栏标题
    public override var title: String? {
        
        didSet{
            
            titleLabel.text = title
        }
    }
    
    /// 返回图标
    public lazy var closeImage = imageNamed("icon_back")
    
    /// 相册图标
    public lazy var albumImage = imageNamed("album")
    
    /// 返回按钮
    public let backBtn = UIButton.init(type: .custom)
    
    /// 相册按钮
    public let albumBtn = UIButton.init(type: .custom)
    
    /// 标题
    public let titleLabel = UILabel.init()
    
    public weak var delegate:HeaderViewControllerDelegate?
    
    private let viewHeight:CGFloat = screenHeight >= 812 ? 88 : 64

    override public func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: viewHeight)
        
        self.setupUI()
    }
    
    private func setupUI() {
        
        backBtn.frame = CGRect(x: 20, y: viewHeight-35, width: 20, height: 20)
        backBtn.setBackgroundImage(closeImage, for: .normal)
        backBtn.addTarget(self, action: #selector(closeBtnClick(_:)), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        albumBtn.frame = CGRect(x: screenWidth-45, y: viewHeight-35, width: 25, height: 20)
        albumBtn.setBackgroundImage(albumImage, for: .normal)
        albumBtn.addTarget(self, action: #selector(fromAlbum(_:)), for: .touchUpInside)
        self.view.addSubview(albumBtn)
        
        titleLabel.frame = CGRect(x: (screenWidth-100)/2, y: viewHeight-35, width: 100, height: 20)
        titleLabel.text = "扫一扫"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
    }
    
    @objc private func closeBtnClick(_ sender: Any) {
        
        delegate?.didClickedCloseButton()
    }

    // 选取相册
    @objc private func fromAlbum(_ sender: AnyObject) {
        
        // 判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            // 初始化图片控制器
            let picker = UIImagePickerController()
            
            // 设置代理
            picker.delegate = self
            
            // 指定图片控制器类型
            picker.sourceType = .photoLibrary
            
            // 弹出控制器，显示界面
            self.present(picker, animated: true, completion: nil)
            
        }else{
            
            self.showAlert("读取相册错误")
        }
    }
     
    // 选择图片成功后代理
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        
        // 获取选择的原图
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let valueString = self.recognizeQRCode(image)
        
        if valueString!.count == 0 {
            
            self.showAlert("无法解析图片")
            
            return
        }
        
        self.delegate?.didClickedImageButton(valueString!)
         
        // 图片控制器退出
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// 二维码识别
    ///
    /// - Returns: 二维码内容
    private func recognizeQRCode(_ image:UIImage) -> String? {
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: CIImage.init(image: image)!)
        
        guard (features?.count)! > 0 else {
            
            return nil
        }
        
        let feature = features?.first as? CIQRCodeFeature
        
        return feature?.messageString
    }
    
    private func showAlert(_ message:String) {
        
        let alertVC = UIAlertController.init(title: "温馨提示", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: "确定", style: .default, handler: nil)
        
        alertVC.addAction(action)
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

