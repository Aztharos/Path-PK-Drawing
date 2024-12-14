import SwiftUI
import PencilKit

struct UnifiedToolPopover: View {
    @Binding var drawingTool: DrawingTool
    @Binding var selectedShape: String
    @Binding var isDrawingPath: Bool
    @Binding var pencilType: PKInkingTool.InkType
    @Binding var isDrawing: Bool
    @Binding var selectedTool: String?
    
    let pathTools: [(type: DrawingTool.ToolType, icon: String, shape: String)] = [
        (.crayon, "pencil.line", "crayon"),
        (.rectangle, "rectangle", "rectangle"),
        (.ellipse, "circle", "ellipse"),
        (.line, "line.diagonal", "line")
    ]
    
    let pkTools: [(type: PKInkingTool.InkType, icon: String)] = [
        (.marker, "paintbrush.pointed"),
        (.pencil, "pencil"),
        (.pen, "pencil.tip"),
        (.monoline, "pencil.line"),
        (.fountainPen, "paintbrush.pointed.fill"),
        (.watercolor, "eyedropper.halffull"),
        (.crayon, "paintbrush")
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            // Section for Path Tools
            VStack {
                Text("Path Tools")
                    .font(.headline)
                
                ForEach(pathTools, id: \.shape) { tool in
                    StyledButton(systemImage: tool.icon) {
                        updateTool(tool.type, shape: tool.shape)
                    }
                    .shadow(color: isSelected(tool.shape) ? .green : .red, radius: 5, x: 0, y: 0)
                    .overlay(
                        isSelected(tool.shape) ? RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2) : nil
                    )
                }
            }
            
            Divider().padding(.vertical)
            
            // Section for PencilKit Tools
            VStack {
                Text("PencilKit Tools")
                    .font(.headline)
                
                ForEach(pkTools, id: \.type) { tool in
                    StyledButton(systemImage: tool.icon) {
                        updatePKTool(isDrawing: true, type: tool.type)
                    }
                    .shadow(color: isSelected(tool.type.rawValue) ? .blue : .red, radius: 5, x: 0, y: 0) 
                    .overlay(
                        isSelected(tool.type.rawValue) ? RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2) : nil
                    )
                }
            }
            EraserTool(
                isDrawingPath: $isDrawingPath,
                isDrawing: $isDrawing,
                selectedTool: $selectedTool
            )
            
        }
        .padding()
    }
    
    // Helper function to check if the tool is selected
    private func isSelected(_ toolName: String) -> Bool {
      return selectedTool == toolName
    }
    
    // Update functions
    private func updateTool(_ type: DrawingTool.ToolType, shape: String) {
        isDrawing = true
        isDrawingPath = true
        drawingTool.type = type
        selectedShape = shape
        selectedTool = shape // Mettre à jour l'outil sélectionné
    }
    
    private func updatePKTool(isDrawing: Bool, type: PKInkingTool.InkType) {
        self.isDrawing = isDrawing
        isDrawingPath = false
        pencilType = type
        selectedTool = type.rawValue // Mettre à jour l'outil sélectionné
    }
}
