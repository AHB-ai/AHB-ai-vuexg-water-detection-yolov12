import streamlit as st
import cv2
import numpy as np
import tempfile
import os
import time
import logging
import shutil # Added for potential server-side save
from pathlib import Path
from typing import Dict, Optional, Tuple, Any

from ultralytics import YOLO
from PIL import Image, UnidentifiedImageError

# --- Configuration ---
APP_TITLE = "Water Leak Detection"
# Use specific paths for each logo
APP_ICON_PATH = "assets/VueXG_Icon.png"
SIDEBAR_LOGO_PATH = "assets/VueXG_Typography.png"
AUTHOR = "AHB.ai"
AUTHOR_URL = "https://www.ahb.ai"

# --- Model Configuration ---
SCRIPT_DIR = Path(__file__).resolve().parent
MODELS_DIR = SCRIPT_DIR / "models"
EXAMPLES_DIR = SCRIPT_DIR / "examples"
OUTPUT_DIR = SCRIPT_DIR / "output_videos"

# Ensure output directory exists
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

DEFAULT_CUSTOM_MODEL_PATH = MODELS_DIR / "water_leak.pt" # Adjust if your custom model has a different name

# --- Model Selection ---
MODEL_OPTIONS = {
    "Water Leak Detection (Custom)": str(DEFAULT_CUSTOM_MODEL_PATH),
    "YOLOv12-nano": "yolov12n.pt",
    "YOLOv12-small": "yolov12s.pt",
    "YOLOv12-medium": "yolov12m.pt",
    "YOLOv12-large": "yolov12l.pt",
    "YOLOv12-xlarge": "yolov12x.pt"
}

# --- Example Images ---
EXAMPLE_IMAGES = {
    "Example 1": str(EXAMPLES_DIR / "sample_day.jpg"),
    "Example 2": str(EXAMPLES_DIR / "sample_night.jpg")
}

# --- Logging Setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Helper Functions ---

@st.cache_resource # Cache the model loading
def load_yolo_model(model_path: str) -> YOLO:
    """Loads the YOLO model from the specified path."""
    model_path_obj = Path(model_path)
    if not model_path_obj.is_file():
        # Handle cases where standard YOLO models haven't been downloaded yet
        # by trying to instantiate them directly, letting ultralytics handle download.
        if model_path in ["yolov12n.pt", "yolov12s.pt", "yolov12m.pt", "yolov12l.pt", "yolov12x.pt"]:
             try:
                 model = YOLO(model_path)
                 logger.info(f"Standard model '{model_path}' loaded/downloaded successfully.")
                 return model
             except Exception as e:
                 logger.error(f"Error loading/downloading standard model {model_path}: {e}", exc_info=True)
                 st.error(f"Error loading standard model '{model_path}': {e}. Check internet connection.")
                 st.stop()
        else:
            # If it's a custom path and doesn't exist
            logger.error(f"Model file not found at specified path: {model_path}")
            st.error(f"Error: Model file not found at {model_path}. Please ensure it exists.")
            st.stop() # Stop execution if model file is missing

    # If the path exists, load it directly
    try:
        model = YOLO(model_path)
        logger.info(f"Model loaded successfully from {model_path}")
        return model
    except Exception as e:
        logger.error(f"Error loading model {model_path}: {e}", exc_info=True)
        st.error(f"Error loading model: {e}. Please ensure the model file is valid.")
        st.stop()

