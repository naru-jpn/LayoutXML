//
//  R.swift
//  
//
//  Created by naru on 2016/05/06.
//
//

import UIKit
import Foundation

extension LayoutXML {
    
    /// Class managing resources.
    class R {
        
        /// Return layout id from identifier
        class func id(string: String) -> Int? {
            return LayoutIDStore.id(string: string)
        }
        
        /// Return localized string or plane text.
        /// - parameter string: string to get text
        /// - returns: localized string or plane text
        class func string(string: String) -> String {
            if string.hasPrefix("@string/") {
                return NSLocalizedString(string.stringByReplacingOccurrencesOfString("@string/", withString: ""), comment: "")
            } else {
                return string.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
            }
        }
        
        /// Return font.
        /// - parameter string: string to get font: 'font-name:font_size'
        /// - returns: font
        class func font(string: String) -> UIFont? {
            let components: [String] = string.componentsSeparatedByString(":")
            if components.count == 2 {
                let name: String = components[0]
                let size: CGFloat = {
                    var float: Float = 0.0
                    let scanner = NSScanner(string: components[1])
                    scanner.charactersToBeSkipped = NSCharacterSet.lowercaseLetterCharacterSet()
                    scanner.scanFloat(&float)
                    return CGFloat(float)
                }()
                return UIFont(name: name, size: size)
            } else {
                return nil
            }
        }
        
        class func color(string string: String) -> UIColor? {
            
            func color(code code: String) -> UIColor? {
                
                /// Get complete color code.
                /// - parameter code: color code
                /// - returns: complete color code
                func completeCode(code code: String) -> String {
                    
                    let length: Int = code.characters.count
                    switch length {
                    case 6:
                        return "FF".stringByAppendingString(code)
                    case 4:
                        return code.characters.reduce("") {
                            "\($0)" + "\($1)\($1)"
                        }
                    case 3:
                        return "FF".stringByAppendingString(code.characters.reduce("") {
                            "\($0)" + "\($1)\($1)"
                            })
                    default:
                        return code
                    }
                }
                
                var value: UInt32 = 0
                NSScanner(string: completeCode(code: code)).scanHexInt(&value)
                let alpha: CGFloat = CGFloat(((value & (0xFF << 24)) >> 24))/255.0
                let red  : CGFloat = CGFloat(((value & (0xFF << 16)) >> 16))/255.0
                let green: CGFloat = CGFloat(((value & (0xFF <<  8)) >>  8))/255.0
                let blue : CGFloat = CGFloat(((value & (0xFF <<  0)) >>  0))/255.0
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            }
            
            // @code
            if string.hasPrefix("@code/") {
                let code: String = string.stringByReplacingOccurrencesOfString("@code/", withString: "")
                return color(code: code)
            }
            // @color
            if string.hasPrefix("@color/") {
                let name: String = string.stringByReplacingOccurrencesOfString("@color/", withString: "")
                guard let code = ColorStore.store.dictionary?[name] else {
                    return nil
                }
                return color(code: code)
            }
            // @pattern, @+pattern
            // let cached: Bool = string.hasPrefix("@+")
            // TODO: Get image pattern
            // ...
            
            return color(code: string)
        }
        
        /// Class to store layout id
        private class LayoutIDStore {
            
            var incremented: Int = 1
            
            var dictionary: [String: Int] = [:]
            
            class var store: LayoutIDStore {
                struct Static {
                    static let instance: LayoutIDStore = LayoutIDStore()
                }
                return Static.instance
            }
            
            class func id(string string: String) -> Int? {
                
                if string.hasPrefix("@+id/") {
                    
                    let name: String = string.stringByReplacingOccurrencesOfString("@+id/", withString: "")
                    
                    if let id: Int = store.dictionary[name] {
                        return id
                    }
                    
                    self.store.dictionary[name] = store.incremented
                    store.incremented = store.incremented + 1
                                        
                    return store.incremented - 1
                }
                else if string.hasPrefix("@id/") {
                    
                    let name: String = string.stringByReplacingOccurrencesOfString("@id/", withString: "")
                    
                    return store.dictionary[name]
                }
                else {
                    
                    return nil
                }
            }
        }
        
        /// Class to store color data from plist
        private class ColorStore {
         
            var dictionary: [String: String]?
            
            class var store: ColorStore {
                struct Static {
                    static let instance: ColorStore = ColorStore()
                }
                return Static.instance
            }
            
            /// Return color code from key string.
            /// - parameter key: key string to get color code
            /// - return: color code
            class func code(key key: String) -> String? {
                if nil == store.dictionary {
                    if let path = NSBundle.mainBundle().pathForResource(LayoutXML.Constants.ColorPlist, ofType: "plist") {
                        if NSFileManager.defaultManager().fileExistsAtPath(path) {
                            store.dictionary = {
                                guard let dictionary: NSDictionary = NSDictionary(contentsOfFile: path) else {
                                    return nil
                                }
                                var temp: [String: String] = [:]
                                for (key, value) in dictionary {
                                    if let k = key as? String, let v = value as? String {
                                        temp[k] = v
                                    }
                                }
                                return temp
                            }()
                        }
                    }
                }
                return store.dictionary?[key]
            }
        }
    }
}
