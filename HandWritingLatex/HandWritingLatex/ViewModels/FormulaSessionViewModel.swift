import Foundation
import UIKit

@MainActor
final class FormulaSessionViewModel: ObservableObject {
    @Published private(set) var items: [FormulaItem] = []

    let canvasController: CanvasController

    init(canvasController: CanvasController) {
        self.canvasController = canvasController
    }

    func recognizeCurrentDrawing() {
        guard canvasController.hasDrawing else { return }
        guard let image = canvasController.snapshotImage(),
              let pngData = image.pngData() else { return }

        let item = FormulaItem(
            id: UUID(),
            snapshot: image,
            timestamp: Date(),
            state: .processing
        )
        items.insert(item, at: 0)
        canvasController.clear()

        Task {
            await runOCR(for: item.id, pngData: pngData)
        }
    }

    func selectPen() {
        canvasController.setPen()
    }

    func selectEraser() {
        canvasController.setEraser()
    }

    func clearCanvas() {
        canvasController.clear()
    }

    func retry(item: FormulaItem) {
        updateItem(id: item.id, state: .processing)
        guard let pngData = item.snapshot.pngData() else { return }
        Task {
            await runOCR(for: item.id, pngData: pngData)
        }
    }

    func copy(item: FormulaItem) {
        guard case let .success(latex, _) = item.state else { return }
        UIPasteboard.general.string = latex
    }

    func sendToObsidian(item: FormulaItem) {
        guard case let .success(latex, _) = item.state else { return }
        Task {
            do {
                try await obsidianClient.insert(latex: latex)
            } catch {
                print("[Formula OCR] Obsidian insert failed: \(error)")
            }
        }
    }

    private func runOCR(for id: UUID, pngData: Data) async {
        do {
            let result = try await ocrClient.recognize(pngData: pngData)
            let trimmed = result.latex.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                removeItem(id: id)
                return
            }
            updateItem(id: id, state: .success(latex: trimmed, engine: result.engine))
        } catch {
            let message = errorMessage(for: error)
            updateItem(id: id, state: .failure(message: message))
        }
    }

    private func updateItem(id: UUID, state: FormulaState) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].state = state
    }

    private func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    private func errorMessage(for error: Error) -> String {
        if error is URLError {
            return "Network error. Tap retry."
        }
        if case OCRClientError.serverError = error {
            return "OCR failed. Tap retry."
        }
        return "OCR failed. Tap retry."
    }

    private var ocrClient: OCRClient {
        OCRClient(baseURL: AppConfig.ocrBaseURL)
    }

    private var obsidianClient: ObsidianClient {
        ObsidianClient(baseURL: AppConfig.obsidianBaseURL)
    }
}
