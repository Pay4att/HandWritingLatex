import SwiftUI

struct ContentView: View {
    @StateObject private var canvasController: CanvasController
    @StateObject private var viewModel: FormulaSessionViewModel
    @State private var isSettingsPresented = false

    init() {
        let controller = CanvasController()
        _canvasController = StateObject(wrappedValue: controller)
        _viewModel = StateObject(wrappedValue: FormulaSessionViewModel(canvasController: controller))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                CanvasPanelView(controller: canvasController)

                Button(action: viewModel.recognizeCurrentDrawing) {
                    Label("Recognize", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canvasController.hasDrawing)

                FormulaListView(
                    items: viewModel.items,
                    onCopy: viewModel.copy,
                    onSend: viewModel.sendToObsidian,
                    onRetry: viewModel.retry
                )
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Formula OCR")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isSettingsPresented = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: viewModel.selectPen) {
                        Image(systemName: "pencil")
                    }
                    .foregroundStyle(canvasController.activeTool == .pen ? .primary : .secondary)

                    Button(action: viewModel.selectEraser) {
                        Image(systemName: "eraser")
                    }
                    .foregroundStyle(canvasController.activeTool == .eraser ? .primary : .secondary)

                    Button(action: viewModel.clearCanvas) {
                        Image(systemName: "trash")
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
        }
    }
}
