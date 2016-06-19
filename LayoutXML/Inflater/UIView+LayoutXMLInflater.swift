//
//  UIView+LayoutXMLInflater.swift
//  
//
//  Created by naru on 2016/05/04.
//
//

import UIKit
import Foundation

extension UIView {
    
    func loadLayoutXML(resource resource: String) {
        self.loadLayoutXML(resource: resource, completion: nil)
    }
    
    func loadLayoutXML(resource resource: String, completion: (() -> ())?) {
        
        self._size = self.frame.size
        
        LayoutXMLInflater().inflate(resource: resource) { converter, views in
            
            for view in views {
                self.addSubview(view)
                if let layouter = view as? LayoutXMLLayouter {
                    layouter.requestLayout()
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    // MARK: create view from layout xml element
   
    /// Create view from XMLElement.
    /// - parameter layoutXMLElement: layout xml element to create view
    /// - returns: created object
    class func view(layoutXMLElement layoutXMLElement: LayoutXMLInflater.LayoutXMLElement) -> Self {
        
        let view = self.init()
        let attributes: [String: String] = layoutXMLElement.attributes
        
        // layout id
        if let string = attributes[LayoutXML.Constants.LayoutID] {
            if let layoutID = LayoutXML.R.id(string) {
                view.layoutID = layoutID
            }
        }
    
        // size info
        let sizeInfo = layoutXMLSize(width: attributes[LayoutXML.Constants.Width], height: attributes[LayoutXML.Constants.Height])
        view.sizeInfo = sizeInfo
        
        // margin
        if let margin = attributes[LayoutXML.Constants.Margin] {
            view.margin = layoutXMLEdgeInsets(string: margin)
        } else {
            let top = attributes[LayoutXML.Constants.Margins.Top]
            let right = attributes[LayoutXML.Constants.Margins.Right]
            let bottom = attributes[LayoutXML.Constants.Margins.Bottom]
            let left = attributes[LayoutXML.Constants.Margins.Left]
            view.margin = layoutXMLEdgeInsets(top: top, right: right, bottom: bottom, left: left)
        }
        
        // padding
        if let padding = attributes[LayoutXML.Constants.Padding] {
            view.padding = layoutXMLEdgeInsets(string: padding)
        } else {
            let top = attributes[LayoutXML.Constants.Paddings.Top]
            let right = attributes[LayoutXML.Constants.Paddings.Right]
            let bottom = attributes[LayoutXML.Constants.Paddings.Bottom]
            let left = attributes[LayoutXML.Constants.Paddings.Left]
            view.padding = layoutXMLEdgeInsets(top: top, right: right, bottom: bottom, left: left)
        }
        
        // background color
        if let value = attributes[LayoutXML.Constants.BackgroundColor] {
            if let color: UIColor = LayoutXML.R.color(string: value) {
                view.backgroundColor = color
            }
        }
        
        // weight
        if let value = attributes[LayoutXML.Constants.LinearLayout.Weight] {
            if let double: Double = Double(value), let weight: CGFloat = CGFloat(double) {
                view.weight = weight
            }
        }
        
        // gravity
        if let value = attributes[LayoutXML.Constants.LinearLayout.Gravity] {
            view.gravity = LayoutXMLGravity(string: value)
        }

        // layout gravity
        if let value = attributes[LayoutXML.Constants.LinearLayout.LayoutGravity] {
            view.layoutGravity = LayoutXMLGravity(string: value)
        }
        
        // dependency
        if let value = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.AlignParent] {
            view.dependency.alignParent = LayoutXMLRelativeAlignParent(string: value)
        }
        
        // dependency (align)
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.Top] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.top = LayoutXMLRelativeAnchor(type: .Align, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.Left] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.left = LayoutXMLRelativeAnchor(type: .Align, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.Bottom] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.bottom = LayoutXMLRelativeAnchor(type: .Align, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.Right] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.right = LayoutXMLRelativeAnchor(type: .Align, layoutID: layoutID)
            }
        }
        
        // dependency (position)
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.Top] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.top = LayoutXMLRelativeAnchor(type: .Position, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.Right] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.left = LayoutXMLRelativeAnchor(type: .Position, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.Bottom] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.bottom = LayoutXMLRelativeAnchor(type: .Position, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.Left] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.right = LayoutXMLRelativeAnchor(type: .Position, layoutID: layoutID)
            }
        }
        
        // for linear layout
        if let linearLayout = view as! AnyObject as? LinearLayout {
            
            // orientation
            if let value = attributes[LayoutXML.Constants.LinearLayout.Orientation] {
                linearLayout.orientation = LayoutXMLOrientation(string: value)
            }
            
            // weight sum
            if let value = attributes[LayoutXML.Constants.LinearLayout.WeightSum], let weightSum: Double = Double(value) {
                linearLayout.weightSum = CGFloat(weightSum)
            }
        }
        
        // for label
        if let label = view as! AnyObject as? UILabel {
            
            // font
            if let value = attributes[LayoutXML.Constants.Font] {
                if let font = LayoutXML.R.font(value) {
                    label.font = font
                }
            }
            
            // text
            if let value = attributes[LayoutXML.Constants.Text] {
                label.text = LayoutXML.R.string(value)
            }
            
            // number of lines
            if let value = attributes[LayoutXML.Constants.Label.NumberOfLines], let numberOfLines: Int = Int(value) {
                label.numberOfLines = numberOfLines
            }
        }
        
        // for button
        if let button = view as! AnyObject as? UIButton {
            
            // font
            if let value = attributes[LayoutXML.Constants.Font] {
                if let font = LayoutXML.R.font(value) {
                    button.titleLabel?.font = font
                }
            }
            
            // text
            if let value = attributes[LayoutXML.Constants.Text] {
                button.setTitle(LayoutXML.R.string(value), forState: .Normal)
            }
        }
        
        return view
    }
}
