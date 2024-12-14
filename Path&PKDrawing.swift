
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
    @State private var isToolPopoverVisible: Bool = false
    @State private var selectedTool: String? = nil

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
       }//zstack
            VStack(spacing: 10) {
                HStack {
                       HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.gray)
                            ColorPicker("", selection: $backgroundColor)
                                .labelsHidden()
                        }//hstack
                        .padding()
                        .background(
                            BlurBackground()
                        )
                        HStack {
                            Image(systemName: "pencil.tip")
                                .foregroundColor(.gray)
                            ColorPicker("", selection: $color)
                                .labelsHidden()
                        }//hstack
                        .padding()
                        .background(
                            BlurBackground()
                        )
                    
                        HStack {
                            Image(systemName: "eye")
                                .foregroundColor(.gray)
                                Slider(value: $opacity, in: 0.0...1.0, step: 0.05) {
                            }
                        }//hstack
                     .frame(minWidth: 100, maxWidth: 200)
                        .padding()
                        .background(
                            BlurBackground()
                        )
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundColor(.gray)
                            Slider(value: $lineWidth, in: 1...60, step: 1) {
                            }
                        }//hstack
                        .frame(minWidth: 100, maxWidth: 350)
                        .padding()
                        .background(
                            BlurBackground()
                        )
                    StyledButton(systemImage: isPencilEffectEnabled ? "scribble" : "pencil") {
                        isPencilEffectEnabled.toggle()
                    }
                    .shadow(color: isDrawingPath ? Color.green : Color.red, radius: 5, x: 1, y: -3)
                    
                    StyledButton(systemImage: "list.triangle") {
                        isToolPopoverVisible.toggle()
                    }
                    .shadow(color: isDrawingPath ? Color.green : Color.blue, radius: 5, x: 1, y: -3)
                    .popover(isPresented: $isToolPopoverVisible) {
                        UnifiedToolPopover(
                            drawingTool: $drawingTool,
                            selectedShape: $selectedShape,
                            isDrawingPath: $isDrawingPath,
                            pencilType: $pencilType,
                            isDrawing: $isDrawing, selectedTool: $selectedTool
                        )
                    }
                    StyledButton(systemImage: "pencil.and.ruler.fill") {
                        if isDrawingPath == false {
                            canvas.isRulerActive.toggle()
                        } else {
                            do {
                                canvas.isRulerActive = false
                            }
                        }
                    }
                    .shadow(color: !isDrawingPath ? Color.blue : Color.red, radius: 5, x: 1, y: -3)
                    
                    HStack {
                        StyledButton(systemImage: "arrow.uturn.backward", action: performUndo)
                        StyledButton(systemImage: "arrow.uturn.forward", action: performRedo)
                        StyledButton(systemImage: "trash", action: performClear)
                    }//HStack
                    .shadow(color: isDrawingPath ? Color.green : Color.blue, radius: 5, x: 1, y: -3)
                }//hstack
                .padding(.horizontal)
            }//vstack
        }//vstack
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
