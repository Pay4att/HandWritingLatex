import SwiftUI

struct FormulaListView: View {
    let items: [FormulaItem]
    let onCopy: (FormulaItem) -> Void
    let onSend: (FormulaItem) -> Void
    let onRetry: (FormulaItem) -> Void
    var showsTitle: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !items.isEmpty {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