def process_image(image_source: Any, model: YOLO, img_size: int, conf: float) -> Optional[np.ndarray]:
    """Processes a single image for object detection."""
    original_image_rgb = None
    try:
        # Ensure input is in a format YOLO understands and keep original RGB
        if isinstance(image_source, Image.Image):
            # Convert PIL to numpy array (RGB)
            original_image_rgb = np.array(image_source.convert("RGB"))
            # YOLO might prefer BGR, conversion happens internally or pass BGR
            image_for_yolo = cv2.cvtColor(original_image_rgb, cv2.COLOR_RGB2BGR)
        elif isinstance(image_source, (str, Path)):
             # Read with OpenCV (loads as BGR)
             image_for_yolo = cv2.imread(str(image_source))
             if image_for_yolo is None:
                 raise ValueError(f"Could not read image file: {image_source}")
             original_image_rgb = cv2.cvtColor(image_for_yolo, cv2.COLOR_BGR2RGB)
        elif isinstance(image_source, np.ndarray):
             # Assume BGR if 3 channels, or convert if needed. Let's assume BGR input typical for CV ops
             if image_source.ndim == 3 and image_source.shape[2] == 3:
                 image_for_yolo = image_source
                 original_image_rgb = cv2.cvtColor(image_source, cv2.COLOR_BGR2RGB)
             else: # Grayscale or other formats - might need specific handling
                 image_for_yolo = image_source # Pass as is, YOLO might handle it
                 original_image_rgb = image_source # Cannot reliably convert to RGB
        else:
             raise TypeError(f"Unsupported image source type: {type(image_source)}")

        results = model.predict(source=image_for_yolo, imgsz=img_size, conf=conf, verbose=False)

        # Check if plot method exists and results are valid
        if not results or not hasattr(results[0], 'plot') or results[0].boxes is None or len(results[0].boxes) == 0:
             logger.warning("No detections found or plot unavailable for the image.")
             # Return the original image (RGB) if no detections
             return original_image_rgb

        annotated_image_bgr = results[0].plot()  # Returns BGR numpy array

        # Convert annotated BGR to RGB for Streamlit display
        annotated_image_rgb = cv2.cvtColor(annotated_image_bgr, cv2.COLOR_BGR2RGB)
        logger.info("Image processed successfully.")
        return annotated_image_rgb

    except Exception as e:
        logger.error(f"Error processing image: {e}", exc_info=True)
        st.error(f"Error during image detection: {e}")
        # Return original image in case of processing error
        return original_image_rgb


