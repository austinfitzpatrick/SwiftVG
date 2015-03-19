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
    var svg:SVGVectorImage?             // The vector image to draw to the screen
        { didSet { setNeedsDisplay() } }
    
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
            svg = parser.parse()
        } else {
            svg = nil
        }

    }
    
    /// Draw the SVGVectorImage to the screen - respecting the contentMode property
    override func drawRect(rect: CGRect) {
        
        if let svg = self.svg {        
            switch contentMode {
            case .ScaleToFill:
                let xScale = frame.width / svg.size.width
                let yScale = frame.height / svg.size.height
                CGContextScaleCTM(UIGraphicsGetCurrentContext(), xScale, yScale)
            default: break
                
            }
            svg.draw()
        }
    }
    
    /// Interface builder drawing code
    override func prepareForInterfaceBuilder() {
        svgNameChanged()
        setNeedsDisplay()
    }
}
