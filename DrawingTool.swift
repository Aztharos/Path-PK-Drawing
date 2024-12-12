import SwiftUI

class DrawingTool {
    enum ToolType {
        case crayon, rectangle, ellipse, line
    }   
    var type: ToolType = .crayon
    var startPoint: CGPoint?
    var currentPath = Path()
    func updatePath(from startPoint: CGPoint?, to newPoint: CGPoint) -> Path {
        guard let startPoint = startPoint else {
            return Path()
        }
        var path = Path()
        switch type {
        case .crayon:
            if currentPath.isEmpty {
                path.move(to: newPoint)
            } else {
                path = currentPath
                path.addLine(to: newPoint)
            }
        case .rectangle:
            let rect = CGRect(x: min(startPoint.x, newPoint.x),
                              y: min(startPoint.y, newPoint.y),
                              width: abs(newPoint.x - startPoint.x),
                              height: abs(newPoint.y - startPoint.y))
            path.addRect(rect)
        case .ellipse:
            let ellipse = CGRect(x: min(startPoint.x, newPoint.x),
                                 y: min(startPoint.y, newPoint.y),
                                 width: abs(newPoint.x - startPoint.x),
                                 height: abs(newPoint.y - startPoint.y))
            path.addEllipse(in: ellipse)
        case .line:
            path.move(to: startPoint)
            path.addLine(to: newPoint)
        }
        return path
    }
}
