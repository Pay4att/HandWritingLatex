import SwiftUI

struct FormulaListView: View {
    let items: [FormulaItem]
    let onCopy: (FormulaItem) -> Void
    let onSend: (FormulaItem) -> Void
    let onRetry: (FormulaItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Formulas")
                .font(.headline)
                .foregroundStyle(.primary)

            if items.isEmpty {
                Text("No formulas yet.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items) { item in
                            FormulaCardView(
                                item: item,
                                onCopy: { onCopy(item) },
                                onSend: { onSend(item) },
                                onRetry: { onRetry(item) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
