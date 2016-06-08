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
public protocol LayoutXMLLayouter {
    
    /// Refresh Layout
    func requestLayout()
    
    /// Layout Children
    func layout()
}

/// Defalut implementations for layouter of UIView.
extension LayoutXMLLayouter where Self: UIView {
    
    /// Execute measure and layout subviews.
    public func requestLayout() {
        self.measure()
        self.layout()
    }
    
    /// Layout Recursively
    public func layout() {
        
        self.frame = CGRectMake(_origin.x, _origin.y, _size.width, _size.height)
        
        // set subview frames
        for subview in self.subviews {
            subview._origin.x = padding.left + subview.margin.left
            subview._origin.y = padding.top + subview.margin.top
            subview.frame = CGRectMake(subview._origin.x, subview._origin.y, subview._size.width, subview._size.height)
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
        }
    }
}

/// Manage shared serial queue for work of layout.
class LayoutXMLLayouterWorker: NSObject, OS_dispatch_queue {
    class var worker: OS_dispatch_queue {
        struct Static {
            static let instance: OS_dispatch_queue = dispatch_queue_create("com.jpn.naru.layoutxml.worker", DISPATCH_QUEUE_SERIAL)
        }
        return Static.instance
    }
}
