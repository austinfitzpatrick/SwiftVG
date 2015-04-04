//
//  SVGVectorImage+ColorReplacement.swift
//  SwiftVG
//
//  Created by Austin Fitzpatrick on 3/20/15.
//  Copyright (c) 2015 austinfitzpatrick. All rights reserved.
//

import UIKit


protocol SVGColorReplaceable {
    func replaceColor(color: UIColor, withColor replacement:UIColor, includeGradients:Bool)
}

extension SVGGroup: SVGColorReplaceable {
    func replaceColor(color: UIColor, withColor replacement: UIColor, includeGradients:Bool) {
        for drawable in drawables {
            if let group = drawable as? SVGGroup { group.replaceColor(color, withColor: replacement, includeGradients:includeGradients) }
            else if let path = drawable as? SVGPath { path.replaceColor(color, withColor: replacement, includeGradients:includeGradients) }
        }
    }
}

extension SVGPath: SVGColorReplaceable {
    func replaceColor(color: UIColor, withColor replacement: UIColor, includeGradients:Bool) {
        if let fillColor = self.fill?.asColor(){
            if fillColor == color {
                self.fill = replacement
            }
        } else if let fillGradient = self.fill?.asGradient() {
            if includeGradients {
                for stop in fillGradient.stops {
                    if stop.color == color {
                        fillGradient.removeStop(stop)
                        fillGradient.addStop(stop.offset, color: replacement, opacity: 1.0)
                    }
                }
            }
        }
    }
}
