//
//  LayoutXML.swift
//  
//
//  Created by naru on 2016/05/03.
//
//

import UIKit
import Foundation

public struct LayoutXML {
    
    public struct Constants {
        
        static let xmlDocument = "xml"
        
        static let layoutID = "id"
        static let width = "width"
        static let height = "height"
        static let font = "font"
        static let text = "text"
        static let title = "title"
        static let backgroundColor = "background_color"
        
        static let margin = "margin"
        public struct Margins {
            static let top = "margin-top"
            static let right = "margin-right"
            static let bottom = "margin-bottom"
            static let left = "margin-left"
        }
        
        static let padding = "padding"
        public struct Paddings {
            static let top = "padding-top"
            static let right = "padding-right"
            static let bottom = "padding-bottom"
            static let left = "padding-left"
        }
        
        static let visibility = "visibility"
        public struct Visibilities {
            static let visible = "visible"
            static let invisible = "invisible"
            static let gone = "gone"
        }
        
        public struct Length {
            static let fillParent = "fill_parent"
            static let matchParent = "match_parent"
            static let wrapContent = "wrap_content"
        }
        
        public struct LinearLayout {
            
            static let weight = "weight"
            static let weightSum = "weight_sum"
            
            static let gravity = "gravity"
            static let layoutGravity = "layout_gravity"
            public struct Gravities {
                static let top = "top"
                static let right = "right"
                static let bottom = "bottom"
                static let left = "left"
                static let centerHorizontal = "center_horizontal"
                static let centerVertical = "center_vertical"
                static let center = "center"
            }
            
            static let orientation = "orientation"
            public struct Orientations {
                static let horizontal = "horizontal"
                static let vertical = "vertical"
            }
        }
        
        public struct RelativeLayout {
            
            public struct AlignRules {
                
                public struct Aligns {
                    static let top = "align_top"
                    static let left = "align_left"
                    static let bottom = "align_bottom"
                    static let right = "align_right"
                }
                
                public struct Positions {
                    static let top = "above"
                    static let left = "to_left_of"
                    static let bottom = "below"
                    static let right = "to_right_of"
                }
                
                static let alignParent = "align_parent"
                public struct AlignParents {
                    static let top = "top"
                    static let left = "left"
                    static let bottom = "bottom"
                    static let right = "right"
                    static let centerHorizontal = "center_horizontal"
                    static let centerVertical = "center_vertical"
                    static let center = "center"
                }
            }
        }
        
        public struct Label {
            
            static let numberOfLines = "number_of_lines"
            
            static let lineBreakMode = "line_break_mode"
            public struct LineBreakModes {
                static let wordWrapping = "word_wrapping"
                static let charWrapping = "char_wrapping"
                static let clipping = "clipping"
                static let truncatingHead = "truncating_head"
                static let truncatingTail = "truncating_tail"
                static let truncatingMiddle = "truncating_middle"
            }
        }
        
        static let colorPlist = "LayoutXMLColors"
    }
}


/// Representing length of view
public typealias LayoutXMLLength = CGFloat

public extension LayoutXMLLength {
    public static let zero = CGFloat(0.0)
    /// having same length with parent
    public static let fillParent  = CGFloat(-1.0)
    public static let matchParent = CGFloat(-1.0)
    /// having enough length to wrap children
    public static let wrapContent = CGFloat(-2.0)
    /// otherwise, value is represent view length
}

/// Return LayoutXMLLength from string.
/// - parameter string: string to convert
/// - returns: layout xml length value
public func layoutXMLLength(string: String?) -> LayoutXMLLength {
    
    guard let string = string?.lowercased().replacingOccurrences(of: " ", with: "") else {
        return LayoutXMLLength.zero
    }
    
    if string == LayoutXML.Constants.Length.fillParent || string == LayoutXML.Constants.Length.matchParent {
        return LayoutXMLLength.matchParent
    }
    else if string == LayoutXML.Constants.Length.wrapContent {
        return LayoutXMLLength.wrapContent
    }
    else {
        var float: Float = 0.0
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = NSCharacterSet.lowercaseLetters
        scanner.scanFloat(&float)
        return CGFloat(float)
    }
}


/// Representing size of view
public struct LayoutXMLSize {
    
    var width: LayoutXMLLength
    var height: LayoutXMLLength
    
    public func CGSizeValue() -> CGSize { return CGSize(width: width, height: height) }
}

public extension CGSize {
    public func LayoutXMLSizeValue() -> LayoutXMLSize { return LayoutXMLSize(width: width, height: height) }
}

