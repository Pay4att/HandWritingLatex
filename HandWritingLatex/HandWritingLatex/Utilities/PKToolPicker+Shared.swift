import PencilKit
import UIKit

extension PKToolPicker {
    static var sharedSelectedTool: PKTool {
        get {
            guard let window = keyWindow(),
                  let picker = PKToolPicker.shared(for: window) else {
                return PKInkingTool(.pen, color: .black, width: 5)
            }
            return picker.selectedTool
        }
        set {
            guard let window = keyWindow() else { return }
            PKToolPicker.shared(for: window)?.selectedTool = newValue
        }
    }
}

private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
}
