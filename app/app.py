import os
from uuid import uuid4

from flask import Flask, render_template, request
from ultralytics import YOLO

UPLOAD_FOLDER = "static/uploads"
MODEL_NAME = "yolo11n-seg.pt"

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

model = YOLO(MODEL_NAME)


@app.route("/", methods=["GET", "POST"])
def index():
    result_image = None
    uploaded_image = None

    if request.method == "POST":
        file = request.files.get("image")

        if file and file.filename:
            ext = file.filename.rsplit(".", 1)[-1].lower()
            filename = f"{uuid4()}.{ext}"
            input_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)
            file.save(input_path)

            results = model(input_path)
            annotated = results[0].plot()

            output_filename = f"result_{filename}"
            output_path = os.path.join(app.config["UPLOAD_FOLDER"], output_filename)

            import cv2
            cv2.imwrite(output_path, annotated)

            uploaded_image = input_path
            result_image = output_path

    return render_template(
        "index.html",
        uploaded_image=uploaded_image,
        result_image=result_image,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)