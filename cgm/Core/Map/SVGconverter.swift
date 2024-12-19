

import SwiftUI


struct MyPathWrapper{
    var path: Path
    var sector: String
}

class SVGparser {
    var pathsWithIds: [String: Path] = [:] // Przechowuje ID i ścieżki
    var rect: Path = Path()
    
    init() {}
    
    func parseSVGpaths(from svg: String) -> [MyPathWrapper] {
        var paths: [MyPathWrapper] = []
        let regex = try! NSRegularExpression(pattern: "<path[^>]*id=\"([^\"]+)\"[^>]*d=\"([^\"]+)\"[^>]*>", options: [])
        let matches = regex.matches(in: svg, options: [], range: NSRange(location: 0, length: svg.utf16.count))
        
        for match in matches {
            if let idRange = Range(match.range(at: 1), in: svg),
               let dRange = Range(match.range(at: 2), in: svg) {
                let idAttribute = String(svg[idRange])
                let dAttribute = String(svg[dRange])
                if let path = convertToSwiftUiPath(from: dAttribute) {
                    paths.append(MyPathWrapper(path: path, sector: idAttribute))
                }
            }
        }
        return paths
    }
    
    func extractAttribute(named name: String, from tag: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "\(name)=\"([^\"]*)\"", options: [])
        if let match = regex.firstMatch(in: tag, options: [], range: NSRange(location: 0, length: tag.utf16.count)),
           let range = Range(match.range(at: 1), in: tag) {
            return String(tag[range])
        }
        return nil
    }
    
    func convertToSwiftUiPath(from pathData: String) -> Path? {
        var path = Path()
        let regex = try! NSRegularExpression(pattern: "([a-zA-Z])|([-]?[0-9]*\\.?[0-9]+)", options: [])
        let matches = regex.matches(in: pathData, range: NSRange(pathData.startIndex..., in: pathData))
        
        var currentPoint = CGPoint(x: 0, y: 0)
        var startPoint = CGPoint(x: 0, y: 0)
        var command: Character = "M"
        var values: [CGFloat] = []
        
        for match in matches {
            let str = String(pathData[Range(match.range, in: pathData)!])
            
            if let num = Double(str) {
                values.append(CGFloat(num))
            } else {
                if !values.isEmpty {
                    switch command {
                    case "M", "m":
                        let x = values[0], y = values[1]
                        if command == "M" {
                            currentPoint = CGPoint(x: x, y: y)
                        } else {
                            currentPoint = CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                        }
                        path.move(to: currentPoint)
                        startPoint = currentPoint
                        values.removeAll()
                    case "L", "l":
                        let x = values[0], y = values[1]
                        if command == "L" {
                            currentPoint = CGPoint(x: x, y: y)
                        } else {
                            currentPoint = CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                        }
                        path.addLine(to: currentPoint)
                        values.removeAll()
                    case "C", "c":
                        let x1 = values[0], y1 = values[1], x2 = values[2], y2 = values[3], x = values[4], y = values[5]
                        if command == "C" {
                            currentPoint = CGPoint(x: x, y: y)
                        } else {
                            currentPoint = CGPoint(x: currentPoint.x + x, y: currentPoint.y + y)
                        }
                        path.addCurve(to: currentPoint, control1: CGPoint(x: currentPoint.x + x1, y: currentPoint.y + y1), control2: CGPoint(x: currentPoint.x + x2, y: currentPoint.y + y2))
                        values.removeAll()
                    case "H", "h":
                        let x = values[0]
                        if command == "H" {
                            currentPoint = CGPoint(x: x, y: currentPoint.y)
                        } else {
                            currentPoint = CGPoint(x: currentPoint.x + x, y: currentPoint.y)
                        }
                        path.addLine(to: currentPoint)
                        values.removeAll()
                    case "V", "v":
                        let y = values[0]
                        if command == "V" {
                            currentPoint = CGPoint(x: currentPoint.x, y: y)
                        } else {
                            currentPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + y)
                        }
                        path.addLine(to: currentPoint)
                        values.removeAll()
                    case "Z", "z":
                        path.closeSubpath()
                        currentPoint = startPoint
                    default:
                        break
                    }
                    values.removeAll()
                }
                command = Character(str)
            }
        }
        return path
    }
    
    func calculateBoundingBox() -> CGRect {
        var minX: CGFloat = CGFloat.greatestFiniteMagnitude
        var minY: CGFloat = CGFloat.greatestFiniteMagnitude
        var maxX: CGFloat = -CGFloat.greatestFiniteMagnitude
        var maxY: CGFloat = -CGFloat.greatestFiniteMagnitude
        
        for path in pathsWithIds.values {
            path.forEach { element in
                switch element {
                case .move(to: let point), .line(to: let point), .quadCurve(to: let point, control: _), .curve(to: let point, control1: _, control2: _):
                    minX = min(minX, point.x)
                    minY = min(minY, point.y)
                    maxX = max(maxX, point.x)
                    maxY = max(maxY, point.y)
                default:
                    break
                }
            }
        }
        
        return CGRect(x: minX - 5, y: minY - 5, width: maxX - minX + 10, height: maxY - minY + 10)
    }
}