public extension LayoutXMLSize {
    public static let zero = LayoutXMLSize(width: 0.0, height: 0.0)
}

/// Return layoutXMLSize from string.
/// - parameter width: string to convert
/// - parameter height: string to convert
/// - returns: layout xml size value
public func layoutXMLSize(width: String?, height: String?) -> LayoutXMLSize {
    return LayoutXMLSize(width: layoutXMLLength(string: width), height: layoutXMLLength(string: height))
}


/// Edge insets
public typealias LayoutXMLEdgeInsets = UIEdgeInsets

/// Return layoutXMLEdgeInsets from strings.
/// - parameter top: top inset
/// - parameter right: right inset
/// - parameter bottom: bottom inset
/// - parameter left: left inset
/// - return: layout xml edge insets
public func layoutXMLEdgeInsets(top: String?, right: String?, bottom: String?, left: String?) -> LayoutXMLEdgeInsets {
    return LayoutXMLEdgeInsets(top: layoutXMLLength(string: top), left: layoutXMLLength(string: left), bottom: layoutXMLLength(string: bottom), right: layoutXMLLength(string: right))
}

/// Return layoutXMLEdgeInsets from string.
/// - parameter string: string to create insets
/// - return: layout xml edge insets
public func layoutXMLEdgeInsets(string: String?) -> LayoutXMLEdgeInsets {
    
    guard let string = string else {
        return LayoutXMLEdgeInsets.zero
    }
    
    let components = string.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: [" "])
    switch components.count {
    case 1:
        return layoutXMLEdgeInsets(top: components[0], right: components[0], bottom: components[0], left: components[0])
    case 2:
        return layoutXMLEdgeInsets(top: components[0], right: components[1], bottom: components[0], left: components[1])
    case 3:
        return layoutXMLEdgeInsets(top: components[0], right: components[1], bottom: components[2], left: components[1])
    case 4:
        return layoutXMLEdgeInsets(top: components[0], right: components[1], bottom: components[2], left: components[3])
    default:
        return LayoutXMLEdgeInsets.zero
    }
}



/// Visibility of view
public enum LayoutXMLVisibility: Int {
    /// view is visible and view size is effected
    case visible = 0
    /// view is invisible but view size is effected
    case invisible
    /// view is invisible and view size is not effected
    case gone
}


/// Protocol to provide fundamental properties for layouted object
public protocol LayoutXMLLayoutable {
    
    /// layout id
    var layoutID: Int { get set }
    
    /// temporary stored information for calculated size
    var _size: CGSize { get set }
    
    /// temporary stored information for calculated origin
    var _origin: CGPoint { get set }
    
    /// margin for view
    var margin: LayoutXMLEdgeInsets { get set }
    
    /// padding of view
    var padding: LayoutXMLEdgeInsets { get set }
    
    /// information of size
    var sizeInfo: LayoutXMLSize { get set }
    
    /// visibility
    var visibility: LayoutXMLVisibility { get set }
    
    /// weight
    var weight: CGFloat { get set }
    
    /// gravity
    var gravity: LayoutXMLGravity { get set }
    
    /// layout gravity
    var layoutGravity: LayoutXMLGravity { get set }
    
    /// dependency
    var dependency: LayoutXMLDependency { get set }
    
    /// Update visibility
    func updateVisibility()
    
    /// Refresh All Layouter
    func refreshLayout()
    
    /// Measure
    func measure()
    func measureWidth()
    func measureHeight()
}

extension UIView: LayoutXMLLayoutable {
    
    private struct AssociateKeys {
        static var layoutID: String = "__layoutID"
        static var _size: String = "__size"
        static var _origin: String = "__origin"
        static var margin: String = "_margin"
        static var padding: String = "_padding"
        static var sizeInfo: String = "_sizeInfo"
        static var visibility: String = "_visibility"
        static var weight: String = "_weight"
        static var gravity: String = "_gravity"
        static var layoutGravity: String = "_layoutGravity"
        static var dependency: String = "_dependency"
    }
    
    /// Getter / Setter
    
    private func get(_ pointer: UnsafeRawPointer) -> AnyObject? {
        return objc_getAssociatedObject(self, pointer) as AnyObject
    }
    
