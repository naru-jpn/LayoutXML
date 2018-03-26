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
    
    func loadLayoutXML(resource: String) {
        loadLayoutXML(resource: resource, completion: nil)
    }
    
    func loadLayoutXML(resource: String, completion: (() -> ())?) {
        
        _size = frame.size
        
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
    class func view(layoutXMLElement: LayoutXMLInflater.LayoutXMLElement) -> Self {
        
        let view = self.init()
        let attributes: [String: String] = layoutXMLElement.attributes
        
        // layout id
        if let string = attributes[LayoutXML.Constants.layoutID] {
            if let layoutID = LayoutXML.R.id(string) {
                view.layoutID = layoutID
            }
        }
    
        // size info
        let sizeInfo = layoutXMLSize(width: attributes[LayoutXML.Constants.width], height: attributes[LayoutXML.Constants.height])
        view.sizeInfo = sizeInfo
        
        // margin
        if let margin = attributes[LayoutXML.Constants.margin] {
            view.margin = layoutXMLEdgeInsets(string: margin)
        } else {
            let top = attributes[LayoutXML.Constants.Margins.top]
            let right = attributes[LayoutXML.Constants.Margins.right]
            let bottom = attributes[LayoutXML.Constants.Margins.bottom]
            let left = attributes[LayoutXML.Constants.Margins.left]
            view.margin = layoutXMLEdgeInsets(top: top, right: right, bottom: bottom, left: left)
        }
        
        // padding
        if let padding = attributes[LayoutXML.Constants.padding] {
            view.padding = layoutXMLEdgeInsets(string: padding)
        } else {
            let top = attributes[LayoutXML.Constants.Paddings.top]
            let right = attributes[LayoutXML.Constants.Paddings.right]
            let bottom = attributes[LayoutXML.Constants.Paddings.bottom]
            let left = attributes[LayoutXML.Constants.Paddings.left]
            view.padding = layoutXMLEdgeInsets(top: top, right: right, bottom: bottom, left: left)
        }
        
        // background color
        if let value = attributes[LayoutXML.Constants.backgroundColor] {
            if let color: UIColor = LayoutXML.R.color(value) {
                view.backgroundColor = color
            }
        }
        
        // weight
        if let value = attributes[LayoutXML.Constants.LinearLayout.weight] {
            if let double: Double = Double(value) {
                view.weight = CGFloat(double)
            }
        }
        
        // gravity
        if let value = attributes[LayoutXML.Constants.LinearLayout.gravity] {
            view.gravity = LayoutXMLGravity(string: value)
        }

        // layout gravity
        if let value = attributes[LayoutXML.Constants.LinearLayout.layoutGravity] {
            view.layoutGravity = LayoutXMLGravity(string: value)
        }
        
        // dependency
        if let value = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.alignParent] {
            view.dependency.alignParent = LayoutXMLRelativeAlignParent(string: value)
        }
        
        // dependency (align)
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.top] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.top = LayoutXMLRelativeAnchor(type: .align, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.left] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.left = LayoutXMLRelativeAnchor(type: .align, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.bottom] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.bottom = LayoutXMLRelativeAnchor(type: .align, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Aligns.right] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.right = LayoutXMLRelativeAnchor(type: .align, layoutID: layoutID)
            }
        }
        
        // dependency (position)
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.top] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.top = LayoutXMLRelativeAnchor(type: .position, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.right] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.left = LayoutXMLRelativeAnchor(type: .position, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.bottom] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.bottom = LayoutXMLRelativeAnchor(type: .position, layoutID: layoutID)
            }
        }
        if let string = attributes[LayoutXML.Constants.RelativeLayout.AlignRules.Positions.left] {
            if let layoutID: Int = LayoutXML.R.id(string) {
                view.dependency.anchors.right = LayoutXMLRelativeAnchor(type: .position, layoutID: layoutID)
            }
        }
        
        // for linear layout
        if let linearLayout = view as AnyObject as? LinearLayout {
            
            // orientation
            if let value = attributes[LayoutXML.Constants.LinearLayout.orientation] {
                linearLayout.orientation = LayoutXMLOrientation(string: value)
            }
            
            // weight sum
            if let value = attributes[LayoutXML.Constants.LinearLayout.weightSum], let weightSum: Double = Double(value) {
                linearLayout.weightSum = CGFloat(weightSum)
            }
        }
        
        // for label
        if let label = view as AnyObject as? UILabel {
            
            // font
            if let value = attributes[LayoutXML.Constants.font] {
                if let font = LayoutXML.R.font(value) {
                    label.font = font
                }
            }
            
            // text
            if let value = attributes[LayoutXML.Constants.text] {
                label.text = LayoutXML.R.string(value)
            }
            
            // text color
            if let value = attributes[LayoutXML.Constants.Label.textColor], let color: UIColor = LayoutXML.R.color(value) {
                label.textColor = color
            }
            
            // number of lines
            if let value = attributes[LayoutXML.Constants.Label.numberOfLines], let numberOfLines: Int = Int(value) {
                label.numberOfLines = numberOfLines
            }
        }
        
        // for button
        if let button = view as AnyObject as? UIButton {
            
            // font
            if let value = attributes[LayoutXML.Constants.font] {
                if let font = LayoutXML.R.font(value) {
                    button.titleLabel?.font = font
                }
            }
            
            // text
            if let value = attributes[LayoutXML.Constants.text] {
                button.setTitle(LayoutXML.R.string(value), for: .normal)
            }
        }
        
        return view
    }
}
