# Formula OCR Insert (Obsidian)

Desktop-only Obsidian plugin that listens on localhost and inserts LaTeX into the active note.

## Local HTTP API

```
POST http://127.0.0.1:27123/insert
Content-Type: application/json

{"latex":"\\frac{a}{b}"}
```

If the payload is not already wrapped in `$...$` or `$$...$$`, the plugin wraps it as display math (`$$...$$`).

## Development

```
npm install
npm run dev
```

## Manual install

Copy `main.js`, `manifest.json`, and `styles.css` to:

```
<Vault>/.obsidian/plugins/formula-ocr-insert/
```
