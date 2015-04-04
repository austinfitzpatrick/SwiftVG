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
    
    //MARK: Rendering to images

    /// Renders the vector image to a raster UIImage
    ///
    /// :param: size the size of the UIImage to be returned
    /// :param: contentMode the contentMode to use for rendering, some values may effect the output size
    /// :returns: a UIImage containing a raster representation of the SVGVectorImage
    func renderToImage(#size:CGSize, contentMode:UIViewContentMode = .ScaleToFill) -> UIImage{
        
        let targetSize = sizeWithTargetSize(size, contentMode: contentMode)
        let scale = scaleWithTargetSize(size, contentMode: contentMode)
        UIGraphicsBeginImageContext(targetSize)
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context, scale.width, scale.height)
        self.draw()
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    //MARK: Private Functions and Variables
    
    /// Returns the size of the vector image when scaled to fit in the size parameter using
    /// the given content mode
    /// 
    /// :param: size The size to render at
    /// :param: contentMode the contentMode to use for rendering
    /// :returns: the size to render at
    internal func sizeWithTargetSize(size:CGSize, contentMode:UIViewContentMode) -> CGSize {
        let targetSize = self.size
        let bounds = size
        switch contentMode {
        case .ScaleAspectFit:
            let scaleFactor = min(bounds.width / targetSize.width, bounds.height / targetSize.height)
            let scale = CGSizeMake(scaleFactor, scaleFactor)
            return CGSize(width: targetSize.width * scale.width, height: targetSize.height * scale.height)
        case .ScaleAspectFill:
            let scaleFactor = max(bounds.width / targetSize.width, bounds.height / targetSize.height)
            let scale = CGSizeMake(scaleFactor, scaleFactor)
            return CGSize(width: targetSize.width * scale.width, height: targetSize.height * scale.height)
        case .ScaleToFill:
            return size
        case .Center:
            return size
        default:
            return size
        }
    }
    
    /// Returns the size of the translation to apply when rendering the SVG at the given size with the given contentMode
    ///
    /// :param: size The size to render at
    /// :param: contentMode the contentMode to use for rendering
    /// :returns: the translation to apply when rendering
    internal func translationWithTargetSize(size:CGSize, contentMode:UIViewContentMode) -> CGPoint {
        let targetSize = self.size
        let bounds = size
        var newSize:CGSize
        switch contentMode {
        case .ScaleAspectFit:
            let scaleFactor = min(bounds.width / targetSize.width, bounds.height / targetSize.height)
            let scale = CGSizeMake(scaleFactor, scaleFactor)
            newSize = CGSize(width: targetSize.width * scale.width, height: targetSize.height * scale.height)
            let xTranslation = (bounds.width - newSize.width) / 2.0
            let yTranslation = (bounds.height - newSize.height) / 2.0
            return CGPoint(x:xTranslation, y:yTranslation)
        case .ScaleAspectFill:
            let scaleFactor = max(bounds.width / targetSize.width, bounds.height / targetSize.height)
            let scale = CGSizeMake(scaleFactor, scaleFactor)
            newSize = CGSize(width: targetSize.width * scale.width, height: targetSize.height * scale.height)
            let xTranslation = (bounds.width - newSize.width) / 2.0
            let yTranslation = (bounds.height - newSize.height) / 2.0
            return CGPoint(x:xTranslation, y:yTranslation)
        case .ScaleToFill:
            newSize = size
            let scaleFactor = CGSize(width:bounds.width / targetSize.width, height: bounds.height / targetSize.height)
            return CGPointZero
        case .Center:
            newSize = targetSize
            let xTranslation = (bounds.width - newSize.width) / 2.0
            let yTranslation = (bounds.height - newSize.height) / 2.0
            return CGPoint(x:xTranslation, y:yTranslation)
        default:
            return CGPointZero
        }
    }
    
    /// Returns the scale of the translation to apply when rendering the SVG at the given size with the given contentMode
    ///
    /// :param: size The size to render at
    /// :param: contentMode the contentMode to use for rendering
    /// :returns: the scale to apply to the context when rendering
    internal func scaleWithTargetSize(size:CGSize, contentMode:UIViewContentMode) -> CGSize {

        let targetSize = self.size
        let bounds = size
        var newSize:CGSize
        switch contentMode {
        case .ScaleAspectFit:
            let scaleFactor = min(bounds.width / targetSize.width, bounds.height / targetSize.height)
            return CGSizeMake(scaleFactor, scaleFactor)
        case .ScaleAspectFill:
            let scaleFactor = max(bounds.width / targetSize.width, bounds.height / targetSize.height)
            return CGSizeMake(scaleFactor, scaleFactor)
        case .ScaleToFill:
            return CGSize(width:bounds.width / targetSize.width, height: bounds.height / targetSize.height)
        case .Center:
            return CGSize(width: 1, height: 1)
        default:
            return CGSize(width: 1, height: 1)
        }
    }
    
}
