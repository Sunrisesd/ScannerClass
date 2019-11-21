//
//  Platform.swift
//  CocoaPodsManager
//
//  Created by Sunrise on 2019/11/21.
//  Copyright © 2019 ANSO. All rights reserved.
//

import Foundation

struct Platform {
    
    static let isSimulator: Bool = {
        
        #if swift(>=4.1)
          #if targetEnvironment(simulator)
            return true
          #else
            return false
          #endif
        #else
          #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
          #else
            return false
          #endif
        #endif
    }()
}
