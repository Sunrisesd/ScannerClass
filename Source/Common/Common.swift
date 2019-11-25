//
//  Common.swift
//  CocoaPodsManager
//
//  Created by Sunrise on 2019/11/21.
//  Copyright © 2019 ANSO. All rights reserved.
//

import Foundation
import UIKit

let bundle = Bundle(for: HeaderVC.self)

let screenWidth = UIScreen.main.bounds.width

let screenHeight = UIScreen.main.bounds.height

let statusHeight = UIApplication.shared.statusBarFrame.height

public func imageNamed(_ name:String)-> UIImage {
    
    guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else {

        return UIImage()
    }
    
//    guard let image = UIImage.init(named: "Resources.bundle/\(name)") else {
//
//        return UIImage()
//    }
    
    return image
}
