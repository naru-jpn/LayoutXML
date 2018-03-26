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

public class AbsoluteLayout: UIView, LayoutXMLLayouter {
            
    override public func measureWidth() {
        
        // Gone
        if self.visibility == .gone {
            self._size.width = LayoutXMLLength.zero
        }
        // Match Parent
        else if self.sizeInfo.width == LayoutXMLLength.matchParent {
            
            if let superview: UIView = self.superview {
                self._size.width = superview._size.width - (margin.left + margin.right) - (superview.padding.left + superview.padding.right)
            } else {
                _size.width = 0.0
            }
            
            for subview in self.subviews {
                subview.measureWidth()
            }
        }
        // Wrap Content
        else if self.sizeInfo.width == LayoutXMLLength.wrapContent {
            
            let matchParents: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.width == LayoutXMLLength.matchParent ? subview : nil
            }
            let others: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.width != LayoutXMLLength.matchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureWidth()
            }
            
            _size.width = others.map { (subview: UIView) -> CGFloat in
                return subview._size.width + (subview.margin.left + subview.margin.right) + (padding.left + padding.right)
            }.max() ?? 0.0
            
            for subview in matchParents {
                subview.measureWidth()
            }
        }
        // Others
        else {
            self._size.width = self.sizeInfo.width
            
            for subview in self.subviews {
                subview.measureWidth()
            }
        }
    }
    
    override public func measureHeight() {
        
        // gone
        if visibility == .gone {
            _size.height = LayoutXMLLength.zero
        }
        // match parent
        else if sizeInfo.height == LayoutXMLLength.matchParent {
            
            if let superview: UIView = superview {
                _size.height = superview._size.height - (margin.top + margin.bottom) - (superview.padding.top + superview.padding.bottom)
            } else {
                _size.height = 0.0
            }
            
            for subview in self.subviews {
                subview.measureHeight()
            }
        }
        // wrap content
        else if sizeInfo.height == LayoutXMLLength.wrapContent {
            
            let matchParents: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height == LayoutXMLLength.matchParent ? subview : nil
            }
            let others: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height != LayoutXMLLength.matchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureHeight()
            }
            
            _size.height = others.map { (subview: UIView) -> CGFloat in
                return subview._size.height + (subview.margin.top + subview.margin.bottom) + (padding.top + padding.bottom)
            }.max() ?? 0.0
            
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
    
    public func measureSubviewsHorizontal() {
        
    }
    
    public func measureSubviewsVertical() {
        
    }
    
    public func layout() {
        
        if self.visibility == .gone {
            return
        }
        
        self.frame = CGRect(x: _origin.x, y: _origin.y, width: _size.width, height: _size.height)
        
        // set subview frames
        for subview in self.subviews {
            subview._origin.x = padding.left + subview.margin.left
            subview._origin.y = padding.top + subview.margin.top
            subview.frame = CGRect(x: subview._origin.x, y: subview._origin.y, width: subview._size.width, height: subview._size.height)
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
        }
    }
}
