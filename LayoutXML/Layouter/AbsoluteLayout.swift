//
//  AbsoluteLayout.swift
//  
//
//  Created by naru on 2016/05/05.
//
//

import UIKit
import Foundation

@objc (AbsoluteLayout)

class AbsoluteLayout: UIView, LayoutXMLLayouter {
            
    override func measureWidth() {
        
        // gone
        if visibility == .Gone {
            _size.width = LayoutXMLLength.Zero
        }
        // match parent
        else if sizeInfo.width == LayoutXMLLength.MatchParent {
            
            if let superview = superview {
                _size.width = superview._size.width - (margin.left + margin.right) - (superview.padding.left + superview.padding.right)
            } else {
                _size.width = 0.0
            }
            
            for subview in subviews {
                subview.measureWidth()
            }
        }
        // wrap content
        else if sizeInfo.width == LayoutXMLLength.WrapContent {
            
            let matchParents: [UIView] = subviews.flatMap { subview in
                return subview.sizeInfo.width == LayoutXMLLength.MatchParent ? subview : nil
            }
            let others: [UIView] = subviews.flatMap { subview in
                return subview.sizeInfo.width != LayoutXMLLength.MatchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureWidth()
            }
            
            _size.width = others.map { subview in
                return subview._size.width + (subview.margin.left + subview.margin.right) + (padding.left + padding.right)
            }.maxElement() ?? 0.0
            
            for subview in matchParents {
                subview.measureWidth()
            }
        }
        // others
        else {
            _size.width = sizeInfo.width
            
            for subview in subviews {
                subview.measureWidth()
            }
        }
    }
    
    override func measureHeight() {
        
        // gone
        if visibility == .Gone {
            _size.height = LayoutXMLLength.Zero
        }
        // match parent
        else if sizeInfo.height == LayoutXMLLength.MatchParent {
            
            if let superview = superview {
                _size.height = superview._size.height - (margin.top + margin.bottom) - (superview.padding.top + superview.padding.bottom)
            } else {
                _size.height = 0.0
            }
            
            for subview in subviews {
                subview.measureHeight()
            }
        }
        // wrap content
        else if sizeInfo.height == LayoutXMLLength.WrapContent {
            
            let matchParents: [UIView] = subviews.flatMap { subview in
                return subview.sizeInfo.height == LayoutXMLLength.MatchParent ? subview : nil
            }
            let others: [UIView] = subviews.flatMap { subview in
                return subview.sizeInfo.height != LayoutXMLLength.MatchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureHeight()
            }
            
            _size.height = others.map { subview in
                return subview._size.height + (subview.margin.top + subview.margin.bottom) + (padding.top + padding.bottom)
            }.maxElement() ?? 0.0
            
            for subview in matchParents {
                subview.measureHeight()
            }
        }
        // others
        else {
            _size.height = sizeInfo.height
            
            for subview in subviews {
                subview.measureHeight()
            }
        }
    }
}
