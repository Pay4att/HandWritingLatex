# OCR Backend (FastAPI)

Minimal OCR service for handwritten formulas.

## Install

```
pip install paddlepaddle-gpu==3.2.0 -i https://www.paddlepaddle.org.cn/packages/stable/cu118/
pip install "paddleocr[all]"
pip install fastapi
pip install uvicorn
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
