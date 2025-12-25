#!/bin/bash

echo "========================================="
echo "Installing ComfyUI Custom Nodes"
echo "========================================="

cd /workspace/ComfyUI/custom_nodes

# Helper function to clone and cleanup
clone_node() {
    local repo=$1
    local dirname=$(basename $repo .git)
    echo "Installing $dirname..."

    # Try to clone, continue if it fails
    if git clone --depth 1 $repo 2>/dev/null; then
        cd $dirname
        if [ -f requirements.txt ]; then
            pip install --no-cache-dir -r requirements.txt 2>/dev/null || true
        fi
        rm -rf .git
        cd ..
        echo "✓ $dirname installed successfully"
    else
        echo "⚠ Warning: Failed to clone $dirname, skipping..."
    fi
}

# Essential Video and Image Processing Nodes
clone_node https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git

clone_node https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
clone_node https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
clone_node https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git

# Advanced Video Nodes
clone_node https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
clone_node https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
clone_node https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git

# ControlNet and Pose
clone_node https://github.com/Fannovel16/comfyui_controlnet_aux.git

# Quality and Upscaling
clone_node https://github.com/cubiq/ComfyUI_essentials.git
clone_node https://github.com/kijai/ComfyUI-SUPIR.git

# Workflow Helpers
clone_node https://github.com/jags111/efficiency-nodes-comfyui.git
clone_node https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
clone_node https://github.com/rgthree/rgthree-comfy.git

# WAS Node Suite
clone_node https://github.com/WASasquatch/was-node-suite-comfyui.git

# Additional useful nodes
clone_node https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
clone_node https://github.com/daniabib/ComfyUI-AnimateLCM.git
clone_node https://github.com/FizzleDorf/ComfyUI_FizzNodes.git

# Install any additional Python dependencies
echo "Installing additional Python packages..."
pip install --no-cache-dir -q \
    scikit-image \
    kornia \
    spandrel \
    facexlib \
    timm \
    einops \
    transformers \
    accelerate \
    safetensors \
    omegaconf \
    pytorch-lightning

# Clean up pip cache and temporary files
rm -rf /root/.cache/pip
rm -rf /tmp/* /var/tmp/*

echo "========================================="
echo "Custom Nodes Installation Complete!"
echo "========================================="
