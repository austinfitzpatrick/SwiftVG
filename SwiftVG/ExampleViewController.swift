//
//  ViewController.swift
//  SwiftVG
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 austinfitzpatrick. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    @IBOutlet private var svgView:SVGView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        svgView.vectorImage?.replaceColor(UIColor.blackColor(), withColor: UIColor.whiteColor(), includeGradients: true)
        svgView.setNeedsDisplay()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

