#!/usr/bin/env python3
"""
Model Download Manager for ComfyUI
Simple web interface to download models, LoRAs, and other files
Includes custom node installation functionality
"""

import gradio as gr
import os
import subprocess
from pathlib import Path
import threading
import time
import re

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

# Custom nodes list (from install_custom_nodes.sh)
CUSTOM_NODES = [
    {"name": "ComfyUI-VideoHelperSuite", "url": "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"},
    {"name": "ComfyUI_IPAdapter_plus", "url": "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git"},
    {"name": "ComfyUI-Impact-Pack", "url": "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"},
    {"name": "ComfyUI-Impact-Subpack", "url": "https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git"},
    {"name": "ComfyUI-Advanced-ControlNet", "url": "https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git"},
    {"name": "ComfyUI-AnimateDiff-Evolved", "url": "https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git"},
    {"name": "ComfyUI-Frame-Interpolation", "url": "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git"},
    {"name": "comfyui_controlnet_aux", "url": "https://github.com/Fannovel16/comfyui_controlnet_aux.git"},
    {"name": "ComfyUI_essentials", "url": "https://github.com/cubiq/ComfyUI_essentials.git"},
    {"name": "ComfyUI-SUPIR", "url": "https://github.com/kijai/ComfyUI-SUPIR.git"},
    {"name": "efficiency-nodes-comfyui", "url": "https://github.com/jags111/efficiency-nodes-comfyui.git"},
    {"name": "ComfyUI-Custom-Scripts", "url": "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"},
    {"name": "rgthree-comfy", "url": "https://github.com/rgthree/rgthree-comfy.git"},
    {"name": "was-node-suite-comfyui", "url": "https://github.com/WASasquatch/was-node-suite-comfyui.git"},
    {"name": "ComfyUI_UltimateSDUpscale", "url": "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"},
    {"name": "ComfyUI-AnimateLCM", "url": "https://github.com/daniabib/ComfyUI-AnimateLCM.git"},
    {"name": "ComfyUI_FizzNodes", "url": "https://github.com/FizzleDorf/ComfyUI_FizzNodes.git"},
]

# Global download status
download_status = {"active": False, "message": ""}

# Custom nodes installation status
nodes_status = {"installing": False, "log": "", "progress": ""}

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

def check_node_installed(node_name):
    """Check if a custom node is already installed"""
    custom_nodes_dir = "/workspace/ComfyUI/custom_nodes"
    node_path = os.path.join(custom_nodes_dir, node_name)
    return os.path.exists(node_path) and os.path.isdir(node_path)

def get_installed_nodes():
    """Get list of installed custom nodes with status"""
    status_lines = []
    status_lines.append("=" * 60)
    status_lines.append("CUSTOM NODES STATUS")
    status_lines.append("=" * 60)
    status_lines.append("")

    installed_count = 0
    for node in CUSTOM_NODES:
        is_installed = check_node_installed(node["name"])
        if is_installed:
            status_lines.append(f"✅ {node['name']}")
            installed_count += 1
        else:
            status_lines.append(f"⬜ {node['name']}")

    status_lines.append("")
    status_lines.append("=" * 60)
    status_lines.append(f"Installed: {installed_count}/{len(CUSTOM_NODES)} nodes")
    status_lines.append("=" * 60)

    return "\n".join(status_lines)

def install_single_node(node_name, node_url):
    """Install a single custom node"""
    custom_nodes_dir = "/workspace/ComfyUI/custom_nodes"
    os.makedirs(custom_nodes_dir, exist_ok=True)

    node_dir = os.path.join(custom_nodes_dir, node_name)

    # Check if already installed
    if os.path.exists(node_dir):
        return f"⚠️  {node_name} already installed, skipping..."

    try:
        # Clone the repository
        print(f"Installing {node_name}...")
        clone_result = subprocess.run(
            ["git", "clone", "--depth", "1", node_url, node_dir],
            cwd=custom_nodes_dir,
            capture_output=True,
            text=True,
            timeout=300
        )

        if clone_result.returncode != 0:
            return f"❌ Failed to clone {node_name}"

        # Install requirements if they exist
        requirements_file = os.path.join(node_dir, "requirements.txt")
        if os.path.exists(requirements_file):
            print(f"Installing dependencies for {node_name}...")
            pip_result = subprocess.run(
                ["pip", "install", "--no-cache-dir", "-r", "requirements.txt"],
                cwd=node_dir,
                capture_output=True,
                text=True,
                timeout=600
            )
            # Don't fail if pip install has issues, just continue

        # Remove .git directory to save space
        git_dir = os.path.join(node_dir, ".git")
        if os.path.exists(git_dir):
            subprocess.run(["rm", "-rf", git_dir])

        return f"✅ {node_name} installed successfully"

    except subprocess.TimeoutExpired:
        return f"⏱️  {node_name} installation timed out"
    except Exception as e:
        return f"❌ {node_name} failed: {str(e)}"

