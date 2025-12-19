import SwiftUI

struct CanvasPanelView: View {
    @ObservedObject var controller: CanvasController

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Canvas")
                .font(.headline)
                .foregroundStyle(.primary)
            CanvasView(controller: controller)
                .frame(minHeight: 220, maxHeight: 260)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        }
    }
}
