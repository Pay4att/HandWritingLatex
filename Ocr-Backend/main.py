from __future__ import annotations

import os
import tempfile
from typing import Optional

from fastapi import FastAPI, HTTPException, Request

from paddle_engine import PaddleFormulaNetEngine


def create_app() -> FastAPI:
    app = FastAPI()
    paddle_engine = PaddleFormulaNetEngine()

    @app.post("/ocr/formula")
    async def ocr_formula(request: Request) -> dict:
        content_type = request.headers.get("content-type", "")
        if "image/png" not in content_type:
            raise HTTPException(status_code=415, detail="Expected Content-Type image/png")

        image_bytes = await request.body()
        if not image_bytes:
            raise HTTPException(status_code=400, detail="Empty request body")

        try:
            latex = _run_engine(paddle_engine, image_bytes)
        except ImportError:
            raise HTTPException(status_code=500, detail="Paddle OCR unavailable")
        except Exception:
            raise HTTPException(status_code=500, detail="OCR failed")

        return {"latex": latex or "", "engine": "paddle"}

    return app


def _run_engine(engine: object, image_bytes: bytes) -> Optional[str]:
    temp_path = _write_temp_png(image_bytes)
    try:
        return engine.recognize(temp_path)
    finally:
        os.unlink(temp_path)


def _write_temp_png(image_bytes: bytes) -> str:
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as handle:
        handle.write(image_bytes)
        return handle.name


app = create_app()
