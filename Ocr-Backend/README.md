# OCR Backend (FastAPI)

Minimal OCR service for handwritten formulas.

## Install

```
pip install -r requirements.txt
```

## Run

```
uvicorn main:app --host 0.0.0.0 --port 8000
```

## API

```
POST /ocr/formula
Content-Type: image/png
```

Response:

```json
{"latex":"...","engine":"paddle"}
```

Notes:
- Paddle FormulaNet is the only engine.
- Empty LaTeX returns an empty string (no error).
