
 //Path & PK Drawing

import SwiftUI
import PencilKit

enum DrawingMode {
    case path
    case pencilKit
}
struct DrawingView: View {
    @State private var currentPath = Path()
    @State private var paths: [(path: Path, color: Color, lineWidth: CGFloat)] = []
    @State private var color: Color = .black
    @State private var lineWidth: CGFloat = 2
    @State private var opacity: Double = 1.0
    @State private var canvas = PKCanvasView()
    @State private var isDrawingPath = true
    @State private var previousPoint: CGPoint?
    @State private var isPencilEffectEnabled: Bool = false
    @State private var isDrawing = true
    @State private var pencilType: PKInkingTool.InkType = .pencil
    @State private var drawingMode: DrawingMode = .path
    @State private var selectedShape: String = "crayon"
    @State private var drawingTool = DrawingTool()
    @State private var backgroundColor: Color = .white
    @State private var pathUndoStack: [(path: Path, color: Color, lineWidth: CGFloat)] = []
    @State private var pathRedoStack: [(path: Path, color: Color, lineWidth: CGFloat)] = []
    @State private var isPKPopover: Bool = false
    @State private var isPathPopover: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                CanvasView(canvas: $canvas, color: $color, isDrawing: $isDrawing, pencilType: $pencilType, backgroundColor: $backgroundColor, toolOpacity: $opacity, toolLineWidth: $lineWidth)
                   .environment(\.colorScheme, .light)  //colorpicker PK
                Canvas { context, size in
                    for (path, pathColor, pathLineWidth) in paths {
                        context.stroke(path, with: .color(pathColor), lineWidth: pathLineWidth)
                    }
                    context.stroke(currentPath, with: .color(color.opacity(opacity)), lineWidth: lineWidth)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if isDrawingPath {
                                if drawingTool.startPoint == nil {
                                    drawingTool.startPoint = value.location
                                }
                                switch drawingTool.type {
                                case .crayon:
                                    if currentPath.isEmpty {
                                        currentPath.move(to: value.location)
                                    } else {
                                        currentPath.addLine(to: value.location)
                                    }
                                case .rectangle, .ellipse, .line:
                                    currentPath = drawingTool.updatePath(from: drawingTool.startPoint, to: value.location)
                                }
                                if isPencilEffectEnabled {
                                    if let previousPoint = previousPoint {
                                        let distance = hypot(value.location.x - previousPoint.x, value.location.y - previousPoint.y)
                                        lineWidth = max(1, min(40, distance / 2))
                                        opacity = max(0.1, min(1.0, 1 - distance / 200))
                                    }
                                }
                                previousPoint = value.location
                            }
                        }
                        .onEnded { _ in
                            if isDrawingPath {
                                paths.append((path: currentPath, color: color.opacity(opacity), lineWidth: lineWidth))
                                pathRedoStack.removeAll()
                                currentPath = Path()
                                drawingTool.startPoint = nil
                            }
                            previousPoint = nil
                        }
                )
                .allowsHitTesting(isDrawingPath)
                .background(Color.clear)
            }
            VStack(spacing: 10) {
                HStack {
                
                        StyledButton(systemImage: "scribble") {
                            isDrawingPath = true
                        }
                        .shadow(color: isDrawingPath ? Color.green : Color.red, radius: 5, x: 1, y: -3)
                        StyledButton(systemImage: isPencilEffectEnabled ? "pencil.slash" : "pencil") {
                            isPencilEffectEnabled.toggle()
                        }
                        .shadow(color: isDrawingPath ? Color.green : Color.red, radius: 5, x: 1, y: -3)
                    
                    //Menu Popover Path
                    StyledButton(systemImage: "list.triangle") {
                        isPathPopover.toggle()
                    }
                    
                    .shadow(color: isDrawingPath ? Color.green : Color.red, radius: 5, x: 1, y: -3)
                    .popover(isPresented: $isPathPopover,
                             attachmentAnchor: .rect(.bounds),
                             arrowEdge: .top
                    ) {
                        
                        VStack(spacing: 15) {
                            StyledButton(systemImage: "pencil.line") {
                                drawingTool.type = .crayon
                                selectedShape = "crayon"
                            }
                            StyledButton(systemImage: "rectangle") {
                                drawingTool.type = .rectangle
                                selectedShape = "rectangle"
                            }
                            StyledButton(systemImage: "circle") {
                                drawingTool.type = .ellipse
                                selectedShape = "ellipse"
                            }
                            StyledButton(systemImage: "line.diagonal") {
                                drawingTool.type = .line
                                selectedShape = "line"
                            }
                        }//vstack
                        .padding()
                        .shadow(color: isDrawingPath ? Color.green : Color.red, radius: 5, x: 1, y: -3)
                    }//popover
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.gray)
                            ColorPicker("", selection: $backgroundColor)
                                .labelsHidden()
                        }
                        .padding()
                        .background(
                            BlurBackground()
                        )
                        HStack {
                            Image(systemName: "pencil.tip")
                                .foregroundColor(.gray)
                            ColorPicker("", selection: $color)
                                .labelsHidden()
                        }
                        .padding()
                        .background(
                            BlurBackground()
                        )
                    
                        HStack {
                            Image(systemName: "eye")
                                .foregroundColor(.gray)
                                Slider(value: $opacity, in: 0.0...1.0, step: 0.05) {
                            }
                        }
                     .frame(minWidth: 100, maxWidth: 200)
                        .padding()
                        .background(
                            BlurBackground()
                        )
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundColor(.gray)
                            Slider(value: $lineWidth, in: 1...60, step: 2) {
                            }
                        }
                        .frame(minWidth: 100, maxWidth: 200)
                        .padding()
                        .background(
                            BlurBackground()
                        )
                    
                    //Menu Popover PK
                    StyledButton(systemImage: "list.triangle") {
                        isPKPopover.toggle()
                    }
                    .shadow(color: !isDrawingPath ? Color.blue : Color.red, radius: 5, x: 1, y: -3)
                    .popover(isPresented: $isPKPopover,
                             attachmentAnchor: .rect(.bounds),
                             arrowEdge: .top
                    ) {
                        VStack(spacing: 15) {
                            StyledButton(systemImage: "eraser.line.dashed") {
                                isDrawing = false
                            }
                            StyledButton(systemImage: "paintbrush.pointed") {
                                isDrawing = true
                                pencilType = .marker
                            }
                            StyledButton(systemImage: "pencil") {
                                isDrawing = true
                                pencilType = .pencil
                            }
                            StyledButton(systemImage: "pencil.tip") {
                                isDrawing = true
                                pencilType = .pen
                            }
                            StyledButton(systemImage: "pencil.line") {
                                isDrawing = true
                                pencilType = .monoline
                            }
                            StyledButton(systemImage: "paintbrush.pointed.fill") {
                                isDrawing = true
                                pencilType = .fountainPen
                            }
                            StyledButton(systemImage: "eyedropper.halffull") {
                                isDrawing = true
                                pencilType = .watercolor
                            }
                            StyledButton(systemImage: "paintbrush") {
                                isDrawing = true
                                pencilType = .crayon
                            }
                        }//vstack
                        .padding()
                        .shadow(color: !isDrawingPath ? Color.green : Color.red, radius: 5, x: 1, y: -3)
                    }//popover
                    StyledButton(systemImage: "pencil.and.ruler.fill") {
                        canvas.isRulerActive.toggle()
                    }
                    .shadow(color: !isDrawingPath ? Color.blue : Color.red, radius: 5, x: 1, y: -3)
                    StyledButton(systemImage: "pencil.circle") {
                        isDrawingPath = false
                    }
                    .shadow(color: !isDrawingPath ? Color.blue : Color.red, radius: 5, x: 1, y: -3)
                }
                .padding(.horizontal)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              HStack {
                        StyledButton(systemImage: "arrow.uturn.backward", action: performUndo)
                        StyledButton(systemImage: "arrow.uturn.forward", action: performRedo)
                        StyledButton(systemImage: "trash", action: performClear)
  }//HStack
                    .shadow(color: isDrawingPath ? Color.green : Color.blue, radius: 5, x: 1, y: -3)
            }//toolbaritem
        }//toolbar
    }//body
}//drawingview


extension DrawingView {
    func performUndo() {
        if isDrawingPath {
            if !paths.isEmpty {
                let lastPath = paths.removeLast()
                pathUndoStack.append(lastPath)
            }
        } else {
            canvas.undoManager?.undo()
        }
    }
    func performRedo() {
        if isDrawingPath {
            if !pathUndoStack.isEmpty {
                let restoredPath = pathUndoStack.removeLast()
                paths.append(restoredPath)
            }
        } else {
            canvas.undoManager?.redo()
        }
    }
    func performClear() {
        if isDrawingPath {
            paths.removeAll()
            pathUndoStack.removeAll()
            pathRedoStack.removeAll()
        } else {
            canvas.drawing = PKDrawing()
        }
    }
}


