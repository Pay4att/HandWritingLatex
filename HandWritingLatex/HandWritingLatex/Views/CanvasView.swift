import PencilKit
import SwiftUI
import UIKit

struct CanvasView: UIViewRepresentable {
    @ObservedObject var controller: CanvasController

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = controller.canvasView
        DispatchQueue.main.async {
            configureToolPicker(for: canvasView)
        }
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}

private func configureToolPicker(for canvasView: PKCanvasView) {
    guard let window = canvasView.window ?? keyWindow() else { return }
    let toolPicker = PKToolPicker.shared(for: window)
    toolPicker?.setVisible(true, forFirstResponder: canvasView)
    toolPicker?.addObserver(canvasView)
    canvasView.becomeFirstResponder()
}

private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
}
