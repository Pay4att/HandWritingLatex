from paddleocr import FormulaRecognition
model = FormulaRecognition(model_name="PP-FormulaNet_plus-L")
output = model.predict(input="test.png", batch_size=1)
for res in output:
    res.print()
    res.save_to_img(save_path="./output/")
    res.save_to_json(save_path="./output/res.json")