def process_video(
    video_path: str, model: YOLO, img_size: int, conf: float
) -> Optional[str]:
    """
    Processes a video file frame by frame for object detection.
    Displays real-time preview and progress.
    Returns the path to the processed temporary video file.
    """
    output_video_path = None
    cap = None
    out = None
    temp_output_file = None

    try:
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            st.error(f"Error: Could not open video file: {video_path}")
            logger.error(f"cv2.VideoCapture failed to open: {video_path}")
            return None

        frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

        # Handle potential issues with reading video properties
        if frame_width == 0 or frame_height == 0:
            st.error("Error: Could not read video dimensions. The file might be corrupted or unsupported.")
            logger.error(f"Failed to get valid dimensions for video: {video_path}")
            cap.release()
            return None
        if not fps or fps <= 0:
            logger.warning(f"Could not read FPS for video {video_path}. Defaulting to 30 FPS.")
            fps = 30 # Default fps if read fails

        # Create a temporary file for the output video
        temp_output_file = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4', dir=str(OUTPUT_DIR.parent)) # Store temp near output
        output_video_path = temp_output_file.name
        temp_output_file.close() # Close the file handle immediately, just need the name

        # Define the codec and create VideoWriter object
        fourcc = cv2.VideoWriter_fourcc(*'mp4v') # or 'avc1'
        out = cv2.VideoWriter(output_video_path, fourcc, fps, (frame_width, frame_height))
        if not out.isOpened():
             st.error("Error: Could not create video writer. Check codec support and permissions.")
             logger.error(f"cv2.VideoWriter failed to open for path: {output_video_path} with codec mp4v")
             # Clean up the temp file if writer fails
             if Path(output_video_path).exists(): os.unlink(output_video_path)
             cap.release()
             return None


        st.subheader("Processing Video")
        st.info("Processing frame by frame. Preview updates periodically.")
        progress_bar = st.progress(0)
        frame_text = st.empty()
        preview_image = st.empty()

        frame_count = 0
        start_time = time.time()
        preview_update_rate = max(1, int(fps / 2)) # Update preview roughly twice per second

        while True:
            ret, frame = cap.read()
            if not ret:
                if frame_count == 0:
                     logger.error("Could not read the first frame of the video.")
                     st.error("Error: Could not read frames from the video file.")
                     # Exit processing if no frames could be read at all
                     raise StopIteration("Failed to read any frames.")
                else:
                    logger.info("Reached end of video or error reading subsequent frame.")
                    break # End of video

            frame_count += 1

            try:
                # Process frame (BGR format expected by YOLO)
                results = model.predict(source=frame, imgsz=img_size, conf=conf, verbose=False, stream=False) # stream=False might be more stable for single frames
                if results and hasattr(results[0], 'plot'):
                    annotated_frame = results[0].plot() # Returns BGR
                else:
                     annotated_frame = frame # Use original if no results/plot
            except Exception as e:
                 logger.error(f"Error predicting frame {frame_count}: {e}", exc_info=True)
                 annotated_frame = frame # Use original frame if prediction fails

            # Write the BGR frame to the output video
            if out.isOpened():
                out.write(annotated_frame)
            else:
                logger.warning(f"Video writer closed unexpectedly at frame {frame_count}. Stopping.")
                st.warning("Video writing stopped unexpectedly.")
                break # Stop if writer is closed

            # Update progress and preview periodically
            # Update progress slightly more often than preview if video is long
            update_progress = (frame_count % 5 == 0) or (frame_count == total_frames)
            update_preview = (frame_count % preview_update_rate == 0) or (frame_count == total_frames)

            if update_progress and total_frames > 0:
                 progress = min(1.0, frame_count / total_frames)
                 progress_bar.progress(progress)
                 frame_text.text(f"Processing frame {frame_count}/{total_frames} ({progress:.0%})")

            if update_preview:
                 # Convert BGR to RGB for Streamlit preview display
                 try:
                     preview_frame_rgb = cv2.cvtColor(annotated_frame, cv2.COLOR_BGR2RGB)
                     preview_image.image(preview_frame_rgb, caption=f"Preview (Frame {frame_count})", use_container_width=True)
                 except cv2.error as cv_err:
                      logger.warning(f"Could not convert frame {frame_count} for preview: {cv_err}")
                      preview_image.warning(f"Preview unavailable for frame {frame_count}")


            # Yield control slightly for UI updates (can sometimes help responsiveness)
            # time.sleep(0.001)

        end_time = time.time()
        processing_time = end_time - start_time
        logger.info(f"Video processing completed for {frame_count} frames in {processing_time:.2f} seconds.")
        if frame_count > 0 and processing_time > 0:
             logger.info(f"Average processing FPS: {frame_count / processing_time:.2f}")

        progress_bar.empty()
        frame_text.empty()
        preview_image.empty()

        # Explicitly check if the output file was created and has size
        output_path_obj = Path(output_video_path)
        if not output_path_obj.is_file() or output_path_obj.stat().st_size == 0:
            logger.error(f"Output video file was not created or is empty: {output_video_path}")
            st.error("Error: Processed video file generation failed.")
            # Clean up empty file if it exists
            if output_path_obj.exists(): os.unlink(output_path_obj)
            return None

        return output_video_path

    except StopIteration as si: # Catch the specific error for no frames read
         logger.error(f"Video processing stopped: {si}")
         # No need to display st.error again, already done inside the loop
         return None
    except Exception as e:
        logger.error(f"Error processing video: {e}", exc_info=True)
        st.error(f"An error occurred during video processing: {e}")
        # Clean up temporary output file if created and an error occurred before return
        if output_video_path and Path(output_video_path).exists():
            try:
                os.unlink(output_video_path)
                logger.info(f"Cleaned up temporary output file due to error: {output_video_path}")
            except OSError as unlink_err:
                logger.error(f"Error deleting temp file {output_video_path} after error: {unlink_err}")
        return None
    finally:
        # Ensure resources are released
        if cap and cap.isOpened():
            cap.release()
            logger.info("Video capture released.")
        if out and out.isOpened():
            out.release()
            logger.info("Video writer released.")


