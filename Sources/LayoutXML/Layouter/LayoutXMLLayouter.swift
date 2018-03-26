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
    
    /// Measure subviews horizontal and vertical.
    func measureSubviews()
    
    /// Measure subviews horizontal.
    func measureSubviewsHorizontal()
    
    /// Measure subviews vertical.
    func measureSubviewsVertical()
    
    /// Request to refresh layout.
    func requestLayout()
    
    /// Layout child views.
    func layout()
}

/// Defalut implementations for layouter.
extension LayoutXMLLayouter where Self: UIView {
    
    /// Execute measure and layout child views.
    public func requestLayout() {
        measure()
        measureSubviews()
        layout()
    }
    
    public func measureSubviews() {
        
        measureSubviewsHorizontal()
        measureSubviewsVertical()
        
        let layouters: [LayoutXMLLayouter] = subviews.flatMap { (subview: UIView) -> LayoutXMLLayouter? in
            return subview as? LayoutXMLLayouter
        }
        for layouter in layouters {
            layouter.measureSubviews()
        }
    }
}

/// Apply shared serial queue for work of layout.
class LayoutXMLLayouterWorker: NSObject {
    class var worker: DispatchQueue {
        struct Static {
            static let instance: DispatchQueue = DispatchQueue(label: "com.jpn.naru.layoutxml.worker")
        }
        return Static.instance
    }
}