    private func set(_ pointer: UnsafeRawPointer, object: AnyObject) {
        objc_setAssociatedObject(self, pointer, object, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }

    /// layout id
    public var layoutID: Int {
        get {
            guard let number = get(&AssociateKeys.layoutID) as? NSNumber else {
                return 0
            }
            return number.intValue
        }
        set {
            let number: NSNumber = NSNumber(value: newValue)
            set(&AssociateKeys.layoutID, object: number)
        }
    }
    
    /// temporary stored information for calculated size
    public var _size: CGSize {
        get {
            guard let value = get(&AssociateKeys._size) as? NSValue else {
                return CGSize.zero
            }
            return value.cgSizeValue
        }
        set {
            let value: NSValue = NSValue(cgSize: newValue)
            set(&AssociateKeys._size, object: value)
        }
    }
    
    /// temporary stored information for calculated origin
    public var _origin: CGPoint {
        get {
            guard let value = get(&AssociateKeys._origin) as? NSValue else {
                return CGPoint.zero
            }
            return value.cgPointValue
        }
        set {
            let value: NSValue = NSValue(cgPoint: newValue)
            set(&AssociateKeys._origin, object: value)
        }
    }
    
    /// margin for view
    public var margin: LayoutXMLEdgeInsets {
        get {
            guard let value = get(&AssociateKeys.margin) as? NSValue else {
                return LayoutXMLEdgeInsets.zero
            }
            return value.uiEdgeInsetsValue
        }
        set {
            let value: NSValue = NSValue(uiEdgeInsets: newValue)
            set(&AssociateKeys.margin, object: value)
        }
    }
    
    /// padding of view
    public var padding: LayoutXMLEdgeInsets {
        get {
            guard let value = get(&AssociateKeys.padding) as? NSValue else {
                return UIEdgeInsets.zero
            }
            return value.uiEdgeInsetsValue
        }
        set {
            let value: NSValue = NSValue(uiEdgeInsets: newValue)
            set(&AssociateKeys.padding, object: value)
        }
    }
    
    /// information of size
    public var sizeInfo: LayoutXMLSize {
        get {
            guard let value = get(&AssociateKeys.sizeInfo) as? NSValue else {
                return LayoutXMLSize.zero
            }
            return value.cgSizeValue.LayoutXMLSizeValue()
        }
        set {
            let value = NSValue(cgSize: newValue.CGSizeValue())
            set(&AssociateKeys.sizeInfo, object: value)
        }
    }
    
    /// visibility
    public var visibility: LayoutXMLVisibility {
        get {
            guard let number = get(&AssociateKeys.visibility) as? NSNumber, let visibility = LayoutXMLVisibility(rawValue: number.intValue) else {
                return LayoutXMLVisibility.visible
            }
            return visibility
        }
        set {
            let number: NSNumber = NSNumber(value: newValue.rawValue)
            set(&AssociateKeys.visibility, object: number)
        }
    }
    
    /// weight
    public var weight: CGFloat {
        get {
            guard let number: NSNumber = get(&AssociateKeys.weight) as? NSNumber else {
                return 0.0
            }
            let weight: Float = number.floatValue
            return CGFloat(weight)
        }
        set {
            let number: NSNumber = NSNumber(value: Float(newValue))
            set(&AssociateKeys.weight, object: number)
        }
    }
    
    /// gravity
    public var gravity: LayoutXMLGravity {
        get {
            guard let number: NSNumber = get(&AssociateKeys.gravity) as? NSNumber else {
                return .default
            }
            let rawValue: Int = number.intValue
            return LayoutXMLGravity(rawValue: rawValue)
        }
        set {
            let number: NSNumber = NSNumber(value: newValue.rawValue)
            set(&AssociateKeys.gravity, object: number)
        }
    }

    /// layout gravity
    public var layoutGravity: LayoutXMLGravity {
        get {
            guard let number: NSNumber = get(&AssociateKeys.layoutGravity) as? NSNumber else {
                return .default
            }
            let rawValue: Int = number.intValue
            return LayoutXMLGravity(rawValue: rawValue)
        }
        set {
            let number: NSNumber = NSNumber(value: newValue.rawValue)
            set(&AssociateKeys.layoutGravity, object: number)
        }
    }
    
    /// dependency
    public var dependency: LayoutXMLDependency {
        get {
            guard let values: NSArray = get(&AssociateKeys.dependency) as? NSArray else {
                let anchors: LayoutXMLRelativeAnchors = LayoutXMLRelativeAnchors(top: nil, left: nil, bottom: nil, right: nil)
                return LayoutXMLDependency(anchors: anchors, alignParent: .default)
            }
            return LayoutXMLDependency(values: values)
        }
        set {
            set(&AssociateKeys.dependency, object: newValue.values)
        }
    }
    
    // MARK: Visibility
    
    public func updateVisibility() {
        isHidden = (visibility != .visible)
    }
    
    // MARK: Refresh All Layouter
    
    public func refreshLayout() {
        
        // Refresh My Size
        if let _ = superview as? UIWindow {
            _size = frame.size
        } else {
            measure()
        }
        
        // Refresh All Layouter
        for subview in subviews {
            if let layouter = subview as? LayoutXMLLayouter {
                layouter.requestLayout()
            }
        }
    }
    
    // MARK: Measures
    
    /// Measure
    public func measure() {
        measureWidth()
        measureHeight()
    }

    /// Measure Width
    @objc
    public func measureWidth() {
        
        // gone
        if visibility == .gone {
            _size.width = LayoutXMLLength.zero
        }
        // match parent
        else if sizeInfo.width == LayoutXMLLength.matchParent {
            
            if let superview = superview {
                _size.width = superview._size.width - (margin.left + margin.right) - (superview.padding.left + superview.padding.right)
            } else {
                _size.width = 0.0
            }
        }
        // wrap content
        else if sizeInfo.width == LayoutXMLLength.wrapContent {
            
            // label
            if let label = self as? UILabel {
                
                let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
                
                // depends on attributed text
                if let attributedText = label.attributedText, attributedText.length > 0 {
                    let textSize = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
                    _size.width = CGSize(width: ceil(textSize.width), height: ceil(textSize.height)).width
                }
                // depends on standard text
                else if let text = label.text, let font = label.font, text.count > 0 {
                    let attributes = [NSAttributedStringKey.font: font]
                    let textSize = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
                    _size.width = CGSize(width: ceil(textSize.width), height: ceil(textSize.height)).width
                }
                // no text
                else {
                    _size.width = LayoutXMLLength.zero
                }
            }
            // image view
            else if let imageView = self as? UIImageView, let image = imageView.image {
                _size.width = image.size.width
            }
            // button
            else if let button = self as? UIButton, let titleLabel = button.titleLabel, let title = titleLabel.text, let font = titleLabel.font {
                let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
                let attributes = [NSAttributedStringKey.font: font]
                _size.width = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.width
            }
            // no measurable content
            else {
                _size.width = 0.0
            }
        }
        // others
        else {
            _size.width = sizeInfo.width
        }
    }
    
    /// Measure Height
    @objc
    public func measureHeight() {
        
        // gone
        if visibility == .gone {
            _size.height = LayoutXMLLength.zero
        }
        // match parent
        else if sizeInfo.height == LayoutXMLLength.matchParent {
            
            if let superview = superview {
                _size.height = superview._size.height - (margin.top + margin.bottom) - (superview.padding.top + superview.padding.bottom)
            } else {
                _size.height = 0.0
            }
        }
        // wrap content
        else if sizeInfo.height == LayoutXMLLength.wrapContent {
            
            // label
            if let label = self as? UILabel {
                
                let size = CGSize(width: _size.width, height: CGFloat.greatestFiniteMagnitude)
                
                // depends on attributed text
                if let attributedText = label.attributedText, attributedText.length > 0 {
                    let textSize = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
                    _size.height = CGSize(width: ceil(textSize.width), height: ceil(textSize.height)).height
                }
                // depends on standard text
                else if let text = label.text, let font = label.font, text.count > 0 {
                    let attributes = [NSAttributedStringKey.font: font]
                    let textSize = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
                    _size.height = CGSize(width: ceil(textSize.width), height: ceil(textSize.height)).height
                }
                // no text
                else {
                    _size.height = LayoutXMLLength.zero
                }
            }
            // image view
            else if let imageView = self as? UIImageView, let image = imageView.image {
                _size.height = image.size.height
            }
            // button
            else if let button = self as? UIButton, let titleLabel = button.titleLabel, let title = titleLabel.text, let font = titleLabel.font {
                let size = CGSize(width: _size.width, height: CGFloat.greatestFiniteMagnitude)
                let attributes = [NSAttributedStringKey.font: font]
                _size.height = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height
            }
            // no measurable content
            else {
                _size.height = 0.0
            }
        }
        // others
        else {
            _size.height = sizeInfo.height
        }
    }
    
    /// Search View From Layout ID
    public func findViewByID(_ id: Int) -> UIView? {

        for subview in subviews {
            
            if subview.layoutID == id {
                return subview
            }
            if let view: UIView = subview.findViewByID(id) {
                return view
            }
        }
        return nil
    }
}