def display_model_info(selected_model_path: str, custom_model_path: str):
    """Displays information about the selected detection model."""
    st.subheader("Detection Information")
    # Use Path objects for comparison
    if Path(selected_model_path) == Path(custom_model_path):
        st.markdown(f"""
        **Water Leak Detection Model (Custom)**

        This model is trained specifically by {AUTHOR} to detect:
        - Water leaks
        - Humans

        """)
    else:
        # Extract model name for standard models
        model_name = Path(selected_model_path).name
        st.markdown(f"""
        **Standard YOLO Model (`{model_name}`)**

        This model detects 80 common object classes (COCO dataset) including:
        - People, vehicles, animals
        - Common household and outdoor objects

        *Model Name: `{model_name}`*
        """)

def configure_sidebar(sidebar_logo: str) -> Tuple[str, int, float, str]:
    """Sets up the Streamlit sidebar for configuration."""
    with st.sidebar:
        # --- Display Sidebar Logo ---
        try:
            logo = Image.open(sidebar_logo)
            st.image(logo, use_container_width=True)
        except FileNotFoundError:
            logger.warning(f"Sidebar logo file not found at {sidebar_logo}. Skipping sidebar logo.")
            st.warning(f"Sidebar logo not found at: {sidebar_logo}")
        except UnidentifiedImageError:
             logger.error(f"Cannot identify image file type for sidebar logo: {sidebar_logo}")
             st.warning(f"Invalid image file for sidebar logo: {sidebar_logo}")
        except Exception as e:
            logger.error(f"Error loading or displaying sidebar logo: {e}", exc_info=True)
            st.warning("Could not display sidebar logo.")

        st.header("⚙️ Model Settings")

        # Check if custom model path exists
        custom_model_exists = Path(DEFAULT_CUSTOM_MODEL_PATH).is_file()
        model_options_list = list(MODEL_OPTIONS.keys())
        default_model_index = 0

        # Prepare dynamic model options based on existence of custom model
        current_model_options = {}
        if custom_model_exists:
             current_model_options.update(MODEL_OPTIONS)
             # Find index of the custom model key
             try:
                 default_model_index = model_options_list.index("Water Leak Detection (Custom)")
             except ValueError:
                 default_model_index = 0 # Fallback if key name mismatch
        else:
             # Filter out the custom model option
             current_model_options = {k: v for k, v in MODEL_OPTIONS.items() if "Custom" not in k}
             model_options_list = list(current_model_options.keys()) # Update list for selectbox
             default_model_index = 0 # Fallback to the first available standard model
             st.warning(f"Custom model not found at: {DEFAULT_CUSTOM_MODEL_PATH}. "
                        "Custom option disabled. Place model in 'models/' or update path.")


        selected_model_name = st.selectbox(
            "Select Model",
            options=model_options_list, # Use the potentially filtered list
            index=default_model_index,
            help="Choose the detection model. The custom model is specifically for water leaks."
        )
        # Get the path from the original dictionary, even if custom was filtered out
        selected_model_path = MODEL_OPTIONS[selected_model_name]


        image_size = st.slider(
            "Image Size (pixels)",
            min_value=320,
            max_value=1280,
            value=640,
            step=32,
            help="Size the image is resized to for detection (larger = potentially more accurate but slower)."
        )

        conf_threshold = st.slider(
            "Confidence Threshold",
            min_value=0.0,
            max_value=1.0,
            value=0.25,
            step=0.05,
            help="Minimum probability for an object detection to be considered valid."
        )

        input_type = st.radio(
            "Input Type",
            options=["Image", "Video"],
            index=0,
            horizontal=True,
        )

    return selected_model_path, image_size, conf_threshold, input_type

