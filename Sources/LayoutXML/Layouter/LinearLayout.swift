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
    
    /// Horizontal
    case horizontal = 0
    /// Vertical
    case vertical = 1
    
    init(string: String) {
        if string == LayoutXML.Constants.LinearLayout.Orientations.vertical {
            self = .vertical
        } else {
            self = .horizontal
        }
    }
}

// Gravity
public struct LayoutXMLGravity: OptionSet {

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    static let left             = LayoutXMLGravity(rawValue: 0)
    static let right            = LayoutXMLGravity(rawValue: 1 << 0)
    static let centerHorizontal = LayoutXMLGravity(rawValue: 1 << 1)
    static let top              = LayoutXMLGravity(rawValue: 0)
    static let bottom           = LayoutXMLGravity(rawValue: 1 << 2)
    static let centerVertical   = LayoutXMLGravity(rawValue: 1 << 3)
    static let center        : LayoutXMLGravity = [.centerHorizontal, .centerVertical]
    static let `default`     : LayoutXMLGravity = [.left, .top]
    static let horizontalMask: LayoutXMLGravity = [.right, .centerHorizontal]
    static let verticalMask  : LayoutXMLGravity = [.bottom, .centerVertical]

    init(string: String) {
        
        func gravity(_ component: String) -> LayoutXMLGravity {
            switch component {
            case LayoutXML.Constants.LinearLayout.Gravities.left:
                return .left
            case LayoutXML.Constants.LinearLayout.Gravities.right:
                return .right
            case LayoutXML.Constants.LinearLayout.Gravities.centerHorizontal:
                return .centerHorizontal
            case LayoutXML.Constants.LinearLayout.Gravities.top:
                return .top
            case LayoutXML.Constants.LinearLayout.Gravities.bottom:
                return .bottom
            case LayoutXML.Constants.LinearLayout.Gravities.centerVertical:
                return .centerVertical
            case LayoutXML.Constants.LinearLayout.Gravities.center:
                return .center
            default:
                return .default
            }
        }
        
        let rawValue: Int = string.components(separatedBy: "|").filter { (component: String) -> Bool in
            component.count > 0
        }.map { (component: String) -> Int in
            return gravity(component).rawValue
        }.reduce(LayoutXMLGravity.default.rawValue, |)
        
        self.rawValue = rawValue
    }
    
    public func isActive(gravity: LayoutXMLGravity) -> Bool {
        return self.rawValue & gravity.rawValue == gravity.rawValue
    }
}

@objc (LinearLayout)

public class LinearLayout: UIView, LayoutXMLLayouter {
    
    public var orientation: LayoutXMLOrientation = .horizontal
    
    public var weightSum: CGFloat = 0.0
        
    public var widthSum: CGFloat = 0.0
    
    public var heightSum: CGFloat = 0.0
    
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
                self._size.width = 0.0
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
        
        // Gone
        if self.visibility == .gone {
            self._size.height = LayoutXMLLength.zero
        }
        // Match Parent
        else if self.sizeInfo.height == LayoutXMLLength.matchParent {
            
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
        else if self.sizeInfo.height == LayoutXMLLength.wrapContent {
            
            let matchParents: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height == LayoutXMLLength.matchParent ? subview : nil
            }
            let others: [UIView] = self.subviews.flatMap { (subview: UIView) -> UIView? in
                return subview.sizeInfo.height != LayoutXMLLength.matchParent ? subview : nil
            }
            
            for subview in others {
                subview.measureHeight()
            }
            
            self._size.height = others.map { (subview: UIView) -> CGFloat in
                return subview._size.height + (subview.margin.top + subview.margin.bottom) + (padding.top + padding.bottom)
            }.max() ?? 0.0
            
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
        self.widthSum = widths.reduce(0.0, +)
        
        // Adjust Subviews Horizontal
        if self.orientation == .horizontal {
            
            let weightSum: CGFloat = self.weightSum > 0.0 ? self.weightSum : self.subviews.map { (subview: UIView) -> CGFloat in
                return subview.weight
            }.reduce(0.0, +)
            
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
            self.widthSum = widths.reduce(0.0, +)
        }
    }
    
    public func measureSubviewsVertical() {
        
        for subview in self.subviews {
            subview.measureHeight()
        }
        
        let heights: [CGFloat] = self.subviews.map { (subview: UIView) -> CGFloat in
            return subview._size.height + subview.margin.top + subview.margin.bottom
        }
        self.heightSum = heights.reduce(0.0, +)
        
        // Adjust Subviews Vertical
        if self.orientation == .vertical {
            
            let weightSum: CGFloat = self.weightSum > 0.0 ? self.weightSum : self.subviews.map { (subview: UIView) -> CGFloat in
                return subview.weight
                }.reduce(0.0, +)
            
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
            self.heightSum = heights.reduce(0.0, +)
        }
    }
    
