//
//  SVGText.swift
//  Seedling Comic
//
//  Created by Austin Fitzpatrick on 3/23/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

class SVGText: SVGDrawable {

    var group:SVGGroup? /// The group that this Text belongs to
    var clippingPath:UIBezierPath? /// The clipping path to apply to the text
    
    var text:String? /// The string to draw
    var transform:CGAffineTransform? /// The transform to apply to the text
    var fill:SVGFillable? /// The fill to apply to the text
    var font:UIFont? /// The font to use to render the text
    var viewBox:CGRect?
    var identifier:String?
    
    var onWillDraw:(()->())?
    var onDidDraw:(()->())?
    
    init(){
        
    }
    
    /// Draws the text to the current context
    func draw() {
        onWillDraw?()
        let color = fill?.asColor() ?? UIColor.whiteColor()
        let attributes:[NSString:AnyObject] = [NSFontAttributeName: font ?? UIFont.systemFontOfSize(24), NSForegroundColorAttributeName: color]
        let line = CTLineCreateWithAttributedString((NSAttributedString(string:text!, attributes: attributes)))
        var ascent = CGFloat(0)
        CTLineGetTypographicBounds(line, &ascent, nil, nil)
        let offsetToConvertSVGOriginToAppleOrigin = -ascent

        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-viewBox!.origin.x, -viewBox!.origin.y))
        CGContextConcatCTM(context, transform!)

        let size = (text! as NSString).sizeWithAttributes(attributes)
        let p = CGPointMake(0, offsetToConvertSVGOriginToAppleOrigin)
        (text! as NSString).drawInRect(CGRectMake(p.x, p.y, size.width, size.height), withAttributes: attributes)
        CGContextRestoreGState(context)
        onDidDraw?()
    }
    
}