
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
    func draw() //Draw the SVGDrawable to the screen
}
