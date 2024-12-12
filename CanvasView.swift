import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var color: Color
    @Binding var isDrawing: Bool
    @Binding var pencilType: PKInkingTool.InkType
    @Binding var backgroundColor: Color
    @Binding var toolOpacity: Double
    @Binding var toolLineWidth: CGFloat
    
    var ink: PKInkingTool {
        let drawingColor: UIColor
        if color == .black {
            drawingColor = UIColor.black.withAlphaComponent(CGFloat(toolOpacity))
        } else {
            drawingColor = UIColor(color).withAlphaComponent(CGFloat(toolOpacity))
        }
        return PKInkingTool(pencilType, color: drawingColor, width: toolLineWidth)
    }
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDrawing ? ink : eraser
        canvas.isRulerActive = false
        canvas.backgroundColor = UIColor(backgroundColor)
        canvas.alwaysBounceVertical = true
        canvas.isScrollEnabled = true
        canvas.drawing = PKDrawing()
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = isDrawing ? ink : eraser
        uiView.backgroundColor = UIColor(backgroundColor)
    }
}