    public func layout() {
        
        if self.visibility == .gone {
            return
        }
        
        self.frame = CGRect(x: self.margin.left, y: self.margin.top, width: _size.width, height: _size.height)

        if self.orientation == .horizontal {
            layoutHorizontal()
        }
        if self.orientation == .vertical {
            layoutVertical()
        }
    }
    
    private func layoutHorizontal() {
        
        var buf: CGFloat = self.widthSum
        var currentPosition: CGPoint = CGPoint(x: self.padding.left, y: self.padding.top)
        
        let usableWidth: CGFloat = self._size.width - (self.padding.left + self.padding.right)
        let usableHeight: CGFloat = self._size.height - (self.padding.top + self.padding.bottom)
        let majorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: self.gravity.rawValue & LayoutXMLGravity.horizontalMask.rawValue)
        let minorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: self.gravity.rawValue & LayoutXMLGravity.verticalMask.rawValue)
        
        if majorGravity.isActive(gravity: .right) {
            currentPosition.x = currentPosition.x + usableWidth - self.widthSum
        } else if majorGravity.isActive(gravity: .centerHorizontal) {
            currentPosition.x = currentPosition.x + (usableWidth - self.widthSum)/2.0
        }
        
        for subview in self.subviews {
            
            if majorGravity == .default {
                if subview.gravity.isActive(gravity: .right) {
                    currentPosition.x = (self.padding.left + usableWidth - buf)
                } else if subview.gravity.isActive(gravity: .centerHorizontal) {
                    currentPosition.x = (self.padding.left + usableWidth - buf - currentPosition.x)/2.0
                }
            }
            
            currentPosition.x = currentPosition.x + subview.margin.left
            
            let localGravity: LayoutXMLGravity = minorGravity != .default ? minorGravity : subview.gravity
            let subUsableHeight: CGFloat = (subview._size.height + subview.margin.top + subview.margin.bottom)
            
            if localGravity.isActive(gravity: .bottom) {
                currentPosition.y = self.padding.top + subview.margin.top + (usableHeight - subUsableHeight)
            } else if localGravity.isActive(gravity: .centerVertical) {
                currentPosition.y = self.padding.top + subview.margin.top + (usableHeight - subUsableHeight)/2.0
            } else {
                currentPosition.y = self.padding.top + subview.margin.top
            }
            
            subview._origin = currentPosition
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
            subview.frame = CGRect(x: subview._origin.x, y: subview._origin.y, width: subview._size.width, height: subview._size.height)

            currentPosition.x = currentPosition.x + subview._size.width + subview.margin.right
            buf = buf - (subview._size.width + subview.margin.left + subview.margin.right)
        }
    }
    
    private func layoutVertical() {
        
        var buf: CGFloat = heightSum
        var currentPosition: CGPoint = CGPoint(x: padding.left, y: padding.top)
        
        let usableWidth: CGFloat = _size.width - (padding.left + padding.right)
        let usableHeight: CGFloat = _size.height - (padding.top + padding.bottom)
        let majorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: gravity.rawValue & LayoutXMLGravity.verticalMask.rawValue)
        let minorGravity: LayoutXMLGravity =  LayoutXMLGravity(rawValue: gravity.rawValue & LayoutXMLGravity.horizontalMask.rawValue)
        
        if majorGravity.isActive(gravity: .bottom) {
            currentPosition.y = currentPosition.y + usableHeight - heightSum
        } else if majorGravity.isActive(gravity: .centerVertical) {
            currentPosition.y = currentPosition.y + (usableHeight - heightSum)/2.0
        }
        
        for subview in subviews {
            
            if majorGravity == .default {
                if subview.gravity.isActive(gravity: .bottom) {
                    currentPosition.y = (padding.top + usableHeight - buf)
                } else if subview.gravity.isActive(gravity: .centerVertical) {
                    currentPosition.y = (padding.top + usableHeight - buf - currentPosition.y)/2.0
                }
            }
            
            currentPosition.y = currentPosition.y + subview.margin.top
            
            let localGravity: LayoutXMLGravity = minorGravity != .default ? minorGravity : subview.gravity
            let subUsableWidth: CGFloat = (subview._size.width + subview.margin.left + subview.margin.right)
            
            if localGravity.isActive(gravity: .right) {
                currentPosition.x = padding.left + subview.margin.left + (usableWidth - subUsableWidth)
            } else if localGravity.isActive(gravity: .centerHorizontal) {
                currentPosition.x = padding.left + subview.margin.left + (usableWidth - subUsableWidth)/2.0
            } else {
                currentPosition.x = padding.left + subview.margin.left
            }
            
            subview._origin = currentPosition
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
            subview.frame = CGRect(x: subview._origin.x, y: subview._origin.y, width: subview._size.width, height: subview._size.height)
            
            currentPosition.y = currentPosition.y + subview._size.height + subview.margin.bottom
            buf = buf - (subview._size.height + subview.margin.top + subview.margin.bottom)
        }
    }
}
