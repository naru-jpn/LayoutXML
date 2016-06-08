//
//  LayoutXMLLayouter.swift
//  
//
//  Created by naru on 2016/05/03.
//
//

import UIKit
import Foundation

/// Protocol to layout child views.
protocol LayoutXMLLayouter {
    
    /// Request layout for current layout settings.
    func requestLayout()
    
    /// Layout children.
    func layout()
}

/// Manage shared serial queue.
class LayoutXMLLayouterWorker: NSObject, OS_dispatch_queue {
    class var worker: OS_dispatch_queue {
        struct Static {
            static let instance: OS_dispatch_queue = dispatch_queue_create("com.jpn.naru.layoutxml.worker", DISPATCH_QUEUE_SERIAL)
        }
        return Static.instance
    }
}
