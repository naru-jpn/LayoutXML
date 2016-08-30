//
//  RelativeLayout.swift
//  
//
//  Created by naru on 2016/05/03.
//
//

import UIKit
import Foundation

/// Anchor Type
public enum LayoutXMLRelativeAnchorType: Int {
    /// No Anchor
    case None = 0
    /// Adjust Position with Anchor View
    case Position
    /// Adjust Alignment with Anchor View
    case Align
}

/// Option Value to Decide Position on Parent
public struct LayoutXMLRelativeAlignParent: OptionSetType {
    
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    static let Default          = LayoutXMLRelativeAlignParent(rawValue: 0)
    static let Left             = LayoutXMLRelativeAlignParent(rawValue: 1 << 0)
    static let Right            = LayoutXMLRelativeAlignParent(rawValue: 1 << 1)
    static let CenterHorizontal = LayoutXMLRelativeAlignParent(rawValue: 1 << 2)
    static let Top              = LayoutXMLRelativeAlignParent(rawValue: 1 << 3)
    static let Bottom           = LayoutXMLRelativeAlignParent(rawValue: 1 << 4)
    static let CenterVertical   = LayoutXMLRelativeAlignParent(rawValue: 1 << 5)
    static let Center        : LayoutXMLRelativeAlignParent = [.CenterHorizontal, .CenterVertical]
    static let HorizontalMask: LayoutXMLRelativeAlignParent = [.Right, .CenterHorizontal]
    static let VerticalMask  : LayoutXMLRelativeAlignParent = [.Bottom, .CenterVertical]
    
    init(string: String) {
        
        func alignParent(component: String) -> LayoutXMLRelativeAlignParent {
            switch component {
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.Left:
                return .Left
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.Right:
                return .Right
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.CenterHorizontal:
                return .CenterHorizontal
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.Top:
                return .Top
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.Bottom:
                return .Bottom
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.CenterVertical:
                return .CenterVertical
            case LayoutXML.Constants.RelativeLayout.AlignRules.AlignParents.Center:
                return .Center
            default:
                return .Default
            }
        }
        
        let rawValue: Int = string.componentsSeparatedByString("|").filter { (component: String) -> Bool in
            component.characters.count > 0
        }.map { (component: String) -> Int in
            return alignParent(component).rawValue
        }.reduce(LayoutXMLGravity.Default.rawValue, combine: |)
        
        self.rawValue = rawValue
    }
    
    /// Get Option is Active or Not
    public func isActive(alignParent: LayoutXMLRelativeAlignParent) -> Bool {
        return self.rawValue & alignParent.rawValue == alignParent.rawValue
    }
}

public struct LayoutXMLRelativeAnchor {
    
    let type: LayoutXMLRelativeAnchorType
    let layoutID: Int
    
    public var values: [Int] {
        return [self.type.rawValue, self.layoutID]
    }
    
    init(type: LayoutXMLRelativeAnchorType, layoutID: Int) {
        self.type = type
        self.layoutID = layoutID
    }
}

public struct LayoutXMLRelativeAnchors {
    
    var top   : LayoutXMLRelativeAnchor?
    var left  : LayoutXMLRelativeAnchor?
    var bottom: LayoutXMLRelativeAnchor?
    var right : LayoutXMLRelativeAnchor?
    
    public var values: [[Int]] {
        return [self.top, self.left, self.bottom, self.right].map { (anchor: LayoutXMLRelativeAnchor?) -> [Int] in
            return anchor?.values ?? [0, 0]
        }
    }
    
