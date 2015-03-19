//
//  SVGGradient.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// Defines a radial gradient for filling paths.  Create the gradient and then add stops to prepare it for filling.
class SVGRadialGradient: SVGGradient {
    var id:String                       //The id of the gradient for lookup
    var center:CGPoint                  //The center of the gradient
    var radius:CGFloat                  //The radius of the gradient
    var transform:CGAffineTransform     //The transform to apply to the gradient
    var gradientUnits:String            //The units of the gradient TODO
    var stops:[GradientStop]            //Stops define the colors and percentages along the gradient
    
    /// Initializes an SVGRadialGradient to use as a fill
    ///
    /// :param: id The id of the gradient
    /// :param: center The center point of the gradient - before transform is applied
    /// :param: radius The radius of the gradient
    /// :param: gradientUnits the units of the gradient TODO
    /// :param: viewBox the viewBox - used to transform the center point
    /// :returns: an SVGRadialGradient with no stops.  Stops will need to be added with addStop(offset, color)
    init(id:String, center:CGPoint, radius:CGFloat, gradientTransform:String, gradientUnits:String, viewBox:CGRect){
        self.id = id
        self.center = center
        self.radius = radius
        let scanner = NSScanner(string: gradientTransform)
        scanner.scanString("matrix(", intoString: nil)
        var a:Float = 0, b:Float = 0, c:Float = 0, d:Float = 0, tx:Float = 0, ty:Float = 0
        scanner.scanFloat(&a)
        scanner.scanFloat(&b)
        scanner.scanFloat(&c)
        scanner.scanFloat(&d)
        scanner.scanFloat(&tx)
        scanner.scanFloat(&ty)
        transform = CGAffineTransformMake(CGFloat(a), CGFloat(b), CGFloat(c), CGFloat(d), CGFloat(tx), CGFloat(ty))
        self.center = CGPointApplyAffineTransform(self.center, transform)
        self.center = CGPointMake(self.center.x - viewBox.origin.x, self.center.y - viewBox.origin.y)
        self.gradientUnits = gradientUnits
        stops = []
    }
    
    /// Initializes an SVGRadialGradient to use as a fill - convenience for creating it directly from the attributeDict in the XML
    ///
    /// :param: attributeDict the attributeDict directly from the NSXMLParser
    /// :returns: an SVGRadialGradient with no stops.  Stops will need to be added with addStop(offset, color)
    convenience init(attributeDict:[NSObject:AnyObject], viewBox:CGRect){
        let id = attributeDict["id"] as String
        var center = CGPoint(x: CGFloat((attributeDict["cx"] as NSString).floatValue), y: CGFloat((attributeDict["cy"] as NSString).floatValue))
        let radius = CGFloat((attributeDict["r"] as NSString).floatValue)
        let gradientTransform = attributeDict["gradientTransform"] as String
        let gradientUnits = attributeDict["gradientUnits"] as String
        self.init(id:id, center:center, radius:radius, gradientTransform:gradientTransform, gradientUnits:gradientUnits, viewBox:viewBox)
    }
    
    /// Returns a CGGradientRef for drawing to the canvas - after modifing the colors if necsssary with given opacity
    ///
    /// :param: opacity The opacity at which to draw the gradient
    /// :returns: A CGGradientRef ready for drawing to a canvas
    func CGGradientWithOpacity(opacity:CGFloat) -> CGGradientRef {
        if opacity != 1 {
            return CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), stops.map{$0.color.colorWithAlphaComponent(opacity).CGColor}, stops.map{$0.offset})
        } else {
            return CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), stops.map{$0.color.CGColor}, stops.map{$0.offset})
        }
    }

    /// Adds a Stop to the gradient - a Gradient is made up of several stops
    ///
    /// :param: offset the offset location of the stop
    /// :color: the color to blend from/towards at this stop
    func addStop(offset:CGFloat, color:UIColor){
        stops.append(GradientStop(offset: offset, color: color))
    }
    
    //MARK: SVGFillable
    
    /// Returns a fillable as a gradient optional
    /// :returns: self, if self is an SVGGradient, or nil
    func asGradient() -> SVGGradient? {
        return self
    }
    
    /// Returns nil
    /// :returns: self, if self is a UIColor, or nil
    func asColor() -> UIColor? {
        return nil
    }

}