# AGENTS.md

## Project Name
Formula OCR Pipeline (iPad → OCR Backend → Obsidian)

---

## 1. Goal

Build a clean, reliable, AI-assisted system for converting handwritten or captured mathematical formulas into LaTeX and inserting them into Obsidian notes.

Core principles:
- Minimal code
- Clear module boundaries
- Native Apple Pencil experience
- OCR correctness over novelty

---

## 2. System Architecture

```

iPadOS SwiftUI App
→ HTTP (image/png)
OCR Backend (FastAPI)
→ LaTeX
iPadOS SwiftUI App
→ HTTP (LaTeX)
Obsidian Plugin

````

Each layer must be independently testable.

---

## 3. Agents Responsibilities

### 3.1 iPadOS SwiftUI Agent

**Primary responsibility:**  
Input, preview, and user interaction.

**Must support:**
- Apple Pencil handwriting via PencilKit
- Multiple formulas per session
- Eraser tool
- Formula list view
- Clean LaTeX rendering

**Must NOT:**
- Run OCR models
- Perform heavy computation
- Depend on web handwriting

---

### 3.2 OCR Backend Agent

**Primary responsibility:**  
Convert images to LaTeX deterministically.

**Rules:**
- Accept raw images via HTTP
- Return plain LaTeX strings
- No UI logic
- No state

**Preferred engines (in order):**
1. Paddle FormulaNet
2. pix2tex (fallback)

---

### 3.3 Obsidian Plugin Agent

**Primary responsibility:**  
Insert LaTeX into the active note.

**Rules:**
- Local-only communication (localhost)
- No OCR
- No rendering
- No UI complexity

---

## 4. iPad SwiftUI UI & UX Requirements

### 4.1 Canvas (PencilKit)

- Use `PKCanvasView`
- Enable `.anyInput`
- Support:
  - Pen
  - Eraser
  - Clear canvas
- No custom stroke engine

Eraser is **mandatory** and must use:
```swift
PKToolPicker.sharedSelectedTool = PKEraserTool(.vector)
````

---

### 4.2 Formula Management

* Each OCR result is a **FormulaItem**
* FormulaItem contains:

  * Image snapshot
  * LaTeX string
  * Timestamp

The UI must support:

* Multiple formulas per page
* Scrollable formula list
* Tap to copy
* Tap to send to Obsidian

---

### 4.3 Visual Style

**Mandatory:**

* SwiftUI only
* Light, neutral background
* Rounded cards
* No heavy shadows
* Clear hierarchy

**Preferred components:**

* `ScrollView`
* `LazyVStack`
* `Card-style View`
* `Toolbar`

---

### 4.4 LaTeX Rendering

* Use `WKWebView`
* MathJax only
* Display math (`$$...$$`)
* No editing inside WebView

---

## 5. Networking Rules

### 5.1 OCR Request

```
POST /ocr/formula
Content-Type: image/png
```

Response:

```json
{
  "latex": "...",
  "engine": "paddle"
}
```

---

### 5.2 Obsidian Insert Request

```
POST http://localhost:27123/insert
```

Body:

```json
{
  "latex": "..."
}
```

---

## 6. Code Style Rules

### Swift / SwiftUI

* Prefer value types
* No massive view files
* One responsibility per view
* Avoid custom gesture recognizers

### Python

* FastAPI only
* No global state
* One file per OCR engine

### TypeScript (Obsidian)

* Minimal plugin lifecycle
* No framework dependencies
* Direct editor insertion

---

## 7. Error Handling

* OCR failure → show error card
* Network failure → retry button
* Empty LaTeX → discard silently

No blocking UI.

---

## 8. Non-Goals

Explicitly excluded:

* Web-based handwriting
* On-device OCR on iPad
* Real-time stroke recognition
* Cloud dependency

---

## 9. Definition of Done

The system is complete when:

* iPad supports writing, erasing, clearing
* Multiple formulas can be captured in one session
* OCR returns correct LaTeX
* LaTeX renders correctly on iPad
* One tap inserts formula into Obsidian
* No manual copy-paste required

---

## 10. Design Philosophy

> Prefer boring, correct systems over clever ones.

If a component is unstable, isolate it.
If a model hallucinates, replace it.
If the UI distracts, simplify it.

Correct LaTeX > fancy AI.

```