//
//  SVGGradient.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// the SVGGradient protocol extends SVGFillable to specify that the conforming type should
/// be able to supply an CGGradient and modify it with a given opacity when asked
protocol SVGGradient: SVGFillable {
    
    var id:String { get }   //an ID for gradient lookup
    var stops:[GradientStop] { get } //a list of GradientStops
    func addStop(offset:CGFloat, color:UIColor, opacity:CGFloat) //Add a gradient stop with an offset and color
    func removeStop(stop:GradientStop)
    func drawGradientWithOpacity(opacity:CGFloat) //Should draw the gradient - call this after clipping with a bezier path
}

/// Structure defining a gradient stop - contains an offset and a color
struct GradientStop: Equatable{
    var offset:CGFloat
    var color:UIColor
    var opacity:CGFloat = 1.0
}

func ==(lhs:GradientStop, rhs:GradientStop) -> Bool{
    return lhs.offset == rhs.offset && lhs.color == rhs.color
}