def install_all_nodes():
    """Install all custom nodes with progress updates"""
    global nodes_status

    if nodes_status["installing"]:
        return "⚠️  Installation already in progress..."

    nodes_status["installing"] = True
    nodes_status["log"] = ""
    nodes_status["progress"] = "Starting installation..."

    log_lines = []
    log_lines.append("=" * 60)
    log_lines.append("INSTALLING COMFYUI CUSTOM NODES")
    log_lines.append("=" * 60)
    log_lines.append("")
    log_lines.append(f"📦 Total nodes to install: {len(CUSTOM_NODES)}")
    log_lines.append("")

    installed = 0
    skipped = 0
    failed = 0

    for i, node in enumerate(CUSTOM_NODES, 1):
        node_name = node["name"]
        node_url = node["url"]

        progress_msg = f"[{i}/{len(CUSTOM_NODES)}] Installing {node_name}..."
        log_lines.append(progress_msg)
        nodes_status["progress"] = progress_msg
        nodes_status["log"] = "\n".join(log_lines)

        result = install_single_node(node_name, node_url)
        log_lines.append(result)

        if "successfully" in result:
            installed += 1
        elif "already installed" in result or "skipping" in result:
            skipped += 1
        else:
            failed += 1

        log_lines.append("")
        nodes_status["log"] = "\n".join(log_lines)

    # Install additional Python packages
    log_lines.append("=" * 60)
    log_lines.append("Installing additional Python packages...")
    log_lines.append("=" * 60)

    packages = [
        "scikit-image", "kornia", "spandrel", "facexlib",
        "timm", "einops", "transformers", "accelerate",
        "safetensors", "omegaconf", "pytorch-lightning"
    ]

    try:
        subprocess.run(
            ["pip", "install", "--no-cache-dir", "-q"] + packages,
            capture_output=True,
            text=True,
            timeout=600
        )
        log_lines.append("✅ Additional packages installed")
    except:
        log_lines.append("⚠️  Some additional packages may have failed")

    log_lines.append("")
    log_lines.append("=" * 60)
    log_lines.append("INSTALLATION COMPLETE!")
    log_lines.append("=" * 60)
    log_lines.append(f"✅ Successfully installed: {installed}")
    log_lines.append(f"⏭️  Skipped (already installed): {skipped}")
    log_lines.append(f"❌ Failed: {failed}")
    log_lines.append("")
    log_lines.append("🔄 Restart ComfyUI to use the new custom nodes!")
    log_lines.append("=" * 60)

    nodes_status["log"] = "\n".join(log_lines)
    nodes_status["progress"] = "Installation complete!"
    nodes_status["installing"] = False

    return nodes_status["log"]

def install_ai_toolkit():
    """Install AI-Toolkit for LoRA training"""
    if os.path.exists("/workspace/ai-toolkit"):
        return "✅ AI-Toolkit is already installed at /workspace/ai-toolkit"

    log_lines = []
    log_lines.append("=" * 60)
    log_lines.append("INSTALLING AI-TOOLKIT")
    log_lines.append("=" * 60)
    log_lines.append("")

    try:
        # Run the installation script
        result = subprocess.run(
            ["bash", "/workspace/scripts/install_ai_toolkit.sh"],
            capture_output=True,
            text=True,
            timeout=600
        )

        log_lines.append(result.stdout)

        if result.returncode == 0:
            log_lines.append("")
            log_lines.append("=" * 60)
            log_lines.append("✅ AI-Toolkit installed successfully!")
            log_lines.append("=" * 60)
            log_lines.append("Location: /workspace/ai-toolkit/")
            log_lines.append("Configs: /workspace/ai-toolkit/config/")
            log_lines.append("Training data: /workspace/training_data/input/")
        else:
            log_lines.append("")
            log_lines.append("❌ Installation failed")
            log_lines.append(result.stderr)

    except subprocess.TimeoutExpired:
        log_lines.append("⏱️  Installation timed out")
    except Exception as e:
        log_lines.append(f"❌ Error: {str(e)}")

    return "\n".join(log_lines)

