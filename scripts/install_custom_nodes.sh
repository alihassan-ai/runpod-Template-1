#!/bin/bash
set -e

echo "========================================="
echo "Installing ComfyUI Custom Nodes"
echo "========================================="

cd /workspace/ComfyUI/custom_nodes

# Essential Video and Image Processing Nodes
echo "Installing ComfyUI-VideoHelperSuite..."
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite && pip install -r requirements.txt && cd ..

echo "Installing ComfyUI-IPAdapter_plus..."
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
cd ComfyUI_IPAdapter_plus && pip install -r requirements.txt && cd ..

echo "Installing ComfyUI-Impact-Pack..."
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
cd ComfyUI-Impact-Pack && pip install -r requirements.txt && cd ..

echo "Installing ComfyUI Impact Subpack..."
git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git
cd ComfyUI-Impact-Subpack && pip install -r requirements.txt 2>/dev/null || true && cd ..

# Advanced Video Nodes
echo "Installing ComfyUI-Advanced-ControlNet..."
git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git

echo "Installing ComfyUI-AnimateDiff-Evolved..."
git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
cd ComfyUI-AnimateDiff-Evolved && pip install -r requirements.txt && cd ..

echo "Installing ComfyUI-Frame-Interpolation..."
git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git
cd ComfyUI-Frame-Interpolation && pip install -r requirements.txt && cd ..

# ControlNet and Pose
echo "Installing comfyui_controlnet_aux..."
git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git
cd comfyui_controlnet_aux && pip install -r requirements.txt && cd ..

# Quality and Upscaling
echo "Installing ComfyUI_essentials..."
git clone https://github.com/cubiq/ComfyUI_essentials.git
cd ComfyUI_essentials && pip install -r requirements.txt && cd ..

echo "Installing ComfyUI-SUPIR..."
git clone https://github.com/kijai/ComfyUI-SUPIR.git
cd ComfyUI-SUPIR && pip install -r requirements.txt 2>/dev/null || true && cd ..

# Workflow Helpers
echo "Installing efficiency-nodes-comfyui..."
git clone https://github.com/jags111/efficiency-nodes-comfyui.git
cd efficiency-nodes-comfyui && pip install -r requirements.txt 2>/dev/null || true && cd ..

echo "Installing ComfyUI-Custom-Scripts..."
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git

echo "Installing rgthree-comfy..."
git clone https://github.com/rgthree/rgthree-comfy.git
cd rgthree-comfy && pip install -r requirements.txt 2>/dev/null || true && cd ..

# Model Management
echo "Installing ComfyUI-Manager (if not already installed)..."
if [ ! -d "ComfyUI-Manager" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
fi

# WAS Node Suite
echo "Installing was-node-suite-comfyui..."
git clone https://github.com/WASasquatch/was-node-suite-comfyui.git
cd was-node-suite-comfyui && pip install -r requirements.txt && cd ..

# Additional useful nodes
echo "Installing ComfyUI_UltimateSDUpscale..."
git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git

echo "Installing ComfyUI-AnimateLCM..."
git clone https://github.com/daniabib/ComfyUI-AnimateLCM.git

echo "Installing ComfyUI_FizzNodes..."
git clone https://github.com/FizzleDorf/ComfyUI_FizzNodes.git
cd ComfyUI_FizzNodes && pip install -r requirements.txt 2>/dev/null || true && cd ..

# Install any additional Python dependencies
echo "Installing additional Python packages..."
pip install -q \
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

echo "========================================="
echo "Custom Nodes Installation Complete!"
echo "========================================="
