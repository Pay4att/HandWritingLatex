import SwiftUI

struct FormulaCardView: View {
    let item: FormulaItem
    let onCopy: () -> Void
    let onSend: () -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(uiImage: item.snapshot)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text(item.timestamp, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    switch item.state {
                    case .processing:
                        Text("Recognizing...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    case let .success(latex, _):
                        LatexWebView(latex: latex)
                            .frame(height: 90)
                    case let .failure(message):
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }

            switch item.state {
            case .success:
                HStack(spacing: 12) {
                    Button(action: onCopy) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button(action: onSend) {
                        Label("Send", systemImage: "paperplane")
                    }
                }
                .labelStyle(.titleAndIcon)
                .font(.subheadline)
            case .failure:
                Button(action: onRetry) {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .font(.subheadline)
            case .processing:
                EmptyView()
            }
        }
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private var cardBackground: Color {
        switch item.state {
        case .failure:
            return Color(red: 1.0, green: 0.97, blue: 0.97)
        default:
            return Color(.systemBackground)
        }
    }
}
