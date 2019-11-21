## 关于

-用于扫描二维码和条形码以及生成二维码与条形码，支持扫描本地二维码，暂不支持扫描本地条形码

## 注意
-使用时需要在工程中添加访问相机权限

## 需求

- iOS 9.0+
- Xcode 9.0+
- Swift 4.0+

## 安装

### CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod 'ScannerClass'
end
```
## 用法

```swift
import ScannerClass

class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        let vc = ScannerVC()
        
        // 1.默认方式
        vc.setupScanner { (code) in
            
            print(code)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        // 2.微信
        vc.setupScanner("微信扫一扫", .green, .default, "将二维码/条码放入框内，即可自动扫描") { (code) in
            
            print(code)
            
            self.navigationController?.popViewController(animated: true)
        } 
        
        // 3.支付宝
        vc.setupScanner("支付宝扫一扫", .blue, .grid, "放入框内，自动扫描") { (code) in
            
            print(code)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        let myWechat = "147258"
        
        let myWechatNum = "4234115"
        
        // 4.生成二维码图片
        QRCodeView.image = UIImage.generateQRCode(myWechat, screenWidth - 80, nil, .purple)
        
        // 5.生成条形码图片
        barCodeView.image = UIImage.generateCode(myWechatNum, CGSize(width: screenWidth - 80, height: (screenWidth - 80)/3), .blue)
        
    }
}

```


