import SwiftUI

struct FloatingToolBar: View {
    @ObservedObject var controller: CanvasController
    @ObservedObject var viewModel: FormulaSessionViewModel
    @Binding var isHistoryPresented: Bool
    var showHistoryButton: Bool = true
    
    var body: some View {
        HStack(spacing: 20) {
            // Pen
            ToolButton(
                icon: "pencil",
                isSelected: controller.activeTool == .pen,
                action: viewModel.selectPen
            )
            
            // Eraser
            ToolButton(
                icon: "eraser",
                isSelected: controller.activeTool == .eraser,
                action: viewModel.selectEraser
            )

            Picker("Input Mode", selection: inputModeBinding) {
                Label("Pencil", systemImage: "pencil")
                    .tag(CanvasInputMode.pencilOnly)
                Label("Touch", systemImage: "hand.point.up.left")
                    .tag(CanvasInputMode.touchAndPencil)
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
            .accessibilityLabel("Input Mode")
            
            Divider()
                .frame(height: 20)
            
            // Clear
            ToolButton(
                icon: "trash",
                isSelected: false,
                action: viewModel.clearCanvas
            )
            
            // Recognize
            Button(action: viewModel.recognizeCurrentDrawing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(controller.hasDrawing ? Color.blue : Color.gray)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    )
            }
            .disabled(!controller.hasDrawing)
            
            // History
            if showHistoryButton {
                ToolButton(
                    icon: "clock",
                    isSelected: isHistoryPresented,
                    action: { isHistoryPresented.toggle() }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.bottom, 8)
    }

    private var inputModeBinding: Binding<CanvasInputMode> {
        Binding(
            get: { controller.inputMode },
            set: { controller.setInputMode($0) }
        )
    }
}

struct ToolButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .blue : .secondary)
                .frame(width: 40, height: 40)
                .background(
                    isSelected ? Color.blue.opacity(0.1) : Color.clear
                )
                .clipShape(Circle())
        }
    }
}
