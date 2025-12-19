SwiftUI code for the iPad client.

## Structure

```
iPadOS-Swiftui/
  App/
  Models/
  Services/
  Utilities/
  ViewModels/
  Views/
```

## Configure endpoints

Open **Settings** in the app to set the OCR backend URL.

Defaults live in `iPadOS-Swiftui/Utilities/AppConfig.swift`:

```
static let defaultOCRBaseURL = "http://<backend-ip>:8000"
static let obsidianBaseURL = URL(string: "http://<desktop-ip>:27123")!
```

## Notes

- Uses `PKCanvasView` with `.anyInput` and a vector eraser tool.
- Renders LaTeX via `WKWebView` + MathJax display mode.
- Error cards include retry; empty LaTeX is discarded.
