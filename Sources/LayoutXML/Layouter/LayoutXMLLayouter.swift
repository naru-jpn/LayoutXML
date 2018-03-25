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
    
    func measureSubviews()
    
    func measureSubviewsHorizontal()
    
    func measureSubviewsVertical()
    
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
        self.measureSubviews()
        self.layout()
    }
    
    public func measureSubviews() {
        
        measureSubviewsHorizontal()
        measureSubviewsVertical()
        
        let layouters: [LayoutXMLLayouter] = self.subviews.flatMap { (subview: UIView) -> LayoutXMLLayouter? in
            return subview as? LayoutXMLLayouter
        }
        for layouter in layouters {
            layouter.measureSubviews()
        }
    }
}

/// Manage shared serial queue for work of layout.
class LayoutXMLLayouterWorker: NSObject {
    class var worker: DispatchQueue {
        struct Static {
            static let instance: DispatchQueue = DispatchQueue(label: "com.jpn.naru.layoutxml.worker")
        }
        return Static.instance
    }
}