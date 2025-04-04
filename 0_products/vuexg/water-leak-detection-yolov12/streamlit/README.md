# Water Leak Detection App

This Streamlit application uses YOLO (You Only Look Once) object detection models to identify objects in images and videos, focusing on a custom model trained for water leak detection.

Developed by [AHB.ai](https://www.ahb.ai).

![App Screenshot](assets/VueXG_Typography.png)

## Features

- **Image Detection:** Upload an image (JPG, JPEG, PNG) for object detection.  
- **Video Detection:** Upload a video (MP4, AVI, MOV, WEBM) for frame-by-frame object detection.  
- **Example Inputs:** Use provided example images for quick testing.  
- **Model Selection:** Choose between a custom water leak detection model and standard YOLOv12 models (nano to xlarge).  
- **Adjustable Settings:** Configure inference image size and confidence threshold via the sidebar.  
- **Real-time Preview:** View video processing progress and periodic frame previews.  
- **Save Processed Video:** Download the video with detection overlays after processing is complete.  
- **Clean UI:** User-friendly interface built with Streamlit.  
- **Customizable:** Easily update model paths and example images.

## Project Structure

```
streamlit/
├── app.py                # Main Streamlit application
├── assets/
│   └── logo.png          # Application logo (replace with your own)
├── models/               # Directory for models
│   └── best.pt           # Default custom model path
├── examples/             # Directory for example images
│   ├── example1.jpg
│   └── example2.jpg
├── output_videos/        # Default server-side save location (if enabled)
├── requirements.txt      # Python dependencies
└── README.md             # This documentation file
```

## Requirements

- **Python 3.11+**  
- Packages listed in `requirements.txt`:  
  - `streamlit`  
  - `opencv-python-headless`  
  - `numpy`  
  - `ultralytics`  
  - `Pillow`

## Setup

1. **Clone the Repository (or Download Files)**
   ```bash
   git clone https://github.com/AHB-ai/AHB-ai-vuexg-water-detection-yolov12.git
   cd your_project_directory
   ```
2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```
3. **Place Assets**
   - Put your logo file named `logo.png` inside the `assets/` directory.  
   - Place your custom YOLO model (e.g., `best.pt`) inside the `models/` directory.  
     - If your model name or location differs, update the `DEFAULT_CUSTOM_MODEL_PATH` constant in `app.py`.  
   - Place your example images (e.g., `example1.jpg`, `example2.jpg`) inside the `examples/` directory.  
     - Update the `EXAMPLE_IMAGES` dictionary in `app.py` if your filenames differ.

4. **Download Standard YOLO Models (If Needed)**
   - The `ultralytics` library will automatically download the standard YOLOv12 models (e.g., `yolov12n.pt`, `yolov12s.pt`, etc.) the first time they are selected, provided you have an internet connection.

## How to Run

1. Navigate to the project directory in your terminal.
2. Run the Streamlit application:
   ```bash
   streamlit run app.py
   ```
3. The application will open in your default web browser.

## Usage Guide

1. **Configure Settings (Sidebar)**
   - **Select Model:** Choose the detection model to use. The “Custom” model is specific to water leaks, while standard YOLO models detect common objects.
   - **Image Size:** Adjust the image size for detection. Larger sizes may improve accuracy for smaller objects but increase processing time.
   - **Confidence Threshold:** Set the minimum confidence score for a detection to be displayed. Lower values may show more detections, including possible false positives.
   - **Input Type:** Select whether you want to process an “Image” or a “Video.”

2. **Provide Input (Main Area - Left Column)**
   - **Image:** Click **Upload an image** or select one of the example images from the dropdown.
   - **Video:** Click **Upload a video**. The original video will appear once uploaded.

3. **Start Detection**
   - Click the **⚡ Detect Objects** button.

4. **View Results (Main Area - Right Column)**
   - **Image:** If you uploaded/selected an image, the original appears on the left, and the version with detection boxes appears on the right.
   - **Video:** Processing progress is shown, with a preview frame updating periodically. Once finished, the processed video with detections appears on the right.

5. **Save Video**
   - If a video was processed successfully, a **💾 Save Processed Video** button appears below the result. Click it to download the `.mp4` file.

6. **Model Information**
   - Below the results, information about the classes detected by the selected model is displayed.

## Notes

- Video processing can be computationally intensive, especially for long videos or larger models.  
- Ensure the model file (`best.pt` or your custom file) and example images are correctly placed in their respective directories (`models/`, `examples/`). Otherwise, update the paths in `app.py`.  
- Temporary files are created during video processing. The temporary *input* video is deleted automatically after processing. The temporary *processed* video is kept until you download it or start a new video processing task (depending on Streamlit’s session behavior).

---

Developed by: [AHB.ai](https://www.ahb.ai)  
Lead AI Developer: [Maykhel De Leon](https://www.linkedin.com/in/maykheldeleon/)