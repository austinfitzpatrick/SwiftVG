
//
//  File.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

// An SVGDrawable can be drawn to the screen.  To conform a type must implement one method, draw()
protocol SVGDrawable {
    var identifier:String? { get set }//The ID of the drawable for targetting
    func draw() //Draw the SVGDrawable to the screen
    var group:SVGGroup? { get set } //The parent group of this SVGDrawable
    var clippingPath:UIBezierPath? { get set } //The clipping path for this drawable - if any
    var onWillDraw:(()->())? { get set }
    var onDidDraw:(()->())? { get set }
}
