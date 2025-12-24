#!/bin/bash

echo "========================================="
echo "Starting RunPod ComfyUI Template"
echo "========================================="

# Set up environment
export PYTHONUNBUFFERED=1
export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128
export CUDA_MODULE_LOADING=LAZY

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

# Function to start Model Download Manager
start_model_downloader() {
    echo "Starting Model Download Manager on port 7860..."
    cd /workspace/scripts
    python model_downloader.py &
}

# Function to start AI-Toolkit web interface (if available)
start_ai_toolkit_ui() {
    if [ -f "/workspace/ai-toolkit/app.py" ]; then
        echo "Starting AI-Toolkit UI on port 7861..."
        cd /workspace/ai-toolkit
        python app.py --server-name 0.0.0.0 --server-port 7861 &
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
        echo "ComfyUI:          https://${RUNPOD_POD_ID}-8188.proxy.runpod.net"
        echo "Jupyter:          https://${RUNPOD_POD_ID}-8888.proxy.runpod.net"
        echo "Model Downloader: https://${RUNPOD_POD_ID}-7860.proxy.runpod.net"
        echo "AI-Toolkit:       https://${RUNPOD_POD_ID}-7861.proxy.runpod.net"
    else
        # Local or other hosting
        echo "ComfyUI:          http://localhost:8188"
        echo "Jupyter:          http://localhost:8888"
        echo "Model Downloader: http://localhost:7860"
        echo "AI-Toolkit:       http://localhost:7861"
    fi

    echo ""
    echo "========================================="
    echo "Quick Start Guide:"
    echo "========================================="
    echo "1. Access Model Downloader to download checkpoints, LoRAs, and models"
    echo "2. Access ComfyUI to start generating images/videos"
    echo "3. Use Jupyter to upload training images to /workspace/training_data/"
    echo "4. Use AI-Toolkit UI for LoRA training (Flux/SDXL)"
    echo ""
    echo "Models directory: /workspace/ComfyUI/models/"
    echo "Training data:    /workspace/training_data/"
    echo "AI-Toolkit:       /workspace/ai-toolkit/"
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
