//
//  UIColor+Hexadecimal.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// Extension for UIColor allowing it to parse a "#ABCDEF" style hex string
extension UIColor {
    
    /// Initializes a UIColor with a hex string
    /// :param: hexString the string to parse for a hex color
    /// :returns: the UIColor or nil if parsing fails
    convenience init?(hexString:String) {
        if hexString == "#FFFFFF" {
            self.init(white: 1, alpha: 1)
            return
        }
        if hexString == "#000000" {
            self.init(white: 0, alpha: 1)
            return
        }
        let charset = NSCharacterSet(charactersInString: "#0123456789ABCDEF")
        var rgbValue:UInt32 = 0
        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = 1
        scanner.scanHexInt(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green:CGFloat((rgbValue & 0xFF00) >> 8)/255.0, blue:CGFloat(rgbValue & 0xFF)/255.0, alpha:1.0)
        if let range = hexString.rangeOfCharacterFromSet(charset.invertedSet, options: .allZeros, range: nil){
            return nil
        }
    }
}