    init(top: LayoutXMLRelativeAnchor?, left: LayoutXMLRelativeAnchor?, bottom: LayoutXMLRelativeAnchor?, right: LayoutXMLRelativeAnchor?) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    init(values: [[Int]]) {
        if let type: Int = values[0][0], let layoutID: Int = values[0][1] where layoutID > 0 {
            self.top = LayoutXMLRelativeAnchor(type: LayoutXMLRelativeAnchorType(rawValue: type)!, layoutID: layoutID)
        }
        if let type: Int = values[1][0], let layoutID: Int = values[1][1] where layoutID > 0 {
            self.left = LayoutXMLRelativeAnchor(type: LayoutXMLRelativeAnchorType(rawValue: type)!, layoutID: layoutID)
        }
        if let type: Int = values[2][0], let layoutID: Int = values[2][1] where layoutID > 0 {
            self.bottom = LayoutXMLRelativeAnchor(type: LayoutXMLRelativeAnchorType(rawValue: type)!, layoutID: layoutID)
        }
        if let type: Int = values[3][0], let layoutID: Int = values[3][1] where layoutID > 0 {
            self.right = LayoutXMLRelativeAnchor(type: LayoutXMLRelativeAnchorType(rawValue: type)!, layoutID: layoutID)
        }
    }
}

public struct LayoutXMLDependency {
    
    var anchors: LayoutXMLRelativeAnchors
    var alignParent: LayoutXMLRelativeAlignParent
    
    public var values: NSArray {
        return [self.anchors.values, self.alignParent.rawValue]
    }
    
    init(anchors: LayoutXMLRelativeAnchors, alignParent: LayoutXMLRelativeAlignParent) {
        self.anchors = anchors
        self.alignParent = alignParent
    }
    
    init(values: NSArray) {
        if let anchors = values[0] as? [[Int]] {
            self.anchors = LayoutXMLRelativeAnchors(values: anchors)
        } else {
            self.anchors = LayoutXMLRelativeAnchors(top: nil, left: nil, bottom: nil, right: nil)
        }
        if let alignParent = values[1] as? Int {
            self.alignParent = LayoutXMLRelativeAlignParent(rawValue: alignParent)
        } else {
            self.alignParent = .Default
        }
    }
}

/// Graph to Represent Dependencies
public struct LayoutXMLDependencyGraph {
    
    public struct Node: CustomDebugStringConvertible {
        
        let view: UIView
        var dependencies: [Node]
        var dependents: [Node]
        
        init(view: UIView) {
            self.view = view
            self.dependencies = []
            self.dependents = []
        }
        
        public var debugDescription: String {
            return "<view: \(self.view.dynamicType), dependencies(count): \(self.dependencies.count), dependents(count): \(dependents.count)>"
        }
    }
    
    let views: [UIView]
    
    var nodes: [Node] {
        return self.views.map { (view: UIView) -> Node in
            return Node(view: view)
        }
    }
    
    init(views: [UIView]) {
        self.views = views
    }
    
    var horizontalRoots: [Node] {
        
        func roots(nodes: [Node]) -> [Node] {
            return nodes.filter { (node: Node) -> Bool in
                return (node.view.dependency.anchors.left?.type == .None) && (node.view.dependency.anchors.right?.type == .None)
            }
        }
        
        var nodes: [Node] = self.nodes
        
        for (index, node) in nodes.enumerate() {
            
            let anchors: LayoutXMLRelativeAnchors = node.view.dependency.anchors
            
            if anchors.left?.type != .None {
                let anchorIndex: Int? = self.nodes.enumerate().flatMap { (index: Int, node: Node) -> Int? in
                    return (node.view.layoutID == anchors.left?.layoutID) ? index : nil
                }.first
                if let anchorIndex: Int = anchorIndex {
                    nodes[index].dependencies.append(nodes[anchorIndex])
                    nodes[anchorIndex].dependents.append(nodes[index])
                }
            }
            if anchors.right?.type != .None {
                let anchorIndex: Int? = self.nodes.enumerate().flatMap { (index: Int, node: Node) -> Int? in
                    return (node.view.layoutID == anchors.right?.layoutID) ? index : nil
                }.first
                if let anchorIndex: Int = anchorIndex {
                    nodes[index].dependencies.append(nodes[anchorIndex])
                    nodes[anchorIndex].dependents.append(nodes[index])
                }
            }
        }
        
        return roots(nodes)
    }
    
