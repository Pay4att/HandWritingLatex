import PencilKit
import UIKit

final class CanvasController: NSObject, ObservableObject, PKCanvasViewDelegate {
    let canvasView: PKCanvasView

    @Published private(set) var hasDrawing: Bool = false
    @Published private(set) var activeTool: CanvasTool = .pen

    override init() {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        self.canvasView = canvasView
        super.init()
        canvasView.delegate = self
        setPen()
    }

    func setPen() {
        let tool = PKInkingTool(.pen, color: .black, width: 6)
        canvasView.tool = tool
        PKToolPicker.sharedSelectedTool = tool
        activeTool = .pen
    }

    func setEraser() {
        let tool = PKEraserTool(.vector)
        canvasView.tool = tool
        PKToolPicker.sharedSelectedTool = PKEraserTool(.vector)
        activeTool = .eraser
    }

    func clear() {
        canvasView.drawing = PKDrawing()
        hasDrawing = false
    }

    func snapshotImage() -> UIImage? {
        let bounds = canvasView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        let scale = UIScreen.main.scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(bounds)
            let drawingImage = canvasView.drawing.image(from: bounds, scale: scale)
            drawingImage.draw(in: bounds)
        }
    }

    func snapshotPNGData() -> Data? {
        snapshotImage()?.pngData()
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasDrawing = !canvasView.drawing.strokes.isEmpty
    }
}
