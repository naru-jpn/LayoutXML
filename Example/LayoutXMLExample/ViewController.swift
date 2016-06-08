//
//  ViewController.swift
//  LayoutXMLExample
//
//  Created by naru on 2016/05/03.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.loadLayoutXML(resource: "absolute_layout")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        self.view.refreshLayout()
    }

}

