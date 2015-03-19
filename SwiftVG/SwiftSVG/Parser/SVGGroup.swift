//
//  SVGGroup.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// an SVGGroup contains a set of SVGGroupable objects, which could be SVGPaths or SVGGroups.
class SVGGroup: SVGGroupable {
    
    var group:SVGGroup? //The parent of this group, if any
    
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
    init(drawables:[SVGGroupable]) {
        self.drawables = drawables
    }
    
    /// Draws the SVGGroup to the screen by iterating through its contained SVGDrawables
    func draw() {
        for drawable in drawables {
            drawable.draw()
        }
    }
    
    /// Adds an SVGGroupable (SVGDrawable) to the group - and sets that SVGGroupable's group property
    /// to point at this SVGGroup
    ///
    /// :param: drawable an SVGGroupable/SVGDrawable to add to this group
    func addToGroup(drawable:SVGGroupable) {
        var groupableDrawable = drawable
        drawables.append(groupableDrawable)
        groupableDrawable.group = self
    }
    
    //MARK: Private variables and functions
    
    private var drawables:[SVGGroupable] //The list of drawables (which are themselves groupable) in this group
    
}
