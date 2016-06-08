//
//  LayoutXMLInflater.swift
//  
//
//  Created by naru on 2016/05/04.
//
//

import UIKit
import Foundation

final class LayoutXMLInflater: NSObject, NSXMLParserDelegate {
    
    internal class LayoutXMLElement: CustomStringConvertible {
    
        let name: String
        let attributes: [String: String]
        let superElement: LayoutXMLElement?
        var children: [LayoutXMLElement] = []
        
        init(name: String, attributes: [String: String], superElement: LayoutXMLElement?) {
            self.name = name
            self.attributes = attributes
            self.superElement = superElement
        }
        
        var description: String {
            if children.count == 0 {
                return "\(name)"
            } else {
                return "\(name): \(children)"
            }
        }
    }
    
    private var objects: [LayoutXMLElement] = []
    private var current: LayoutXMLElement?
    
    internal typealias LayoutXMLInflaterCompletion = (converter: LayoutXMLInflater, views: [UIView]) -> Void
    var completion: LayoutXMLInflaterCompletion?
    
    /// Inflate layout xml.
    /// - parameter resource: layout xml file name
    /// - parameter completion: completion handler
    internal func inflate(resource resource: String, completion: LayoutXMLInflaterCompletion?) {
        
        let name: String = resource.hasSuffix(".xml") ? resource.stringByReplacingOccurrencesOfString(".xml", withString: "") : resource
        guard let file: String = NSBundle.mainBundle().pathForResource(name, ofType: "xml") else {
            return
        }
        guard let data: NSData = NSData(contentsOfFile: file) else {
            return
        }
        
        self.completion = completion
        
        dispatch_async(dispatch_get_main_queue(), {
            let parser = NSXMLParser(data: data)
            parser.delegate = self
            parser.parse()
        })
    }
    
    // MARK: xml parser delegate -
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if LayoutXML.Constants.XMLDocument == elementName {
            return
        }
        
        guard let _ = NSClassFromString(elementName) as? UIView.Type else {
            return
        }
        
        let element = LayoutXMLElement(name: elementName, attributes: attributeDict, superElement: current)
        
        if let current = current {
            current.children.append(element)
        } else {
            objects.append(element)
        }
        current = element
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        current = current?.superElement
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        
        if let completion = self.completion {

            let views = objects.flatMap { object in
                return convertXMLElementToView(xmlElement: object)
            }
            completion(converter: self, views: views)
        }
    }
    
    // MARK: inflate layout element -
    
    /// Inflate element added sub views from child elements.
    /// Return nil if class represented by element name is not UIView or UIView inherited class.
    /// - parameter xmlElement: xml element to create view
    /// - returns: object of UIView or UIView inherited class
    func convertXMLElementToView(xmlElement xmlElement: LayoutXMLInflater.LayoutXMLElement) -> UIView? {
        guard let _class = NSClassFromString(xmlElement.name) as? UIView.Type else {
            return nil
        }
        let view = _class.view(layoutXMLElement: xmlElement)
        let subViews = xmlElement.children.flatMap { child in
            return convertXMLElementToView(xmlElement: child)
        }
        for subView in subViews {
            view.addSubview(subView)
        }
        return view
    }
}
