#!/bin/bash

set +e  # Never exit on errors - pod must always start!

echo "========================================="
echo "Starting RunPod ComfyUI Template"
echo "========================================="

# Set up environment
export PYTHONUNBUFFERED=1
export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128
export CUDA_MODULE_LOADING=LAZY

# Run first-time setup if needed (never fails)
if [ ! -f "/workspace/.setup_complete" ]; then
    echo ""
    echo "🚀 First deployment detected - running initial setup..."
    echo "   This will install all dependencies using RunPod's fast internet"
    echo "   Services will start even if some dependencies fail to install"
    echo ""
    bash /workspace/scripts/first_run_setup.sh || echo "⚠️ Setup had some issues, but continuing to start services..."
    echo ""
fi

# Create symbolic link for persistent storage if using RunPod network volume
if [ -d "/runpod-volume" ] && [ ! -L "/workspace/ComfyUI/models" ]; then
    echo "Setting up persistent storage..."
    mkdir -p /runpod-volume/models
    mkdir -p /runpod-volume/output

    # Backup existing models if any
    if [ -d "/workspace/ComfyUI/models" ]; then
        cp -rn /workspace/ComfyUI/models/* /runpod-volume/models/ 2>/dev/null || true
    fi

    # Create symlinks
    rm -rf /workspace/ComfyUI/models
    ln -s /runpod-volume/models /workspace/ComfyUI/models

    rm -rf /workspace/ComfyUI/output
    ln -s /runpod-volume/output /workspace/ComfyUI/output

    echo "Persistent storage configured."
fi

# Fix numpy compatibility issue (opencv-python upgrades to 2.x which breaks scipy/ComfyUI)
echo "🔧 Checking numpy version compatibility..."
pip install --no-cache-dir 'numpy<2.0' --force-reinstall --quiet 2>&1 | grep -v "Requirement already satisfied" || true
echo "✅ Numpy compatibility verified"

# Function to start Jupyter Lab
start_jupyter() {
    echo "Starting Jupyter Lab on port 8888..."
    cd /workspace
    jupyter lab \
        --ip=0.0.0.0 \
        --port=8888 \
        --no-browser \
        --allow-root \
        --ServerApp.token='' \
        --ServerApp.password='' \
        --ServerApp.allow_origin='*' \
        --ServerApp.base_url="${JUPYTER_BASE_URL:-/}" \
        &
}

# Function to start ComfyUI
start_comfyui() {
    echo "Starting ComfyUI on port 8188..."
    cd /workspace/ComfyUI
    python main.py \
        --listen 0.0.0.0 \
        --port 8188 \
        --enable-cors-header \
        --preview-method auto \
        &
}

# Function to start Model & Custom Nodes Manager
start_model_downloader() {
    echo "Starting Model & Custom Nodes Manager on port 7860..."
    cd /workspace/scripts
    python model_downloader.py &
}

# Function to start AI-Toolkit web interface (if installed)
start_ai_toolkit_ui() {
    if [ -d "/workspace/ai-toolkit" ]; then
        echo "Starting AI-Toolkit UI on port 7861..."
        cd /workspace/ai-toolkit
        # Check for common UI files
        if [ -f "app.py" ]; then
            python app.py --server-name 0.0.0.0 --server-port 7861 &
        elif [ -f "ui.py" ]; then
            python ui.py --server-name 0.0.0.0 --server-port 7861 &
        elif [ -f "webui.py" ]; then
            python webui.py --server-name 0.0.0.0 --server-port 7861 &
        else
            # Try launching with gradio if available
            python -c "import gradio; print('AI-Toolkit UI file not found')" 2>/dev/null || echo "AI-Toolkit not installed or no UI available"
        fi
    fi
}

# Display access information
display_info() {
    echo ""
    echo "========================================="
    echo "Services Started Successfully!"
    echo "========================================="
    echo ""

    if [ -n "$RUNPOD_POD_ID" ]; then
        # Running on RunPod
        echo "ComfyUI:               https://${RUNPOD_POD_ID}-8188.proxy.runpod.net"
        echo "Jupyter:               https://${RUNPOD_POD_ID}-8888.proxy.runpod.net"
        echo "Model & Nodes Manager: https://${RUNPOD_POD_ID}-7860.proxy.runpod.net"
        echo "AI-Toolkit UI:         https://${RUNPOD_POD_ID}-7861.proxy.runpod.net"
    else
        # Local or other hosting
        echo "ComfyUI:               http://localhost:8188"
        echo "Jupyter:               http://localhost:8888"
        echo "Model & Nodes Manager: http://localhost:7860"
        echo "AI-Toolkit UI:         http://localhost:7861"
    fi

    echo ""
    echo "========================================="
    echo "Quick Start Guide:"
    echo "========================================="
    echo "1. Access Model & Nodes Manager (port 7860):"
    echo "   - Install custom nodes with one click!"
    echo "   - Download checkpoints, LoRAs, and models"
    echo "   - Install AI-Toolkit via the AI-Toolkit tab"
    echo "2. Access ComfyUI (port 8188) to generate images/videos"
    echo "3. Access AI-Toolkit UI (port 7861) for LoRA training"
    echo "4. Use Jupyter (port 8888) to:"
    echo "   - Upload training images to /workspace/training_data/"
    echo "   - Manage files and run commands"
    echo ""
    echo "Directories:"
    echo "  Models:        /workspace/ComfyUI/models/"
    echo "  Custom nodes:  /workspace/ComfyUI/custom_nodes/"
    echo "  Training data: /workspace/training_data/"
    echo "  AI-Toolkit:    /workspace/ai-toolkit/"
    echo ""
    echo "========================================="
}

# Start services
start_jupyter
sleep 2
start_comfyui
sleep 2
start_model_downloader
sleep 2
start_ai_toolkit_ui

# Display info
sleep 3
display_info

# Keep container running and monitor processes
echo ""
echo "Container is ready. Monitoring services..."
echo "Press Ctrl+C to stop all services."
echo ""

# Monitor main processes
while true; do
    # Check if ComfyUI is still running
    if ! pgrep -f "python.*main.py.*8188" > /dev/null; then
        echo "ComfyUI stopped. Restarting..."
        start_comfyui
    fi

    # Check if Jupyter is still running
    if ! pgrep -f "jupyter-lab.*8888" > /dev/null; then
        echo "Jupyter stopped. Restarting..."
        start_jupyter
    fi

    sleep 30
done
