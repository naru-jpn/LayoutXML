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
        
        static let XMLDocument = "xml"
        
        static let LayoutID = "id"
        static let Width = "width"
        static let Height = "height"
        static let Font = "font"
        static let Text = "text"
        static let Title = "title"
        static let BackgroundColor = "background_color"
        
        static let Margin = "margin"
        public struct Margins {
            static let Top = "margin-top"
            static let Right = "margin-right"
            static let Bottom = "margin-bottom"
            static let Left = "margin-left"
        }
        
        static let Padding = "padding"
        public struct Paddings {
            static let Top = "padding-top"
            static let Right = "padding-right"
            static let Bottom = "padding-bottom"
            static let Left = "padding-left"
        }
        
        static let Visibility = "visibility"
        public struct Visibilities {
            static let Visible = "visible"
            static let Invisible = "invisible"
            static let Gone = "gone"
        }
        
        public struct Length {
            static let FillParent = "fill_parent"
            static let MatchParent = "match_parent"
            static let WrapContent = "wrap_content"
        }
        
        public struct LinearLayout {
            
            static let Weight = "weight"
            static let WeightSum = "weight_sum"
            
            static let Gravity = "gravity"
            static let LayoutGravity = "layout_gravity"
            public struct Gravities {
                static let Top = "top"
                static let Right = "right"
                static let Bottom = "bottom"
                static let Left = "left"
                static let CenterHorizontal = "center_horizontal"
                static let CenterVertical = "center_vertical"
                static let Center = "center"
            }
            
            static let Orientation = "orientation"
            public struct Orientations {
                static let Horizontal = "horizontal"
                static let Vertical = "vertical"
            }
        }
        
        public struct RelativeLayout {
            
            public struct AlignRules {
                
                public struct Aligns {
                    static let Top = "align_top"
                    static let Left = "align_left"
                    static let Bottom = "align_bottom"
                    static let Right = "align_right"
                }
                
                public struct Positions {
                    static let Top = "above"
                    static let Left = "to_left_of"
                    static let Bottom = "below"
                    static let Right = "to_right_of"
                }
                
                static let AlignParent = "align_parent"
                public struct AlignParents {
                    static let Top = "top"
                    static let Left = "left"
                    static let Bottom = "bottom"
                    static let Right = "right"
                    static let CenterHorizontal = "center_horizontal"
                    static let CenterVertical = "center_vertical"
                    static let Center = "center"
                }
            }
        }
        
        public struct Label {
            
            static let NumberOfLines = "number_of_lines"
            
            static let LineBreakMode = "line_break_mode"
            public struct LineBreakModes {
                static let ByWordWrapping = "word_wrapping"
                static let ByCharWrapping = "char_wrapping"
                static let ByClipping = "clipping"
                static let ByTruncatingHead = "truncating_head"
                static let ByTruncatingTail = "truncating_tail"
                static let ByTruncatingMiddle = "truncating_middle"
            }
        }
        
        static let ColorPlist = "LayoutXMLColors"
    }
}


/// Representing length of view
public typealias LayoutXMLLength = CGFloat

public extension LayoutXMLLength {
    public static let Zero = CGFloat(0.0)
    /// having same length with parent
    public static let FillParent  = CGFloat(-1.0)
    public static let MatchParent = CGFloat(-1.0)
    /// having enough length to wrap children
    public static let WrapContent = CGFloat(-2.0)
    /// otherwise, value is represent view length
}

/// Return LayoutXMLLength from string.
/// - parameter string: string to convert
/// - returns: layout xml length value
public func layoutXMLLength(string: String?) -> LayoutXMLLength {
    
    guard let string = string?.lowercased().replacingOccurrences(of: " ", with: "") else {
        return LayoutXMLLength.Zero
    }
    
    if string == LayoutXML.Constants.Length.FillParent || string == LayoutXML.Constants.Length.MatchParent {
        return LayoutXMLLength.MatchParent
    }
    else if string == LayoutXML.Constants.Length.WrapContent {
        return LayoutXMLLength.WrapContent
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
    public static let Zero = LayoutXMLSize(width: 0.0, height: 0.0)
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

public extension LayoutXMLEdgeInsets {
    public static let Zero = UIEdgeInsets.zero
}

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
        return LayoutXMLEdgeInsets.Zero
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
        return LayoutXMLEdgeInsets.Zero
    }
}



/// Visibility of view
public enum LayoutXMLVisibility: Int {
    /// view is visible and view size is effected
    case Visible = 0
    /// view is invisible but view size is effected
    case Invisible
    /// view is invisible and view size is not effected
    case Gone
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
                return LayoutXMLEdgeInsets.Zero
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
                return LayoutXMLSize.Zero
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
                return LayoutXMLVisibility.Visible
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
                return LayoutXMLDependency(anchors: anchors, alignParent: .Default)
            }
            return LayoutXMLDependency(values: values)
        }
        set {
            set(&AssociateKeys.dependency, object: newValue.values)
        }
    }
    
    // MARK: Visibility
    
    public func updateVisibility() {
        isHidden = (visibility != .Visible)
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
        }
        // wrap content
        else if sizeInfo.width == LayoutXMLLength.WrapContent {
            
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
                    _size.width = LayoutXMLLength.Zero
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
        }
        // wrap content
        else if sizeInfo.height == LayoutXMLLength.WrapContent {
            
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
                    _size.height = LayoutXMLLength.Zero
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
