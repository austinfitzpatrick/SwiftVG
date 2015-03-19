//
//  SVGGroupable.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/19/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import Foundation

/// The SVGGroupable protocol extends SVGDrawable to specify that the drawable can be stored an SVGGroup
protocol SVGGroupable: SVGDrawable {
    var group:SVGGroup? { get set } //The parent group of this SVGGroupable
}