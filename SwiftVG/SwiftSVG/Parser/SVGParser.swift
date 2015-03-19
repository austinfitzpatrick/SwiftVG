//
//  SVGParser.swift
//  SVGPlayground
//
//  Created by Austin Fitzpatrick on 3/18/15.
//  Copyright (c) 2015 Seedling. All rights reserved.
//

import UIKit

/// A Parser which takes in a .svg file and spits out an SVGVectorImage for display
/// Begin your interaction with the parser by initializing it with a path and calling
/// parse() to retrieve an SVGVectorImage.  Safe to call on a background thread.
class SVGParser: NSObject, NSXMLParserDelegate {
    
    /// Initializes an SVGParser for the file at the given path
    ///
    /// :param: path The path to the SVG file
    /// :returns: An SVGParser ready to parse()
    init(path:String) {
        let url = NSURL(fileURLWithPath: path)
        if let parser = NSXMLParser(contentsOfURL: url) {
            self.parser = parser
        } else {
            fatalError("SVGParser could not find an SVG at the given path: \(path)")
        }
    }
    
    init(data:NSData) {
        self.parser = NSXMLParser(data: data)
    }
    
    /// Parse the supplied SVG file and return an SVGVectorImage
    ///
    /// :returns: an SVGImageVector ready for display
    func parse() -> SVGVectorImage {
        let (drawables, size) = coreParse()
        return SVGVectorImage(drawables: drawables, size:size)
    }
    
    /// Parse the supplied SVG file and return the components of an SVGVectorImage
    ///
    /// :returns: a tuple containing the SVGDrawable array and the size of the SVGVectorImage
    func coreParse() -> ([SVGDrawable], CGSize) {
        parser?.delegate = self
        parser?.parse()
        return (drawables, svgViewBox.size)
    }
    
    //MARK: Private variables and functions
    
    private var parser:NSXMLParser?                  //an NSXMLParser to do the actual XML parsing.
    
    private var svgViewBox:CGRect = CGRectZero       //viewbox defines the bounds and size of the vector image
    
    private var drawables:[SVGDrawable] = []         //A list of drawables at the root level - can include paths and groups
    private var colors:[String:UIColor] = [:]        //A list of colors found in the document - cached for re-use
    private var gradients:[String:SVGGradient] = [:] //A list of gradients referenced by the document
    private var rects:[String:CGRect] = [:]          //A list of rectangles given names by the document
    
    private var lastGradient:SVGGradient?            //the currently open gradient
    private var lastGroup:SVGGroup?                  //the currently open group
    private var definingDefs:Bool = false            //whether or not we're defining <defs> for rects, etc

    /// Takes a string containing a hex value and converts it to a UIColor.  Caches the UIColor for later use.
    ///
    /// :param: potentialHexString the string potentially containing a hex value to parse into a UIColor
    /// :returns: UIColor representation of the hex string - or nil if no hex string is found
    func addColor(potentialHexString:String?) -> UIColor?{
        if let potentialHexStringUnwrapped = potentialHexString {
            if let hexRange = potentialHexStringUnwrapped.rangeOfString("#", options: .allZeros, range: nil, locale: nil){
                let hexString = potentialHexStringUnwrapped.stringByReplacingCharactersInRange(Range<String.Index>(start:potentialHexStringUnwrapped.startIndex, end: hexRange.startIndex), withString: "")
                colors[hexString] = colors[hexString] ?? UIColor(hexString: hexString)
                return colors[hexString]
            }
        }
        return nil
    }
    
