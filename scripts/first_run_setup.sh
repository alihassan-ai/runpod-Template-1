#!/bin/bash

# First Run Setup Script - NEVER FAILS!
# Installs all dependencies on first pod startup using RunPod's fast internet
# Continues even if individual steps fail to ensure pod always starts

set +e  # Don't exit on errors - CRITICAL!

SETUP_COMPLETE_FLAG="/workspace/.setup_complete"
SETUP_LOG="/workspace/first_run_setup.log"

# Check if setup has already been completed
if [ -f "$SETUP_COMPLETE_FLAG" ]; then
    echo "✅ Setup already completed, skipping first-run installation"
    exit 0
fi

echo "=========================================" | tee "$SETUP_LOG"
echo "FIRST RUN SETUP - Installing Dependencies" | tee -a "$SETUP_LOG"
echo "=========================================" | tee -a "$SETUP_LOG"
echo "This will take 5-10 minutes using RunPod's fast internet" | tee -a "$SETUP_LOG"
echo "Pod will start even if some packages fail to install" | tee -a "$SETUP_LOG"
echo "" | tee -a "$SETUP_LOG"

# Install Jupyter and Gradio first (needed for UI)
echo "📦 [1/5] Installing Jupyter and Gradio..." | tee -a "$SETUP_LOG"
pip install --no-cache-dir \
    jupyter \
    jupyterlab \
    notebook \
    gradio 2>&1 | tee -a "$SETUP_LOG" || echo "⚠️ Some packages failed, continuing..." | tee -a "$SETUP_LOG"

# Install ComfyUI dependencies
echo "📦 [2/5] Installing ComfyUI dependencies..." | tee -a "$SETUP_LOG"
cd /workspace/ComfyUI
pip install --no-cache-dir -r requirements.txt 2>&1 | tee -a "$SETUP_LOG" || echo "⚠️ Some packages failed, continuing..." | tee -a "$SETUP_LOG"

# Install additional video processing packages
echo "📦 [3/5] Installing video processing packages..." | tee -a "$SETUP_LOG"
pip install --no-cache-dir \
    opencv-python \
    imageio \
    imageio-ffmpeg \
    av \
    moviepy \
    insightface \
    onnxruntime-gpu 2>&1 | tee -a "$SETUP_LOG" || echo "⚠️ Some packages failed, continuing..." | tee -a "$SETUP_LOG"

# Fix numpy version compatibility (opencv-python upgrades to 2.x which breaks scipy/ComfyUI)
echo "🔧 Fixing numpy version compatibility..." | tee -a "$SETUP_LOG"
pip install --no-cache-dir 'numpy<2.0' --force-reinstall 2>&1 | tee -a "$SETUP_LOG" || echo "⚠️ Numpy downgrade failed, continuing..." | tee -a "$SETUP_LOG"

# Install ComfyUI Manager
echo "📦 [4/5] Installing ComfyUI Manager..." | tee -a "$SETUP_LOG"
cd /workspace/ComfyUI/custom_nodes
if [ ! -d "ComfyUI-Manager" ]; then
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git 2>&1 | tee -a "$SETUP_LOG" || echo "⚠️ ComfyUI-Manager clone failed, continuing..." | tee -a "$SETUP_LOG"
    if [ -d "ComfyUI-Manager" ]; then
        cd ComfyUI-Manager
        rm -rf .git
        cd ..
    fi
fi

# Cleanup (never fails)
echo "🧹 [5/5] Cleaning up..." | tee -a "$SETUP_LOG"
rm -rf /root/.cache/pip /tmp/* /var/tmp/* 2>/dev/null || true
find /usr/local/lib/python3.10/dist-packages -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true
find /usr/local/lib/python3.10/dist-packages -type d -name "test" -exec rm -rf {} + 2>/dev/null || true

# ALWAYS mark setup as complete - even if errors occurred
touch "$SETUP_COMPLETE_FLAG"

echo "" | tee -a "$SETUP_LOG"
echo "=========================================" | tee -a "$SETUP_LOG"
echo "✅ First Run Setup Complete!" | tee -a "$SETUP_LOG"
echo "=========================================" | tee -a "$SETUP_LOG"
echo "" | tee -a "$SETUP_LOG"
echo "Check /workspace/first_run_setup.log for details" | tee -a "$SETUP_LOG"
echo "" | tee -a "$SETUP_LOG"
echo "Next steps:" | tee -a "$SETUP_LOG"
echo "1. Access Model & Nodes Manager (port 7860) to install custom nodes" | tee -a "$SETUP_LOG"
echo "2. Login to Hugging Face via the HF Login tab" | tee -a "$SETUP_LOG"
echo "3. Install AI-Toolkit via the UI if you need LoRA training" | tee -a "$SETUP_LOG"
echo "4. Start using ComfyUI!" | tee -a "$SETUP_LOG"
echo "" | tee -a "$SETUP_LOG"

# Always exit successfully
exit 0
