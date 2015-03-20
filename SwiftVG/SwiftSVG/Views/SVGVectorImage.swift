//
//  SVGDrawable.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// An SVGVectorImage is used by a SVGView to display an SVG to the screen.
class SVGVectorImage: SVGGroup {

    private(set) var size:CGSize //the size of the SVG's at "100%"
    
    /// initializes an SVGVectorImage with a list of drawables and a size
    ///
    /// :param: drawables The list of drawables at the root level - can be nested
    /// :param: size The size of the vector image at "100%"
    /// :returns: An SVGVectorImage ready for display in an SVGView
    init(drawables:[SVGDrawable], size:CGSize){
        self.size = size
        super.init(drawables:drawables)
    }
    
    /// initializes an SVGVectorImage with the contents of another SVGVectorImage
    ///
    /// :param: vectorImage another vector image to take the contents of
    /// :returns: an SVGVectorImage ready for display in an SVGView
    init(vectorImage: SVGVectorImage){
        self.size = vectorImage.size
        super.init(drawables:vectorImage.drawables)
    }
    
    /// Initializes an SVGVectorImage with the contents of the file at the
    /// given path
    ///
    /// :param: path A file path to the SVG file
    /// :returns: an SVGVectorImage ready for display in an SVGView
    convenience init(path: String) {
        let (drawables, size) = SVGParser(path: path).coreParse()
        self.init(drawables: drawables, size: size)
    }
    
    /// Initializes an SVGVectorImage with the data provided (should be an XML String)
    ///
    /// :param: path A file path to the SVG file
    /// :returns: an SVGVectorImage ready for display in an SVGView
    convenience init(data:NSData) {
        let (drawables, size) = SVGParser(data: data).coreParse()
        self.init(drawables: drawables, size: size)
    }
    
    /// Optionally initialies an SVGVectorImage with the given name in the main bundle
    ///
    /// :param: name The name of the vector image file (without the .svg extension)
    /// :returns: an SVGVectorImage ready for display in an SVGView or nil if no svg exists
    ///           at the given path
    convenience init?(named name: String){
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "svg"){
            let vector = SVGParser(path: path).parse()
            self.init(vectorImage: vector)
        } else {
            self.init(drawables:[], size:CGSizeZero)
            return nil
        }
    }
    
}
