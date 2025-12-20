import SwiftUI
import WebKit

struct LatexWebView: UIViewRepresentable {
    let latex: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let sanitized = sanitizeLatex(latex)
        guard context.coordinator.lastLatex != sanitized else { return }
        context.coordinator.lastLatex = sanitized
        webView.loadHTMLString(html(for: sanitized), baseURL: nil)
    }
}

extension LatexWebView {
    final class Coordinator {
        var lastLatex: String = ""
    }
}

private func html(for latex: String) -> String {
    let wrapped = wrapDisplayMath(latex)
    return """
    <!doctype html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { margin: 0; padding: 0; background: transparent; font-family: -apple-system; }
          #math { font-size: 20px; }
        </style>
        <script>
          window.MathJax = { tex: { displayMath: [['$$','$$']] } };
        </script>
        <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js"></script>
      </head>
      <body>
        <div id="math">\(wrapped)</div>
      </body>
    </html>
    """
}

private func wrapDisplayMath(_ latex: String) -> String {
    let trimmed = latex.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("$") && trimmed.hasSuffix("$") {
        return trimmed
    }
    return "$$" + trimmed + "$$"
}

private func sanitizeLatex(_ latex: String) -> String {
    latex
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}
