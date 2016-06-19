//
//  LinearLayout.swift
//  
//
//  Created by naru on 2016/05/03.
//
//

import UIKit
import Foundation

/// Orientation
public enum LayoutXMLOrientation: Int {
    
    case Horizontal = 0
    case Vertical = 1
    
    init(string: String) {
        if string == LayoutXML.Constants.LinearLayout.Orientations.Vertical {
            self = .Vertical
        } else {
            self = .Horizontal
        }
    }
}

// Gravity
public struct LayoutXMLGravity: OptionSetType {

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    static let Left             = LayoutXMLGravity(rawValue: 0)
    static let Right            = LayoutXMLGravity(rawValue: 1 << 0)
    static let CenterHorizontal = LayoutXMLGravity(rawValue: 1 << 1)
    static let Top              = LayoutXMLGravity(rawValue: 0)
    static let Bottom           = LayoutXMLGravity(rawValue: 1 << 2)
    static let CenterVertical   = LayoutXMLGravity(rawValue: 1 << 3)
    static let Center        : LayoutXMLGravity = [.CenterHorizontal, .CenterVertical]
    static let Default       : LayoutXMLGravity = [.Left, .Top]
    static let HorizontalMask: LayoutXMLGravity = [.Right, .CenterHorizontal]
    static let VerticalMask  : LayoutXMLGravity = [.Bottom, .CenterVertical]

    init(string: String) {
        
        func gravity(component: String) -> LayoutXMLGravity {
            switch component {
            case LayoutXML.Constants.LinearLayout.Gravities.Left:
                return .Left
            case LayoutXML.Constants.LinearLayout.Gravities.Right:
                return .Right
            case LayoutXML.Constants.LinearLayout.Gravities.CenterHorizontal:
                return .CenterHorizontal
            case LayoutXML.Constants.LinearLayout.Gravities.Top:
                return .Top
            case LayoutXML.Constants.LinearLayout.Gravities.Bottom:
                return .Bottom
            case LayoutXML.Constants.LinearLayout.Gravities.CenterVertical:
                return .CenterVertical
            case LayoutXML.Constants.LinearLayout.Gravities.Center:
                return .Center
            default:
                return .Default
            }
        }
        
        let rawValue: Int = string.componentsSeparatedByString("|").filter { (component: String) -> Bool in
            component.characters.count > 0
        }.map { (component: String) -> Int in
            return gravity(component).rawValue
        }.reduce(LayoutXMLGravity.Default.rawValue, combine: |)
        
        self.rawValue = rawValue
    }
    
    public func isActive(gravity: LayoutXMLGravity) -> Bool {
        return self.rawValue & gravity.rawValue == gravity.rawValue
    }
}

@objc (LinearLayout)

public class LinearLayout: UIView, LayoutXMLLayouter {
    
    public var orientation: LayoutXMLOrientation = .Horizontal
    
    public var weightSum: CGFloat = 0.0
        
    public var widthSum: CGFloat = 0.0
    
    public var heightSum: CGFloat = 0.0
    
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
                self._size.width = 0.0
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
        
