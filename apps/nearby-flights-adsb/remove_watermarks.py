import cv2
import numpy as np
import os
import glob

def remove_watermark(image_path, output_path):
    # Load the image
    img = cv2.imread(image_path)
    if img is None:
        print(f"Failed to load {image_path}")
        return

    # Convert to grayscale to create a mask
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # The watermark is bright white text. 
    # Thresholding to isolate the white text.
    # We use a high threshold because the text is very white.
    # We might need to adjust this depending on the background.
    _, mask = cv2.threshold(gray, 220, 255, cv2.THRESH_BINARY)

    # Clean up the mask using morphological operations
    # Dilate a bit to ensure we cover the edges of the anti-aliased text
    kernel = np.ones((3, 3), np.uint8)
    mask = cv2.dilate(mask, kernel, iterations=1)

    # Inpaint the image
    # cv2.INPAINT_TELEA is generally good for small regions
    result = cv2.inpaint(img, mask, inpaintRadius=3, flags=cv2.INPAINT_TELEA)

    # Save the result
    cv2.imwrite(output_path, result)
    print(f"Processed: {os.path.basename(image_path)}")

def main():
    input_dir = "originals"
    output_dir = "processed_images"
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    image_paths = glob.glob(os.path.join(input_dir, "*.png"))
    
    for path in image_paths:
        output_path = os.path.join(output_dir, os.path.basename(path))
        remove_watermark(path, output_path)

if __name__ == "__main__":
    main()
