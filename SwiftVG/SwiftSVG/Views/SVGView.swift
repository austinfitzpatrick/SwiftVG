//
//  SVGView.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// An SVGView provides a way to display SVGVectorImages to the screen respecting the contentMode property.
@IBDesignable class SVGView: UIView {
    
    @IBInspectable var svgName:String?  // The name of the SVG - mostly for interface builder
        { didSet { svgNameChanged() } }
    var vectorImage:SVGVectorImage?             // The vector image to draw to the screen
        { didSet { setNeedsDisplay() } }
    
    convenience init(vectorImage:SVGVectorImage?){
        self.init(frame:CGRect(x: 0, y: 0, width: vectorImage?.size.width ?? 0, height: vectorImage?.size.height ?? 0))
        self.vectorImage = vectorImage
    }

    
    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        if let svgName = svgName { svgNameChanged() }
    }
    
    /// When the SVG's name changes we'll reparse the new file
    func svgNameChanged() {
        #if !TARGET_INTERFACE_BUILDER
            let bundle = NSBundle.mainBundle()
        #else
            let bundle = NSBundle(forClass: self.dynamicType)
        #endif
        if let path = bundle.pathForResource(svgName, ofType: "svg") {
            let parser = SVGParser(path: path)
            vectorImage = parser.parse()
        } else {
            vectorImage = nil
        }

    }
    
    /// Draw the SVGVectorImage to the screen - respecting the contentMode property
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if let svg = self.vectorImage {
            let context = UIGraphicsGetCurrentContext()
            let translation = svg.translationWithTargetSize(rect.size, contentMode: contentMode)
            let scale = svg.scaleWithTargetSize(rect.size, contentMode: contentMode)
            CGContextScaleCTM(context, scale.width, scale.height)
            CGContextTranslateCTM(context, translation.x / scale.width, translation.y / scale.height)
            svg.draw()
        }
    }
    
    /// Interface builder drawing code
    override func prepareForInterfaceBuilder() {
        svgNameChanged()
        setNeedsDisplay()
    }
    
}