        // Gone
        if self.visibility == .Gone {
            self._size.height = LayoutXMLLength.Zero
        }
        // Match Parent
        else if self.sizeInfo.height == LayoutXMLLength.MatchParent {
            
            if let superview: UIView = self.superview {
                self._size.height = superview._size.height - (margin.top + margin.bottom) - (superview.padding.top + superview.padding.bottom)
            } else {
                self._size.height = 0.0
            }
            
            for subview in self.subviews {
                subview.measureHeight()
            }
        }
        // Wrap Content
        else if self.sizeInfo.height == LayoutXMLLength.WrapContent {
            
            let matchParents: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height == LayoutXMLLength.MatchParent ? subview : nil
            }
            let others: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height != LayoutXMLLength.MatchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureHeight()
            }
            
            self._size.height = others.map { (subview: UIView) -> CGFloat in
                return subview._size.height + (subview.margin.top + subview.margin.bottom) + (padding.top + padding.bottom)
            }.maxElement() ?? 0.0
            
            for subview in matchParents {
                subview.measureHeight()
            }
        }
        // Others
        else {
            self._size.height = self.sizeInfo.height
            
            for subview in subviews {
                subview.measureHeight()
            }
        }
    }
        
    public func measureSubviewsHorizontal() {
        
        for subview in subviews {
            subview.measureWidth()
        }
        
        let widths: [CGFloat] = self.subviews.map { (subview: UIView) -> CGFloat in
            return subview._size.width + subview.margin.left + subview.margin.right
        }
        self.widthSum = widths.reduce(0.0, combine: +)
        
        // Adjust Subviews Horizontal
        if self.orientation == .Horizontal {
            
            let weightSum: CGFloat = self.weightSum > 0.0 ? self.weightSum : self.subviews.map { (subview: UIView) -> CGFloat in
                return subview.weight
            }.reduce(0.0, combine: +)
            
            let diff: CGFloat = self._size.width - (self.padding.left + self.padding.right) - self.widthSum
            
            let adjustedSubviews: [UIView] = self.subviews.filter { (subview: UIView) -> Bool in
                subview.weight != 0.0
            }
            for adjustedSubview in adjustedSubviews {
                let rate: CGFloat = adjustedSubview.weight / weightSum
                let adjustedWidth: CGFloat = diff * rate
                adjustedSubview._size.width =  adjustedSubview._size.width + adjustedWidth
            }
            
            let widths: [CGFloat] = self.subviews.map { (subview: UIView) -> CGFloat in
                return subview._size.width + subview.margin.left + subview.margin.right
            }
            self.widthSum = widths.reduce(0.0, combine: +)
        }
    }
    
    public func measureSubviewsVertical() {
        
        for subview in self.subviews {
            subview.measureHeight()
        }
        
        let heights: [CGFloat] = self.subviews.map { (subview: UIView) -> CGFloat in
            return subview._size.height + subview.margin.top + subview.margin.bottom
        }
        self.heightSum = heights.reduce(0.0, combine: +)
        
        // Adjust Subviews Vertical
        if self.orientation == .Vertical {
            
            let weightSum: CGFloat = self.weightSum > 0.0 ? self.weightSum : self.subviews.map { (subview: UIView) -> CGFloat in
                return subview.weight
                }.reduce(0.0, combine: +)
            
            let diff: CGFloat = self._size.height - (self.padding.top + self.padding.bottom) - self.heightSum
            
            let adjustedSubviews: [UIView] = self.subviews.filter { (subview: UIView) -> Bool in
                subview.weight != 0.0
            }
            for adjustedSubview in adjustedSubviews {
                let rate: CGFloat = adjustedSubview.weight / weightSum
                let adjustedHeight: CGFloat = diff * rate
                adjustedSubview._size.height =  adjustedSubview._size.height + adjustedHeight
            }
            
            let heights: [CGFloat] = self.subviews.map { (subview: UIView) -> CGFloat in
                return subview._size.height + subview.margin.top + subview.margin.bottom
            }
            self.heightSum = heights.reduce(0.0, combine: +)
        }
    }
    
    public func layout() {
        
        if self.visibility == .Gone {
            return
        }
        
        self.frame = CGRectMake(self.margin.left, self.margin.top, _size.width, _size.height)

        if self.orientation == .Horizontal {
            layoutHorizontal()
        }
        if self.orientation == .Vertical {
            layoutVertical()
        }
    }
    
    private func layoutHorizontal() {
        
        var buf: CGFloat = self.widthSum
        var currentPosition: CGPoint = CGPointMake(self.padding.left, self.padding.top)
        
        let usableWidth: CGFloat = self._size.width - (self.padding.left + self.padding.right)
        let usableHeight: CGFloat = self._size.height - (self.padding.top + self.padding.bottom)
        let majorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: self.gravity.rawValue & LayoutXMLGravity.HorizontalMask.rawValue)
        let minorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: self.gravity.rawValue & LayoutXMLGravity.VerticalMask.rawValue)
        
        if majorGravity.isActive(.Right) {
            currentPosition.x = currentPosition.x + usableWidth - self.widthSum
        } else if majorGravity.isActive(.CenterHorizontal) {
            currentPosition.x = currentPosition.x + (usableWidth - self.widthSum)/2.0
        }
        
        for subview in self.subviews {
            
            if majorGravity == .Default {
                if subview.gravity.isActive(.Right) {
                    currentPosition.x = (self.padding.left + usableWidth - buf)
                } else if subview.gravity.isActive(.CenterHorizontal) {
                    currentPosition.x = (self.padding.left + usableWidth - buf - currentPosition.x)/2.0
                }
            }
            
            currentPosition.x = currentPosition.x + subview.margin.left
            
            let localGravity: LayoutXMLGravity = minorGravity != .Default ? minorGravity : subview.gravity
            let subUsableHeight: CGFloat = (subview._size.height + subview.margin.top + subview.margin.bottom)
            
            if localGravity.isActive(.Bottom) {
                currentPosition.y = self.padding.top + subview.margin.top + (usableHeight - subUsableHeight)
            } else if localGravity.isActive(.CenterVertical) {
                currentPosition.y = self.padding.top + subview.margin.top + (usableHeight - subUsableHeight)/2.0
            } else {
                currentPosition.y = self.padding.top + subview.margin.top
            }
            
            subview._origin = currentPosition
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
            subview.frame = CGRectMake(subview._origin.x, subview._origin.y, subview._size.width, subview._size.height)

            currentPosition.x = currentPosition.x + subview._size.width + subview.margin.right
            buf = buf - (subview._size.width + subview.margin.left + subview.margin.right)
        }
    }
    
    private func layoutVertical() {
        
        var buf: CGFloat = self.heightSum
        var currentPosition: CGPoint = CGPointMake(self.padding.left, self.padding.top)
        
        let usableWidth: CGFloat = self._size.width - (self.padding.left + self.padding.right)
        let usableHeight: CGFloat = self._size.height - (self.padding.top + self.padding.bottom)
        let majorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: self.gravity.rawValue & LayoutXMLGravity.VerticalMask.rawValue)
        let minorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: self.gravity.rawValue & LayoutXMLGravity.HorizontalMask.rawValue)
        
        if majorGravity.isActive(.Bottom) {
            currentPosition.y = currentPosition.y + usableHeight - self.heightSum
        } else if majorGravity.isActive(.CenterVertical) {
            currentPosition.y = currentPosition.y + (usableHeight - self.heightSum)/2.0
        }
        
        for subview in self.subviews {
            
            if majorGravity == .Default {
                if subview.gravity.isActive(.Bottom) {
                    currentPosition.y = (self.padding.top + usableHeight - buf)
                } else if subview.gravity.isActive(.CenterVertical) {
                    currentPosition.y = (self.padding.top + usableHeight - buf - currentPosition.y)/2.0
                }
            }
            
            currentPosition.y = currentPosition.y + subview.margin.top
            
            let localGravity: LayoutXMLGravity = minorGravity != .Default ? minorGravity : subview.gravity
            let subUsableWidth: CGFloat = (subview._size.width + subview.margin.left + subview.margin.right)
            
            if localGravity.isActive(.Right) {
                currentPosition.x = self.padding.left + subview.margin.left + (usableWidth - subUsableWidth)
            } else if localGravity.isActive(.CenterHorizontal) {
                currentPosition.x = self.padding.left + subview.margin.left + (usableWidth - subUsableWidth)/2.0
            } else {
                currentPosition.x = self.padding.left + subview.margin.left
            }
            
            subview._origin = currentPosition
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
            subview.frame = CGRectMake(subview._origin.x, subview._origin.y, subview._size.width, subview._size.height)
            
            currentPosition.y = currentPosition.y + subview._size.height + subview.margin.bottom
            buf = buf - (subview._size.height + subview.margin.top + subview.margin.bottom)
        }
    }
}
