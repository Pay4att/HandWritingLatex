import SwiftUI

struct FormulaCardView: View {
    let item: FormulaItem
    let onCopy: () -> Void
    let onSend: () -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Status/Latex only (No Image)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.timestamp, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                switch item.state {
                case .processing:
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Recognizing...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                case let .success(latex, _):
                    LatexWebView(latex: latex)
                        .frame(minHeight: 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                case let .failure(message):
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.vertical, 4)
                }
            }

            // Actions
            if case .success = item.state {
                HStack {
                    Button(action: onCopy) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Button(action: onSend) {
                        Label("Insert", systemImage: "arrow.down.to.line")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .controlSize(.small)
                }
                .padding(.top, 4)
            } else if case .failure = item.state {
                Button(action: onRetry) {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
                .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
