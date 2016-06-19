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
        if self.visibility == .Gone {
            self._size.width = LayoutXMLLength.Zero
        }
        // Match Parent
        else if self.sizeInfo.width == LayoutXMLLength.MatchParent {
            
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
        else if self.sizeInfo.width == LayoutXMLLength.WrapContent {
            
            let matchParents: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.width == LayoutXMLLength.MatchParent ? subview : nil
            }
            let others: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.width != LayoutXMLLength.MatchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureWidth()
            }
            
            _size.width = others.map { (subview: UIView) -> CGFloat in
                return subview._size.width + (subview.margin.left + subview.margin.right) + (padding.left + padding.right)
            }.maxElement() ?? 0.0
            
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
        if visibility == .Gone {
            _size.height = LayoutXMLLength.Zero
        }
        // match parent
        else if sizeInfo.height == LayoutXMLLength.MatchParent {
            
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
        else if sizeInfo.height == LayoutXMLLength.WrapContent {
            
            let matchParents: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height == LayoutXMLLength.MatchParent ? subview : nil
            }
            let others: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height != LayoutXMLLength.MatchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureHeight()
            }
            
            _size.height = others.map { (subview: UIView) -> CGFloat in
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
    
    public func measureSubviewsHorizontal() {
        
    }
    
    public func measureSubviewsVertical() {
        
    }
    
    public func layout() {
        
        if self.visibility == .Gone {
            return
        }
        
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
