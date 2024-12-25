//
//  SVGConverter.swift
//  climbing-gym-manager
//
//  Created by Jędrzej Kocięcki on 20/12/2024.
//

import SwiftUI

struct PathWrapper {
    var path: Path
    var id: String
    var color: Color
}

struct Sector {
    var paths: [PathWrapper]
    var id: String
}

class SVGParser {
    private var sectors: [Sector] = []
    
    func parseSVG(from svg: String) -> [Sector] {
        sectors.removeAll()
        
        // Parse groups
        let groupRegex = try! NSRegularExpression(pattern: "<g[^>]*id=\"([^\"]+)\"[^>]*>(.*?)</g>", options: [.dotMatchesLineSeparators])
        let groupMatches = groupRegex.matches(in: svg, options: [], range: NSRange(location: 0, length: svg.utf16.count))
        
        for groupMatch in groupMatches {
            if let groupRange = Range(groupMatch.range(at: 0), in: svg),
               let idRange = Range(groupMatch.range(at: 1), in: svg),
               let contentRange = Range(groupMatch.range(at: 2), in: svg) {
                
                let groupId = String(svg[idRange])
                let groupContent = String(svg[contentRange])
                
                // Parse paths within group
                var pathsInGroup = parsePaths(from: groupContent)
                sectors.append(Sector(paths: pathsInGroup, id: groupId))
            }
        }
        
        return sectors
    }
    
    private func parsePaths(from content: String) -> [PathWrapper] {
        var paths: [PathWrapper] = []
        
        let pathRegex = try! NSRegularExpression(pattern: "<path[^>]*id=\"([^\"]+)\"[^>]*d=\"([^\"]+)\"[^>]*fill=\"([^\"]+)\"[^>]*/>", options: [])
        let matches = pathRegex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
        
        for match in matches {
            if let idRange = Range(match.range(at: 1), in: content),
               let pathRange = Range(match.range(at: 2), in: content),
               let fillRange = Range(match.range(at: 3), in: content) {
                
                let id = String(content[idRange])
                let pathData = String(content[pathRange])
                let fillColor = String(content[fillRange])
                
                if let path = convertToSwiftUIPath(from: pathData) {
                    let color = parseColor(from: fillColor)
                    paths.append(PathWrapper(path: path, id: id, color: color))
                }
            }
        }
        
        return paths
    }
    
    private func convertToSwiftUIPath(from pathData: String) -> Path? {
        var path = Path()
        let regex = try! NSRegularExpression(pattern: "([a-zA-Z])|([-]?[0-9]*\\.?[0-9]+)", options: [])
        let matches = regex.matches(in: pathData, range: NSRange(pathData.startIndex..., in: pathData))
        
        var currentPoint = CGPoint.zero
        var startPoint = CGPoint.zero
        var command: Character = "M"
        var values: [CGFloat] = []
        
        for match in matches {
            let str = String(pathData[Range(match.range, in: pathData)!])
            
            if let num = Double(str) {
                values.append(CGFloat(num))
            } else {
                processPathCommand(command: command, values: &values, path: &path, currentPoint: &currentPoint, startPoint: &startPoint)
                command = Character(str)
            }
        }
        
        // Process last command
        processPathCommand(command: command, values: &values, path: &path, currentPoint: &currentPoint, startPoint: &startPoint)
        
        return path
    }
    
    private func processPathCommand(command: Character, values: inout [CGFloat], path: inout Path, currentPoint: inout CGPoint, startPoint: inout CGPoint) {
        guard !values.isEmpty else { return }
        
        switch command {
        case "M", "m":
            let x = values[0], y = values[1]
            currentPoint = command == "M" ? CGPoint(x: x, y: y) : CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
            path.move(to: currentPoint)
            startPoint = currentPoint
            
        case "L", "l":
            let x = values[0], y = values[1]
            currentPoint = command == "L" ? CGPoint(x: x, y: y) : CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
            path.addLine(to: currentPoint)
            
        case "H", "h":
            let x = values[0]
            currentPoint = CGPoint(x: command == "H" ? x : currentPoint.x + x, y: currentPoint.y)
            path.addLine(to: currentPoint)
            
        case "V", "v":
            let y = values[0]
            currentPoint = CGPoint(x: currentPoint.x, y: command == "V" ? y : currentPoint.y + y)
            path.addLine(to: currentPoint)
            
        case "C", "c":
            let x1 = values[0], y1 = values[1]
            let x2 = values[2], y2 = values[3]
            let x = values[4], y = values[5]
            
            let control1 = command == "C" ?
                CGPoint(x: x1, y: y1) :
                CGPoint(x: currentPoint.x + x1, y: currentPoint.y + y1)
            
            let control2 = command == "C" ?
                CGPoint(x: x2, y: y2) :
                CGPoint(x: currentPoint.x + x2, y: currentPoint.y + y2)
            
            let endPoint = command == "C" ?
                CGPoint(x: x, y: y) :
                CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
            
            path.addCurve(to: endPoint, control1: control1, control2: control2)
            currentPoint = endPoint
            
        case "Z", "z":
            path.closeSubpath()
            currentPoint = startPoint
            
        default:
            break
        }
        
        values.removeAll()
    }
    
    private func parseColor(from fillAttribute: String) -> Color {
        if fillAttribute == "none" {
            return Color.clear
        } else if fillAttribute.hasPrefix("#") {
            return Color(hex: fillAttribute) ?? Color.black
        } else {
            return Color(fillAttribute)
        }
    }
}
