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
        view.backgroundColor = UIColor.white
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.loadLayoutXML(resource: "layouts") {
            // completion
        }
    }
    
    override func viewDidLayoutSubviews() {
        if let id: Int = LayoutXML.R.id("@id/layouts"), let view: UIView = view.findViewByID(id) {
            if #available(iOS 11.0, *) {
                view.margin = self.view.safeAreaInsets
            } else {
                view.margin.top = self.view.frame.size.width > self.view.frame.size.height ? 0.0 : 20.0
            }
        }
        view.refreshLayout()
    }
}
