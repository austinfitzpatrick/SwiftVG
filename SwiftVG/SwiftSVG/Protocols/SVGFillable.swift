//
//  Fillable.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// Protocol shared by objects capable of acting as a fill for an SVGPath
protocol SVGFillable: class {
    func asColor() -> UIColor?
    func asGradient() -> SVGGradient?
}

/// Extend UIColor to conform to SVGFillable
extension UIColor: SVGFillable{
    func asColor() -> UIColor? { return self }
    func asGradient() -> SVGGradient? { return nil}
}
