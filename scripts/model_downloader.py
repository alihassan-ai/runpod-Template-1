#!/usr/bin/env python3
"""
Model Download Manager for ComfyUI
Simple web interface to download models, LoRAs, and other files
"""

import gradio as gr
import os
import subprocess
from pathlib import Path
import threading
import time

# Model directories
MODEL_DIRS = {
    "Checkpoints": "/workspace/ComfyUI/models/checkpoints",
    "LoRAs": "/workspace/ComfyUI/models/loras",
    "VAE": "/workspace/ComfyUI/models/vae",
    "ControlNet": "/workspace/ComfyUI/models/controlnet",
    "CLIP": "/workspace/ComfyUI/models/clip",
    "IP-Adapter": "/workspace/ComfyUI/models/ipadapter",
    "Upscale Models": "/workspace/ComfyUI/models/upscale_models",
    "Embeddings": "/workspace/ComfyUI/models/embeddings",
}

# Global download status
download_status = {"active": False, "message": ""}

def download_file(url, model_type, filename=None):
    """Download a file to the specified model directory"""
    global download_status

    if not url:
        return "❌ Please provide a URL"

    if model_type not in MODEL_DIRS:
        return f"❌ Invalid model type: {model_type}"

    target_dir = MODEL_DIRS[model_type]
    os.makedirs(target_dir, exist_ok=True)

    # Determine filename
    if not filename:
        filename = url.split("/")[-1].split("?")[0]
        if not filename or filename == "":
            filename = "downloaded_model.safetensors"

    output_path = os.path.join(target_dir, filename)

    download_status["active"] = True
    download_status["message"] = f"⏳ Downloading {filename}..."

    try:
        # Use wget with progress
        cmd = [
            "wget",
            "-c",  # Continue partial downloads
            "--content-disposition",  # Use server-provided filename if available
            "-O", output_path,
            url
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            file_size = os.path.getsize(output_path) / (1024 * 1024 * 1024)  # GB
            download_status["active"] = False
            download_status["message"] = ""
            return f"✅ Downloaded successfully!\n📁 Location: {output_path}\n💾 Size: {file_size:.2f} GB"
        else:
            download_status["active"] = False
            download_status["message"] = ""
            return f"❌ Download failed:\n{result.stderr}"

    except Exception as e:
        download_status["active"] = False
        download_status["message"] = ""
        return f"❌ Error: {str(e)}"

def list_models(model_type):
    """List all files in a model directory"""
    if model_type not in MODEL_DIRS:
        return "Invalid model type"

    target_dir = MODEL_DIRS[model_type]

    if not os.path.exists(target_dir):
        return f"📂 Directory is empty: {target_dir}"

    files = []
    for f in sorted(os.listdir(target_dir)):
        file_path = os.path.join(target_dir, f)
        if os.path.isfile(file_path):
            size = os.path.getsize(file_path) / (1024 * 1024)  # MB
            files.append(f"📄 {f} ({size:.1f} MB)")

    if not files:
        return f"📂 No files in {model_type}"

    return "\n".join(files)

def get_quick_links():
    """Return a list of popular model sources"""
    return """
## 🔗 Popular Model Sources

**Checkpoints & LoRAs:**
- [CivitAI](https://civitai.com/) - Largest community model repository
- [HuggingFace](https://huggingface.co/models) - Open-source models

**How to download from CivitAI:**
1. Find your model on CivitAI
2. Click the download button → Copy link address
3. Paste the URL here
4. Select the correct model type
5. Click Download!

**Example URLs:**
- HuggingFace: `https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors`
- CivitAI: `https://civitai.com/api/download/models/MODEL_ID`
"""

# Create Gradio interface
with gr.Blocks(title="ComfyUI Model Downloader", theme=gr.themes.Soft()) as app:
    gr.Markdown("# 📥 ComfyUI Model Download Manager")
    gr.Markdown("Download models, LoRAs, ControlNets, and more directly to your ComfyUI installation")

    with gr.Tab("Download"):
        with gr.Row():
            with gr.Column():
                url_input = gr.Textbox(
                    label="Model URL",
                    placeholder="https://huggingface.co/.../model.safetensors",
                    lines=2
                )
                model_type = gr.Dropdown(
                    choices=list(MODEL_DIRS.keys()),
                    label="Model Type",
                    value="Checkpoints"
                )
                filename_input = gr.Textbox(
                    label="Custom Filename (optional)",
                    placeholder="Leave empty to use original filename"
                )
                download_btn = gr.Button("⬇️ Download", variant="primary", size="lg")

            with gr.Column():
                output = gr.Textbox(
                    label="Download Status",
                    lines=6,
                    interactive=False
                )

        download_btn.click(
            fn=download_file,
            inputs=[url_input, model_type, filename_input],
            outputs=output
        )

    with gr.Tab("Browse Models"):
        with gr.Row():
            browse_type = gr.Dropdown(
                choices=list(MODEL_DIRS.keys()),
                label="Select Model Type",
                value="Checkpoints"
            )
            refresh_btn = gr.Button("🔄 Refresh")

        files_list = gr.Textbox(
            label="Installed Models",
            lines=15,
            interactive=False
        )

        browse_type.change(
            fn=list_models,
            inputs=browse_type,
            outputs=files_list
        )

        refresh_btn.click(
            fn=list_models,
            inputs=browse_type,
            outputs=files_list
        )

    with gr.Tab("📚 Quick Links"):
        gr.Markdown(get_quick_links())

    gr.Markdown("---")
    gr.Markdown("💡 **Tip:** Use a network volume for persistent storage across pod restarts!")

if __name__ == "__main__":
    # Create all model directories
    for dir_path in MODEL_DIRS.values():
        os.makedirs(dir_path, exist_ok=True)

    print("🚀 Starting Model Download Manager on port 7860...")
    app.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=False,
        show_error=True
    )
