//
//  ViewController.swift
//  LayoutXMLExample
//
//  Created by naru on 2018/03/25.
//  Copyright © 2018年 naru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.loadLayoutXML(resource: "layouts") {
            // completion
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        if let id: Int = LayoutXML.R.id("@id/layouts"), let view: UIView = self.view.findViewByID(id) {
            let margin: CGFloat = self.view.frame.size.width > self.view.frame.size.height ? 0.0 : 20.0
            view.margin.top = margin
        }
        
        if let id: Int = LayoutXML.R.id("@id/linear_foundation"), let view: UIView = self.view.findViewByID(id) {
            let margin: CGFloat = self.view.frame.size.width > self.view.frame.size.height ? 0.0 : 20.0
            view.margin.top = margin
        }
        
        if let id: Int = LayoutXML.R.id("@id/relative_foundation"), let view: UIView = self.view.findViewByID(id) {
            let margin: CGFloat = self.view.frame.size.width > self.view.frame.size.height ? 0.0 : 20.0
            view.margin.top = margin
        }
        
        self.view.refreshLayout()
    }
}
