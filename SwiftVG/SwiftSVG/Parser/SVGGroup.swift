//
//  SVGGroup.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// an SVGGroup contains a set of SVGDrawable objects, which could be SVGPaths or SVGGroups.
class SVGGroup: SVGDrawable, Printable {
    
    var group:SVGGroup? //The parent of this group, if any
    var clippingPath:UIBezierPath? //the clipping path for this group, if any
    var identifier:String?
    
    var onWillDraw:(()->())?
    var onDidDraw:(()->())?
    
    /// Initialies and empty SVGGroup
    ///
    /// :returns: an SVGGroup with no drawables
    init(){
        self.drawables = []
    }
    
    /// Initializes an SVGGroup pre-populated with drawables
    /// 
    /// :param: drawables the drawables to populate the group with
    /// :returns: an SVGGroup pre-populated with drawables
    init(drawables:[SVGDrawable]) {
        self.drawables = drawables
    }

    /// Draws the SVGGroup to the screen by iterating through its contained SVGDrawables
    func draw() {
        onWillDraw?()
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        if let clippingPath = clippingPath {
            clippingPath.addClip()
        }
        for drawable in drawables {
            drawable.draw()
        }
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
        onDidDraw?()
    }
    
    /// Adds an SVGDrawable (SVGDrawable) to the group - and sets that SVGDrawable's group property
    /// to point at this SVGGroup
    ///
    /// :param: drawable an SVGDrawable/SVGDrawable to add to this group
    func addToGroup(drawable:SVGDrawable) {
        var groupable = drawable
        drawables.append(groupable)
        groupable.group = self
    }
    
    /// Prints the contents of the group
    var description:String {
        return "{Group<\(drawables.count)> (\(clippingPath != nil)): \(drawables)}"
    }
    
    //MARK: Private variables and functions
    
    internal var drawables:[SVGDrawable] //The list of drawables (which are themselves groupable) in this group
    
}
