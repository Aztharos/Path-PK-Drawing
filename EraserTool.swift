import SwiftUI

struct EraserTool: View {
    @Binding var isDrawingPath: Bool
    @Binding var isDrawing: Bool
    @Binding var selectedTool: String?
    
    var body: some View {
        StyledButton(systemImage: "eraser.line.dashed") {
            activateEraser()
        }
        .shadow(color: selectedTool == "eraser" ? .blue : .red, radius: 5, x: 0, y: 0)
        .overlay(
            selectedTool == "eraser" ? RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2) : nil
        )
    }
    
    // Activer la gomme
    private func activateEraser() {
        isDrawingPath = false
        isDrawing = false
        selectedTool = "eraser"
        
    }
}

