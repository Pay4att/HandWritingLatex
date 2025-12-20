import SwiftUI

struct ContentView: View {
    @StateObject private var canvasController: CanvasController
    @StateObject private var viewModel: FormulaSessionViewModel
    @State private var isSettingsPresented = false
    @State private var isHistoryPresented = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init() {
        let controller = CanvasController()
        _canvasController = StateObject(wrappedValue: controller)
        _viewModel = StateObject(wrappedValue: FormulaSessionViewModel(canvasController: controller))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main Layout
                if horizontalSizeClass == .compact {
                    // iPhone Layout: Full screen canvas
                    CanvasView(controller: canvasController)
                        .background(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // iPad Layout: Split view
                    HStack(spacing: 0) {
                        CanvasView(controller: canvasController)
                            .background(Color.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Divider()
                        
                        FormulaSidePanelView(
                            items: viewModel.items,
                            onCopy: viewModel.copy,
                            onSend: viewModel.sendToObsidian,
                            onRetry: viewModel.retry
                        )
                        .frame(width: 360)
                    }
                }
                
                // Floating Toolbar
                if horizontalSizeClass == .compact {
                    FloatingToolBar(
                        controller: canvasController,
                        viewModel: viewModel,
                        isHistoryPresented: $isHistoryPresented,
                        showHistoryButton: true
                    )
                    .padding(.bottom, 20)
                } else {
                    // For iPad, position the toolbar centered in the canvas area
                    HStack {
                        Spacer()
                        FloatingToolBar(
                            controller: canvasController,
                            viewModel: viewModel,
                            isHistoryPresented: $isHistoryPresented,
                            showHistoryButton: false
                        )
                        .padding(.bottom, 20)
                        Spacer()
                        // Add spacer to offset the sidebar width so toolbar is centered on canvas
                        Spacer().frame(width: 360)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isSettingsPresented = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .sheet(isPresented: $isHistoryPresented) {
                NavigationStack {
                    FormulaListView(
                        items: viewModel.items,
                        onCopy: viewModel.copy,
                        onSend: viewModel.sendToObsidian,
                        onRetry: viewModel.retry,
                        showsTitle: false
                    )
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    .navigationTitle("History")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { isHistoryPresented = false }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct FormulaSidePanelView: View {
    let items: [FormulaItem]
    let onCopy: (FormulaItem) -> Void
    let onSend: (FormulaItem) -> Void
    let onRetry: (FormulaItem) -> Void

    var body: some View {
        FormulaListView(
            items: items,
            onCopy: onCopy,
            onSend: onSend,
            onRetry: onRetry
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }
}