    var verticalRoots: [Node] {
        
        func roots(nodes: [Node]) -> [Node] {
            return nodes.filter { (node: Node) -> Bool in
                return (node.view.dependency.anchors.top?.type == .None) && (node.view.dependency.anchors.bottom?.type == .None)
            }
        }
        
        var nodes: [Node] = self.nodes
        
        for (index, node) in nodes.enumerate() {
            
            let anchors: LayoutXMLRelativeAnchors = node.view.dependency.anchors
            
            if anchors.top?.type != .None {
                let anchorIndex: Int? = self.nodes.enumerate().flatMap { (index: Int, node: Node) -> Int? in
                    return (node.view.layoutID == anchors.top?.layoutID) ? index : nil
                }.first
                if let anchorIndex: Int = anchorIndex {
                    nodes[index].dependencies.append(nodes[anchorIndex])
                    nodes[anchorIndex].dependents.append(nodes[index])
                }
            }
            if anchors.bottom?.type != .None {
                let anchorIndex: Int? = self.nodes.enumerate().flatMap { (index: Int, node: Node) -> Int? in
                    return (node.view.layoutID == anchors.bottom?.layoutID) ? index : nil
                }.first
                if let anchorIndex: Int = anchorIndex {
                    nodes[index].dependencies.append(nodes[anchorIndex])
                    nodes[anchorIndex].dependents.append(nodes[index])
                }
            }
        }
        
        return roots(nodes)
    }
}

@objc (RelativeLayout)

public class RelativeLayout: UIView, LayoutXMLLayouter {
    
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
        
        /// Return View with LayoutID
        func subview(layoutID layoutID: Int) -> UIView? {
            return self.subviews.filter { (subview: UIView) -> Bool in (subview.layoutID == layoutID && layoutID > 0) }.first
        }
        
        /// Adjust Dependent Nodes Recursively
        func adjustDependentNodes(nodes: [LayoutXMLDependencyGraph.Node]) {
            
            for node in nodes {
                
                var isLeftFixed: Bool = false
                
                // Align Parent
                let dependency: LayoutXMLDependency = node.view.dependency
                let rawValue: Int = dependency.alignParent.rawValue & LayoutXMLRelativeAlignParent.HorizontalMask.rawValue
                let alignParent: LayoutXMLRelativeAlignParent = LayoutXMLRelativeAlignParent(rawValue: rawValue)
                
                // Left Anchor
                if let leftAnchor: LayoutXMLRelativeAnchor = node.view.dependency.anchors.left, let view = subview(layoutID: leftAnchor.layoutID) {
                    
                    if leftAnchor.type == .Align {
                        node.view._origin.x = view._origin.x + node.view.margin.left
                    } else {
                        node.view._origin.x = view._origin.x + view._size.width + view.margin.right + node.view.margin.left
                    }
                    isLeftFixed = true
                    
                } else if alignParent.isActive(.CenterHorizontal) {
                    
                    node.view._origin.x = (self._size.width - node.view._size.width)/2.0
                    isLeftFixed = true
                    
                } else {
                    
                    node.view._origin.x = self.padding.left + node.view.margin.left
                    isLeftFixed = true
                }
                
                let fixed: CGFloat = node.view._origin.x
                
                // Right Anchor
                if let rightAnchor: LayoutXMLRelativeAnchor = node.view.dependency.anchors.right, let view = subview(layoutID: rightAnchor.layoutID) {
                    
                    if rightAnchor.type == .Align {
                        node.view._origin.x = view._origin.x + view._size.width - (node.view._size.width + node.view.margin.right)
                    } else {
                        node.view._origin.x = view._origin.x - (node.view._size.width + node.view.margin.right + view.margin.left)
                    }

                } else if alignParent.isActive(.Right) {
                    
                    node.view._origin.x = self._size.width - (node.view._size.width + node.view.margin.right + self.padding.right)
                }
                
                if isLeftFixed {
                    node.view._size.width = node.view._size.width + (node.view._origin.x - fixed)
                    node.view._origin.x = fixed
                }
                
                adjustDependentNodes(node.dependents)
            }
        }
        
