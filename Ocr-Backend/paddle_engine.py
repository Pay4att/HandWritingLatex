from __future__ import annotations

from typing import Any, Optional


class PaddleFormulaNetEngine:
    def __init__(self, model_name: str = "PP-FormulaNet_plus-L") -> None:
        self._model_name = model_name
        self._model = None

    def _get_model(self):
        if self._model is None:
            from paddleocr import FormulaRecognition

            self._model = FormulaRecognition(model_name=self._model_name)
        return self._model

    def recognize(self, image_path: str) -> Optional[str]:
        model = self._get_model()
        output = model.predict(input=image_path, batch_size=1)
        return _extract_latex(output)


def _extract_latex(output: Any) -> Optional[str]:
    if not output:
        return None

    first = output[0]
    if isinstance(first, str):
        return first.strip() or None
    if isinstance(first, dict):
        for key in ("text", "latex", "result", "rec_formula"):
            value = first.get(key)
            if value:
                return str(value).strip()

    for attr in ("text", "latex", "result", "rec_formula"):
        value = getattr(first, attr, None)
        if value:
            return str(value).strip()

    return None
