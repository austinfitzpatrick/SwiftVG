//
//  SVGDrawable.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// An SVGVectorImage is used by a SVGView to display an SVG to the screen.
class SVGVectorImage: NSObject, SVGDrawable {

    private(set) var size:CGSize //the size of the SVG's at "100%"
    
    /// initializes an SVGVectorImage with a list of drawables and a size
    ///
    /// :param: drawables The list of drawables at the root level - can be nested
    /// :param: size The size of the vector image at "100%"
    /// :returns: An SVGVectorImage ready for display in an SVGView
    init(drawables:[SVGDrawable], size:CGSize){
        self.drawables = drawables
        self.size = size
        super.init()
    }
    
    init(vectorImage: SVGVectorImage){
        self.drawables = vectorImage.drawables
        self.size = vectorImage.size
    }
        
    //MARK: SVGDrawable
    
    /// Draw the SVGVectorImage to the screen
    func draw(){
        for drawable in drawables {
            drawable.draw()
        }
    }
    
    //MARK: Private variables and functions
    
    private var drawables:[SVGDrawable]  //The list of drawables that makes up an SVGVectorImage
}