    /// Parses a viewBox string and sets the view box of the SVG
    ///
    /// :param: attributeDict the attribute dictionary from the SVG element form which to extract a view box
    func setViewBox(attributeDict:[NSObject:AnyObject]){
        if let viewBox = attributeDict["viewBox"] as? NSString {
            let floats:[CGFloat] = viewBox.componentsSeparatedByString(" ").map { CGFloat(($0 as NSString).floatValue) }
            if floats.count < 4 { svgViewBox = CGRectZero; println("An error has occured - the view box is zero") }
            svgViewBox = CGRect(x: floats[0], y: floats[1], width: floats[2], height: floats[3])
        } else {
            let width = (attributeDict["width"] as NSString).floatValue
            let height = (attributeDict["height"] as NSString).floatValue
            svgViewBox = CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height))
        }
    }
    
    /// Returns either a gradient ID or hex string for a color from a string (strips "url(" from gradient references)
    ///
    /// :param: string The string to parse for #hexcolors or url(#gradientId)
    /// :returns: A string fit for using as a key to lookup gradients and colors - or nil of the param was nil
    private func gradientIdOrHexFromAttribute(string:String?) -> String? {
        let newString = string?.stringByReplacingOccurrencesOfString("url(#", withString: "", options: .allZeros, range: nil)
        return newString?.stringByReplacingOccurrencesOfString(")", withString: "", options: .allZeros, range: nil)
    }
    
    /// Returns an array of points parsed out of a string in the format "x1,y1 x2,y2 x3,y3"
    ///
    /// :params: string the string to parse points out of
    /// :returns: an array of CGPoint structs representing the points in the string
    private func pointsFromPointString(string:String?) -> [CGPoint] {
        if string == nil { return [] }
        let pairs = string!.componentsSeparatedByString(" ") as [String]
        return pairs.filter{ ($0.utf16Count > 0) }.map {
            let numbers = $0.componentsSeparatedByString(",")
            let x = (numbers[0] as NSString).floatValue
            let y = (numbers[1] as NSString).floatValue
            return CGPoint(x:CGFloat(x) - self.svgViewBox.origin.x, y:CGFloat(y) - self.svgViewBox.origin.y)
        }
    }
    
    /// Processes a rectangle found during parsing.  If we're defining the <defs> for the document we'll just save the rect
    /// for later use.  If we're not currently defining <defs> then we'll interpret it as a rectangular path.
    ///
    /// :param: attributeDict The attributes from the XML element - currently "x", "y", "width", "height", "id", "opacity", "fill" are supported.
    func addRect(attributeDict: [NSObject : AnyObject]){
        let id = attributeDict["id"] as? String
        let originX = CGFloat((attributeDict["x"] as NSString).floatValue)
        let originY = CGFloat((attributeDict["y"] as NSString).floatValue)
        let width = CGFloat((attributeDict["width"] as NSString).floatValue)
        let height = CGFloat((attributeDict["height"] as NSString).floatValue)
        let rect = CGRectOffset(CGRect(x: originX, y: originY, width: width, height: height), -svgViewBox.origin.x, -svgViewBox.origin.y)
        if definingDefs {
            if let id = id {
                rects[id] = rect
            } else{
                println("Defining defs, but didn't find id for rect")
            }
        } else {
            var fill:SVGFillable? = nil
            if let attr = gradientIdOrHexFromAttribute(attributeDict["fill"] as? String){
                fill = gradients[attr] ?? addColor(attr)
            }
            var opacity = CGFloat(1.0)
            if let o = (attributeDict["opacity"] as? NSString)?.floatValue {
                opacity = CGFloat(o)
            }
            
            let path = SVGPath(bezierPath: UIBezierPath(rect: rect), fill:fill, opacity: opacity)
            if lastGroup != nil {
                lastGroup?.addToGroup(path)
            } else {
                drawables.append(path)
            }
        }
    }
    
    /// Adds a path defined by attributeDict to either the last group or the root element, if no group exists
    ///
    /// :param: attributeDict The attributes from the XML element - currently "fill", "opacity" and "d" are supported.
    private func addPath(attributeDict: [NSObject:AnyObject]){
        var fill:SVGFillable? = nil
        if let attr = gradientIdOrHexFromAttribute(attributeDict["fill"] as? String){
            fill = gradients[attr] ?? addColor(attr)
        }
        var opacity = CGFloat(1.0)
        if let o = (attributeDict["opacity"] as? NSString)?.floatValue {
            opacity = CGFloat(o)
        }
        let d = attributeDict["d"] as String
        let bezierPath = UIBezierPath(SVGString: d)
        bezierPath.applyTransform(CGAffineTransformMakeTranslation(-svgViewBox.origin.x, -svgViewBox.origin.y))
        bezierPath.miterLimit = 4
        let path = SVGPath(bezierPath: bezierPath, fill: fill, opacity:opacity)
        if lastGroup != nil {
            lastGroup?.addToGroup(path)
        } else {
            drawables.append(path)
        }
    }
    
    /// Adds a path in the shape of the polygon defined by attributeDict
    ///
    /// :param: attributeDict the attributes from the XML - currently "points", "fill", and "opacity"
    private func addPolygon(attributeDict:[NSObject : AnyObject]) {
        let points = pointsFromPointString(attributeDict["points"] as? String)

        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(points[0])
        for i in 1..<points.count {
            bezierPath.addLineToPoint(points[i])
        }
        bezierPath.closePath()

        
        var fill:SVGFillable? = nil
        if let attr = gradientIdOrHexFromAttribute(attributeDict["fill"] as? String){
            fill = gradients[attr] ?? addColor(attr)
        }
        var opacity = CGFloat(1.0)
        if let o = (attributeDict["opacity"] as? NSString)?.floatValue {
            opacity = CGFloat(o)
        }
        let path = SVGPath(bezierPath: bezierPath, fill: fill, opacity: opacity)
        if lastGroup != nil {
            lastGroup?.addToGroup(path)
        } else {
            drawables.append(path)
        }
    }
    
    /// Begins a new group, setting "lastGroup" to the newly created group
    private func beginGroup() {
        let newGroup = SVGGroup()
        if let lastGroup = lastGroup {
            newGroup.addToGroup(lastGroup)
        }
        lastGroup = newGroup
    }
    
    /// Ends the current group and moves "lastGroup" up one level
    private func endGroup() {
        if let last = lastGroup {
            if last.group == nil {
                drawables.append(last)
            }
            lastGroup = last.group
        }
    }
    
    //MARK: NSXMLParserDelegate
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        if let elementNameEnum = ElementName(rawValue: elementName) {
            switch elementNameEnum {
            case .SVG:
                setViewBox(attributeDict)
            case .RadialGradient: lastGradient = SVGRadialGradient(attributeDict: attributeDict, viewBox:svgViewBox)
            case .LinearGradient: lastGradient = SVGLinearGradient(attributeDict: attributeDict, viewBox:svgViewBox)
            case .Stop:
                let offset = CGFloat((attributeDict["offset"] as NSString).floatValue)
                if let color = addColor(attributeDict["style"] as? String){ lastGradient?.addStop(offset, color: color)}
            case .Defs:
                definingDefs = true
            case .Rect:
                addRect(attributeDict)
            case .Path:
                addPath(attributeDict)
            case .G:
                beginGroup()
            case .Polygon:
                addPolygon(attributeDict)
            default: break
                
            }
        }
        
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if let elementNameEnum = ElementName(rawValue: elementName){
            switch elementNameEnum {
            case .RadialGradient:
                if let gradient = lastGradient {
                    gradients[gradient.id] = gradient
                    lastGradient = nil
                } else {
                    println("We exited a gradient without having a last gradient - something went wrong.")
                }
            case .LinearGradient:
                if let gradient = lastGradient {
                    gradients[gradient.id] = gradient
                    lastGradient = nil
                } else {
                    println("We exited a gradient without having a last gradient - something went wrong.")
                }
            case .Defs:
                definingDefs = false
            case .G:
                endGroup()
            default: break
            }
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        
        parser.delegate = self
        self.parser = nil
    }
    
    
    //MARK: Constants
    // Enumeration defining the possible XML tags in an SVG file
    enum ElementName:String {
        case SVG = "svg"
        case G = "g"
        case Defs = "defs"
        case Rect = "rect"
        case Use = "use"
        case RadialGradient = "radialGradient"
        case LinearGradient = "linearGradient"
        case Stop = "stop"
        case Path = "path"
        case Polygon = "polygon"
    }
    
}
