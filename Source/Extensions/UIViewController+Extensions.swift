//
//  UIViewController+Extensions.swift
//  CocoaPodsManager
//
//  Created by Sunrise on 2019/11/21.
//  Copyright © 2019 ANSO. All rights reserved.
//

import UIKit

extension UIViewController{
    
    public func add(_ childController:UIViewController) {
        
        childController.willMove(toParent: self)
        
        addChild(childController)
        
        view.addSubview(childController.view)
        
        childController.didMove(toParent: self)
    }
}