def set_page_configuration(icon_path: str):
    """Sets the Streamlit page configuration (title and icon)."""
    try:
        icon = Image.open(icon_path)
        st.set_page_config(
            page_title=APP_TITLE,
            page_icon=icon,
            layout="wide"
        )
    except FileNotFoundError:
        logger.error(f"App icon file not found at {icon_path}. Using default icon.")
        st.set_page_config(page_title=APP_TITLE, layout="wide") # Use default emoji icon
    except UnidentifiedImageError:
        logger.error(f"Cannot identify image file type for app icon: {icon_path}. Using default icon.")
        st.set_page_config(page_title=APP_TITLE, layout="wide")
    except Exception as e:
        logger.error(f"Error loading app icon: {e}", exc_info=True)
        st.set_page_config(page_title=APP_TITLE, layout="wide") # Fallback

# --- Main Application Logic ---
def main():
    # Set page config first (icon, title)
    set_page_configuration(APP_ICON_PATH)

    # Configure sidebar (displays sidebar logo and gets settings)
    selected_model_path, image_size, conf_threshold, input_type = configure_sidebar(SIDEBAR_LOGO_PATH)

    # Display main title and author info in the main area
    st.title(APP_TITLE)
    st.markdown(f"Developed by [{AUTHOR}]({AUTHOR_URL})")
    st.divider() # Add a visual separator

    # Load the selected model (cached)
    model = load_yolo_model(selected_model_path)

    col1, col2 = st.columns(2)
    uploaded_file = None
    example_choice = None
    temp_input_path = None # To store path of temporary file for uploaded content

    # --- Input Area ---
    with col1:
        st.header("Input Source")
        if input_type == "Image":
            uploaded_file = st.file_uploader(
                "Upload an image", type=["jpg", "jpeg", "png"], accept_multiple_files=False, key="img_uploader"
            )
            st.markdown("---")
            st.subheader("Or try an example:")

            # Check if example images exist
            valid_examples = {name: path for name, path in EXAMPLE_IMAGES.items() if Path(path).is_file()}
            if not valid_examples:
                 st.warning("No example images found in the 'examples/' directory.")
                 example_options = [""]
            else:
                example_options = [""] + list(valid_examples.keys())

            # Use a key to prevent state issues if options change
            example_choice = st.selectbox(
                "Select example image",
                options=example_options,
                index=0,
                label_visibility="collapsed",
                key="example_selector"
            )

        else: # Video Input
            uploaded_file = st.file_uploader(
                "Upload a video", type=["mp4", "avi", "mov", "webm"], accept_multiple_files=False, key="vid_uploader"
            )

    # --- Detection Trigger ---
    # Place button below input options for better flow
    detect_button = st.button("⚡ Detect Objects", type="primary", use_container_width=True)

    # --- Output Area ---
    with col2:
        st.header("Detection Result")
        result_placeholder = st.empty() # For image or final video display
        save_button_placeholder = st.empty() # For the save video button

    # --- Processing Logic ---
    # Use session state to track if detection has been run, to avoid reprocessing on simple reruns
    if 'detection_ran' not in st.session_state:
        st.session_state.detection_ran = False
    if 'processed_video_path' not in st.session_state:
         st.session_state.processed_video_path = None # Initialize

    if detect_button:
        st.session_state.detection_ran = True # Mark that detection was triggered
        # Clear previous video result path if starting a new detection
        if st.session_state.processed_video_path:
            # Optional: Clean up the old temp file here if desired
            # try:
            #     if Path(st.session_state.processed_video_path).exists():
            #         os.unlink(st.session_state.processed_video_path)
            #         logger.info(f"Cleaned up previous temp output video: {st.session_state.processed_video_path}")
            # except OSError as e:
            #     logger.warning(f"Could not delete previous temp file {st.session_state.processed_video_path}: {e}")
            st.session_state.processed_video_path = None # Reset the path


        source_image = None
        source_video_path = None
        display_original_image = None # To hold the image to display in col1

        # 1. Determine Input Source
        if input_type == "Image":
            input_provided = False
            if uploaded_file:
                try:
                    source_image = Image.open(uploaded_file) # Keep as PIL Image for processing
                    display_original_image = source_image.copy() # Keep a copy for display
                    logger.info(f"Processing uploaded image: {uploaded_file.name}")
                    input_provided = True
                except Exception as e:
                    st.error(f"Error opening uploaded image: {e}")
                    logger.error(f"Error opening uploaded image {uploaded_file.name}: {e}", exc_info=True)
            elif example_choice and valid_examples:
                example_path = valid_examples.get(example_choice)
                if example_path:
                     try:
                         source_image = Image.open(example_path) # Keep as PIL Image
                         display_original_image = source_image.copy()
                         logger.info(f"Processing example image: {example_path}")
                         input_provided = True
                     except FileNotFoundError:
                         st.error(f"Example image file not found: {example_path}")
                         logger.error(f"Example image file not found: {example_path}")
                     except Exception as e:
                         st.error(f"Error opening example image {example_path}: {e}")
                         logger.error(f"Error opening example image {example_path}: {e}", exc_info=True)
                else:
                    st.warning("Please select a valid example image.") # Should not happen if list is correct
            else:
                st.warning("Please upload an image or select an example.")

            # Display original image in col1 only if input was provided
            if display_original_image:
                with col1:
                    st.image(display_original_image, caption="Original Image", use_container_width=True)


        else: # Video Input
            input_provided = False
            if uploaded_file:
                try:
                    # Save uploaded video to a temporary file
                    # Ensure the temp file has the correct suffix for cv2.VideoCapture
                    suffix = Path(uploaded_file.name).suffix or '.mp4'
                    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
                        temp_file.write(uploaded_file.getvalue())
                        temp_input_path = temp_file.name # Store path for processing
                    logger.info(f"Uploaded video saved temporarily to: {temp_input_path}")
                    source_video_path = temp_input_path
                    input_provided = True

                    # Display original video in col1
                    with col1: # Display original under the uploader
                        st.subheader("Original Video")
                        try:
                             st.video(source_video_path)
                        except Exception as e:
                             st.error(f"Could not display the original video: {e}")
                             logger.error(f"Error displaying original video {source_video_path}: {e}", exc_info=True)


                except Exception as e:
                    logger.error(f"Error handling uploaded video file: {e}", exc_info=True)
                    st.error(f"Error reading uploaded video: {e}")
                    source_video_path = None # Ensure processing doesn't start
                    input_provided = False # Mark as no input if error
                    # Clean up temp input file if created before error
                    if temp_input_path and Path(temp_input_path).exists():
                        try: os.unlink(temp_input_path)
                        except OSError: pass
            else:
                st.warning("Please upload a video file.")

        # 2. Perform Detection only if valid input was provided
        processed_output_path = None # Reset this for video
        if input_provided:
            if source_image is not None: # Image processing
                with st.spinner("🧠 Processing Image..."):
                    processed_image = process_image(source_image, model, image_size, conf_threshold)
                with col2: # Display result in the output column
                    if processed_image is not None:
                        result_placeholder.image(processed_image, caption="Detection Result", use_container_width=True)
                        logger.info("Image detection displayed.")
                    else:
                        # Display original if processing failed but original exists
                        if display_original_image:
                             result_placeholder.image(display_original_image, caption="Original Image (Processing Failed or No Detections)", use_container_width=True)
                        else:
                             result_placeholder.warning("Could not process the image or no objects detected.")


            elif source_video_path is not None: # Video processing
                 with col2: # Show spinner in the result column
                    with st.spinner("⏳ Processing Video... Please wait."):
                        processed_output_path = process_video(source_video_path, model, image_size, conf_threshold)

                 if processed_output_path and Path(processed_output_path).exists():
                     logger.info(f"Processed video available at temporary path: {processed_output_path}")
                     st.session_state['processed_video_path'] = processed_output_path # Store path for saving/display

                     # Display processed video in output column
                     with col2:
                          result_placeholder.video(processed_output_path)
                          st.success("✅ Video processing completed!")
                 else:
                      logger.error("Video processing failed or did not produce an output file.")
                      with col2:
                          result_placeholder.error("Video processing failed. Check logs for details.")

                 # Clean up the temporary *input* video file now that processing is done (or failed)
                 if temp_input_path and Path(temp_input_path).exists():
                     try:
                         os.unlink(temp_input_path)
                         logger.info(f"Cleaned up temporary input file: {temp_input_path}")
                     except OSError as e:
                         logger.error(f"Error deleting temporary input file {temp_input_path}: {e}")

            # 3. Display Model Information (after processing attempt, if input was provided)
            display_model_info(selected_model_path, str(DEFAULT_CUSTOM_MODEL_PATH))

        else: # No valid input provided or error during input handling
            st.session_state.detection_ran = False # Reset flag if no input to process
            # Clear any previous results shown in placeholders
            result_placeholder.empty()
            save_button_placeholder.empty()


    # --- Display Save Button (if video was processed in the *current* run or a previous one stored in state) ---
    # This check happens on every rerun, ensuring the button appears if a valid path exists in session state.
    if st.session_state.get('processed_video_path'):
        processed_video_temp_path = st.session_state['processed_video_path']
        path_obj = Path(processed_video_temp_path)

        if path_obj.is_file() and path_obj.stat().st_size > 0:
            try:
                # Reading the whole video into memory might be bad for large files.
                # st.download_button can sometimes handle paths directly, but let's stick
                # to reading bytes for broader compatibility / explicit control.
                # Consider chunking for very large files if memory becomes an issue.
                with open(processed_video_temp_path, "rb") as f:
                    video_bytes = f.read()

                # Generate a default filename
                timestamp = time.strftime("%Y%m%d_%H%M%S")
                output_filename = f"detected_video_{timestamp}.mp4"

                # Ensure the button is placed correctly using the placeholder
                with save_button_placeholder.container():
                    st.download_button(
                        label="💾 Save Processed Video",
                        data=video_bytes,
                        file_name=output_filename,
                        mime="video/mp4",
                        key="download_video_btn",
                        help=f"Click to download the processed video as '{output_filename}'.",
                        use_container_width=True,
                        # on_click=cleanup_temp_video # Optional: Clean up after download click
                    )
                    # You could add a function `cleanup_temp_video` to delete
                    # st.session_state['processed_video_path'] after download starts,
                    # but download success isn't guaranteed. It's safer to leave it
                    # until a new video is processed or the session ends.

            except FileNotFoundError:
                 logger.warning(f"Processed video file disappeared before download could be prepared: {processed_video_temp_path}")
                 st.session_state['processed_video_path'] = None # Clear state if file gone
                 save_button_placeholder.empty() # Remove button if file missing
            except Exception as e:
                 logger.error(f"Error preparing video for download: {e}", exc_info=True)
                 st.error(f"Error preparing download: {e}")
                 # Clear the state on error? Maybe not, allow retry? Let's keep state for now.
                 save_button_placeholder.error("Error preparing download.")

        else:
            logger.warning(f"Processed video path in session state is invalid or file is empty: {processed_video_temp_path}")
            st.session_state['processed_video_path'] = None # Clear invalid state
            save_button_placeholder.empty() # Remove button


    # --- Footer ---
    st.markdown("---")
    st.markdown(f"Developed by [{AUTHOR}]({AUTHOR_URL})")


if __name__ == "__main__":
    main()