def huggingface_login(token):
    """Login to Hugging Face using CLI"""
    if not token or token.strip() == "":
        return "❌ Please provide a Hugging Face token"

    try:
        # Install huggingface_hub if not already installed
        subprocess.run(
            ["pip", "install", "--no-cache-dir", "-q", "huggingface_hub"],
            capture_output=True,
            timeout=60
        )

        # Login using the token
        result = subprocess.run(
            ["huggingface-cli", "login", "--token", token.strip()],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            return f"✅ Successfully logged in to Hugging Face!\n\n{result.stdout}\n\nYou can now use AI-Toolkit to access gated models like Flux."
        else:
            return f"❌ Login failed:\n{result.stderr}"

    except subprocess.TimeoutExpired:
        return "⏱️ Login timed out"
    except Exception as e:
        return f"❌ Error: {str(e)}"

def check_hf_login_status():
    """Check if user is logged into Hugging Face"""
    try:
        result = subprocess.run(
            ["huggingface-cli", "whoami"],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            return f"✅ Logged in as:\n{result.stdout}"
        else:
            return "❌ Not logged in to Hugging Face"

    except:
        return "❌ Unable to check login status (huggingface-cli not installed)"

# Create Gradio interface
with gr.Blocks(title="ComfyUI Manager", theme=gr.themes.Soft()) as app:
    gr.Markdown("# 📥 ComfyUI Model & Custom Nodes Manager")
    gr.Markdown("Download models, LoRAs, ControlNets, and install custom nodes directly to your ComfyUI installation")

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

    with gr.Tab("🧩 Custom Nodes"):
        gr.Markdown("## Install ComfyUI Custom Nodes")
        gr.Markdown("Install all custom nodes with one click. This uses RunPod's fast internet connection!")

        with gr.Row():
            with gr.Column():
                install_all_btn = gr.Button(
                    "🚀 Install All Custom Nodes",
                    variant="primary",
                    size="lg"
                )
                check_status_btn = gr.Button("🔍 Check Installation Status", size="lg")

            with gr.Column():
                gr.Markdown(f"""
                **Nodes to be installed:** {len(CUSTOM_NODES)}

                This will install:
                - Video processing nodes (AnimateDiff, Frame Interpolation)
                - ControlNet and IP-Adapter nodes
                - Quality & upscaling nodes (SUPIR, Ultimate SD Upscale)
                - Workflow helpers and utilities
                - Additional Python dependencies

                **Note:** Installation may take 5-15 minutes depending on internet speed.
                You can monitor progress in real-time below.
                """)

        installation_output = gr.Textbox(
            label="Installation Log",
            lines=20,
            interactive=False,
            placeholder="Click 'Install All Custom Nodes' to begin installation..."
        )

        nodes_status_output = gr.Textbox(
            label="Installed Nodes Status",
            lines=15,
            interactive=False
        )

        install_all_btn.click(
            fn=install_all_nodes,
            outputs=installation_output
        )

        check_status_btn.click(
            fn=get_installed_nodes,
            outputs=nodes_status_output
        )

    with gr.Tab("🎨 AI-Toolkit"):
        gr.Markdown("## Install AI-Toolkit for LoRA Training")
        gr.Markdown("AI-Toolkit enables easy Flux and SDXL LoRA training directly on your RunPod instance.")

        with gr.Row():
            with gr.Column():
                install_toolkit_btn = gr.Button(
                    "🚀 Install AI-Toolkit",
                    variant="primary",
                    size="lg"
                )

            with gr.Column():
                gr.Markdown("""
                **What is AI-Toolkit?**

                AI-Toolkit is a powerful tool for training custom LoRAs for:
                - Flux models
                - SDXL models
                - Custom character/style training

                **Installation includes:**
                - AI-Toolkit repository
                - Training dependencies
                - Pre-configured training templates
                - Launch scripts

                **Note:** Installation takes ~5 minutes.
                """)

        toolkit_output = gr.Textbox(
            label="Installation Log",
            lines=15,
            interactive=False,
            placeholder="Click 'Install AI-Toolkit' to begin installation..."
        )

        install_toolkit_btn.click(
            fn=install_ai_toolkit,
            outputs=toolkit_output
        )

    with gr.Tab("🔑 HF Login"):
        gr.Markdown("## Hugging Face Login")
        gr.Markdown("Login to Hugging Face to access gated models (required for Flux and other restricted models in AI-Toolkit)")

        with gr.Row():
            with gr.Column():
                gr.Markdown("""
                **How to get your token:**

                1. Go to [Hugging Face Settings](https://huggingface.co/settings/tokens)
                2. Click "New token" or use an existing one
                3. Copy the token
                4. Paste it below and click Login

                **Token permissions needed:**
                - Read access to repos

                **This is required for:**
                - Accessing Flux models in AI-Toolkit
                - Downloading gated models
                - Using private repositories
                """)

                check_status_btn_hf = gr.Button("🔍 Check Login Status", size="lg")

            with gr.Column():
                hf_token_input = gr.Textbox(
                    label="Hugging Face Token",
                    placeholder="hf_...",
                    type="password",
                    lines=1
                )
                login_btn = gr.Button("🔑 Login to Hugging Face", variant="primary", size="lg")

        hf_output = gr.Textbox(
            label="Login Status",
            lines=10,
            interactive=False,
            placeholder="Enter your Hugging Face token above and click Login..."
        )

        login_btn.click(
            fn=huggingface_login,
            inputs=hf_token_input,
            outputs=hf_output
        )

        check_status_btn_hf.click(
            fn=check_hf_login_status,
            outputs=hf_output
        )

    with gr.Tab("📚 Quick Links"):
        gr.Markdown(get_quick_links())

    gr.Markdown("---")
    gr.Markdown("💡 **Tip:** Use a network volume for persistent storage across pod restarts!")

if __name__ == "__main__":
    # Create all model directories
    for dir_path in MODEL_DIRS.values():
        os.makedirs(dir_path, exist_ok=True)

    # Create custom_nodes directory if it doesn't exist
    os.makedirs("/workspace/ComfyUI/custom_nodes", exist_ok=True)

    print("🚀 Starting ComfyUI Model & Custom Nodes Manager on port 7860...")
    print("   - Download models, LoRAs, and other files")
    print("   - Install custom nodes with one click")
    app.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=False,
        show_error=True
    )
