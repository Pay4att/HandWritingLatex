import SwiftUI

struct ContentView: View {
    @StateObject private var canvasController: CanvasController
    @StateObject private var viewModel: FormulaSessionViewModel
    @State private var activeSheet: ActiveSheet?

    init() {
        let controller = CanvasController()
        _canvasController = StateObject(wrappedValue: controller)
        _viewModel = StateObject(wrappedValue: FormulaSessionViewModel(canvasController: controller))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CanvasView(controller: canvasController)
                    .background(Color.white)
                    .ignoresSafeArea()
            }
            .navigationTitle("Formula OCR")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeSheet = .settings }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { activeSheet = .formulas }) {
                        Image(systemName: "list.bullet")
                    }

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
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .settings:
                    SettingsView()
                case .formulas:
                    FormulaSheetView(
                        items: viewModel.items,
                        onCopy: viewModel.copy,
                        onSend: viewModel.sendToObsidian,
                        onRetry: viewModel.retry
                    )
                }
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            Button(action: recognizeAndShowResults) {
                Label("Recognize", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canvasController.hasDrawing)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGroupedBackground).opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func recognizeAndShowResults() {
        let shouldOpen = canvasController.hasDrawing
        viewModel.recognizeCurrentDrawing()
        if shouldOpen {
            activeSheet = .formulas
        }
    }
}

private enum ActiveSheet: Identifiable {
    case settings
    case formulas

    var id: Int {
        switch self {
        case .settings:
            return 0
        case .formulas:
            return 1
        }
    }
}

private struct FormulaSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let items: [FormulaItem]
    let onCopy: (FormulaItem) -> Void
    let onSend: (FormulaItem) -> Void
    let onRetry: (FormulaItem) -> Void

    var body: some View {
        NavigationStack {
            FormulaListView(
                items: items,
                onCopy: onCopy,
                onSend: onSend,
                onRetry: onRetry,
                showsTitle: false
            )
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Formulas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