        // Measure Subviews
        for subview in subviews {
            subview.measureWidth()
        }
        
        let roots: [LayoutXMLDependencyGraph.Node] =  LayoutXMLDependencyGraph(views: self.subviews).horizontalRoots
        adjustDependentNodes(roots)
    }
    
    public func measureSubviewsVertical() {
        
        /// Return View With LayoutID
        func subview(layoutID layoutID: Int) -> UIView? {
            return self.subviews.filter { (subview: UIView) -> Bool in (subview.layoutID == layoutID && layoutID > 0) }.first
        }
        
        /// Adjust Dependent Nodes Recursively
        func adjustDependentNodes(nodes: [LayoutXMLDependencyGraph.Node]) {
            
            for node in nodes {
                
                var isTopFixed: Bool = false
                
                // Align Parent
                let dependency: LayoutXMLDependency = node.view.dependency
                let rawValue: Int = dependency.alignParent.rawValue & LayoutXMLRelativeAlignParent.VerticalMask.rawValue
                let alignParent: LayoutXMLRelativeAlignParent = LayoutXMLRelativeAlignParent(rawValue: rawValue)
                
                // Top Anchor
                if let topAnchor: LayoutXMLRelativeAnchor = node.view.dependency.anchors.top, let view = subview(layoutID: topAnchor.layoutID) {
                    
                    if topAnchor.type == .Align {
                        node.view._origin.y = view._origin.y + node.view.margin.top
                    } else {
                        node.view._origin.y = view._origin.y + view._size.height + view.margin.top + node.view.margin.bottom
                    }
                    isTopFixed = true
                    
                } else if alignParent.isActive(.CenterVertical) {
                    
                    node.view._origin.y = (self._size.height - node.view._size.height)/2.0
                    isTopFixed = true
                    
                } else {
                    
                    node.view._origin.y = self.padding.top + node.view.margin.bottom
                    isTopFixed = true
                }
                
                let fixed: CGFloat = node.view._origin.y
                
                // Bottom Anchor
                if let bottomAnchor: LayoutXMLRelativeAnchor = node.view.dependency.anchors.bottom, let view = subview(layoutID: bottomAnchor.layoutID) {
                    
                    if bottomAnchor.type == .Align {
                        node.view._origin.y = view._origin.y + view._size.height - (node.view._size.height + node.view.margin.bottom)
                    } else {
                        node.view._origin.y = view._origin.y - (node.view._size.height + node.view.margin.bottom + view.margin.top)
                    }
                    
                } else if alignParent.isActive(.Bottom) {
                    
                    node.view._origin.y = self._size.height - (node.view._size.height + node.view.margin.bottom + self.padding.bottom)
                }
                
                if isTopFixed {
                    node.view._size.height = node.view._size.height + (node.view._origin.y - fixed)
                    node.view._origin.y = fixed
                }
                
                adjustDependentNodes(node.dependents)
            }
        }
        
        // Measure Subviews
        for subview in subviews {
            subview.measureHeight()
        }
        
        let roots: [LayoutXMLDependencyGraph.Node] =  LayoutXMLDependencyGraph(views: self.subviews).verticalRoots
        adjustDependentNodes(roots)
    }
    
    public func layout() {
        
        if self.visibility == .Gone {
            return
        }
        
        self.frame = CGRectMake(self.margin.left, self.margin.top, _size.width, _size.height)
        
        // set subview frames
        for subview in self.subviews {
            
            subview.frame = CGRectMake(subview._origin.x, subview._origin.y, subview._size.width, subview._size.height)
            
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.layout()
            }
        }
    }
}
