#!/bin/bash
set -e

echo "========================================="
echo "ComfyUI Model Download Script"
echo "========================================="

# HuggingFace download helper
download_hf() {
    local repo=$1
    local filename=$2
    local output_path=$3

    echo "Downloading $filename from $repo..."
    wget -c "https://huggingface.co/$repo/resolve/main/$filename" -O "$output_path" || \
    curl -L -C - "https://huggingface.co/$repo/resolve/main/$filename" -o "$output_path"
}

# CivitAI download helper (requires model ID)
download_civitai() {
    local model_id=$1
    local output_path=$2

    echo "Downloading from CivitAI (ID: $model_id)..."
    wget -c "https://civitai.com/api/download/models/$model_id" -O "$output_path" || \
    curl -L -C - "https://civitai.com/api/download/models/$model_id" -o "$output_path"
}

# Base directories
CHECKPOINT_DIR="/workspace/ComfyUI/models/checkpoints"
LORA_DIR="/workspace/ComfyUI/models/loras"
VAE_DIR="/workspace/ComfyUI/models/vae"
CONTROLNET_DIR="/workspace/ComfyUI/models/controlnet"
CLIP_DIR="/workspace/ComfyUI/models/clip"
IPADAPTER_DIR="/workspace/ComfyUI/models/ipadapter"
UPSCALE_DIR="/workspace/ComfyUI/models/upscale_models"

# Create flag file to track downloads
DOWNLOAD_FLAG="/workspace/.models_downloaded"

# Check if models already downloaded
if [ -f "$DOWNLOAD_FLAG" ]; then
    echo "Models already downloaded (flag file exists)."
    echo "To re-download, delete $DOWNLOAD_FLAG and restart."
    exit 0
fi

echo ""
echo "========================================="
echo "Downloading Essential Models"
echo "========================================="
echo ""

# ===================================
# CHECKPOINTS
# ===================================
echo ">>> Downloading Checkpoints..."

# Realistic Vision XL
if [ ! -f "$CHECKPOINT_DIR/realisticVisionXL_v40.safetensors" ]; then
    echo "Note: For premium checkpoints, please download manually from:"
    echo "  - CivitAI: https://civitai.com/"
    echo "  - HuggingFace: https://huggingface.co/"
    echo ""
    echo "Recommended checkpoints for realistic results:"
    echo "  - Realistic Vision XL v7"
    echo "  - Juggernaut XL"
    echo "  - DreamShaper XL"
    echo ""
fi

# Download SD XL Base (free and open)
if [ ! -f "$CHECKPOINT_DIR/sd_xl_base_1.0.safetensors" ]; then
    echo "Downloading SDXL Base 1.0..."
    download_hf "stabilityai/stable-diffusion-xl-base-1.0" "sd_xl_base_1.0.safetensors" "$CHECKPOINT_DIR/sd_xl_base_1.0.safetensors"
fi

# WAI-NSFW Illustrious SDXL
if [ ! -f "$CHECKPOINT_DIR/wai_nsfw_illustrious_sdxl_v140.safetensors" ]; then
    echo "Downloading WAI-NSFW Illustrious SDXL v1.4.0..."
    wget -c "https://huggingface.co/dhead/wai-nsfw-illustrious-sdxl-v140-sdxl/resolve/main/unet/diffusion_pytorch_model.fp16.safetensors" \
        -O "$CHECKPOINT_DIR/wai_nsfw_illustrious_sdxl_v140.safetensors" || echo "Failed to download WAI-NSFW Illustrious, continuing..."
fi

# Premium Checkpoint from CivitAI (Model ID: 245598)
if [ ! -f "$CHECKPOINT_DIR/checkpoint_245598.safetensors" ]; then
    echo "Downloading checkpoint from CivitAI (ID: 245598)..."
    wget -c --content-disposition "https://civitai.com/api/download/models/245598?type=Model&format=SafeTensor&size=full" \
        -O "$CHECKPOINT_DIR/checkpoint_245598.safetensors" || echo "Failed to download CivitAI model 245598, continuing..."
fi

# Premium Checkpoint from CivitAI (Model ID: 999999)
if [ ! -f "$CHECKPOINT_DIR/checkpoint_999999.safetensors" ]; then
    echo "Downloading checkpoint from CivitAI (ID: 999999)..."
    wget -c --content-disposition "https://civitai.com/api/download/models/999999?type=Model&format=Safetensors&size=full" \
        -O "$CHECKPOINT_DIR/checkpoint_999999.safetensors" || echo "Failed to download CivitAI model 999999, continuing..."
fi

# ===================================
# VAE
# ===================================
echo ""
echo ">>> Downloading VAE Models..."

if [ ! -f "$VAE_DIR/sdxl_vae.safetensors" ]; then
    echo "Downloading SDXL VAE..."
    download_hf "stabilityai/sdxl-vae" "sdxl_vae.safetensors" "$VAE_DIR/sdxl_vae.safetensors"
fi

if [ ! -f "$VAE_DIR/vae-ft-mse-840000-ema-pruned.safetensors" ]; then
    echo "Downloading SD 1.5 VAE..."
    download_hf "stabilityai/sd-vae-ft-mse-original" "vae-ft-mse-840000-ema-pruned.safetensors" "$VAE_DIR/vae-ft-mse-840000-ema-pruned.safetensors"
fi

# ===================================
# CONTROLNET
# ===================================
echo ""
echo ">>> Downloading ControlNet Models..."

# SDXL ControlNets
if [ ! -f "$CONTROLNET_DIR/diffusers_xl_canny_full.safetensors" ]; then
    echo "Downloading SDXL Canny ControlNet..."
    download_hf "stabilityai/control-lora" "control-LoRAs-rank256/control-lora-canny-rank256.safetensors" "$CONTROLNET_DIR/diffusers_xl_canny_full.safetensors" || true
fi

if [ ! -f "$CONTROLNET_DIR/diffusers_xl_depth_full.safetensors" ]; then
    echo "Downloading SDXL Depth ControlNet..."
    download_hf "stabilityai/control-lora" "control-LoRAs-rank256/control-lora-depth-rank256.safetensors" "$CONTROLNET_DIR/diffusers_xl_depth_full.safetensors" || true
fi

# OpenPose
if [ ! -f "$CONTROLNET_DIR/control_v11p_sd15_openpose.pth" ]; then
    echo "Downloading OpenPose ControlNet..."
    download_hf "lllyasviel/ControlNet-v1-1" "control_v11p_sd15_openpose.pth" "$CONTROLNET_DIR/control_v11p_sd15_openpose.pth" || true
fi

# DW OpenPose (Depth-Weighted OpenPose)
if [ ! -f "$CONTROLNET_DIR/dw-ll_ucoco_384.onnx" ]; then
    echo "Downloading DW OpenPose model..."
    download_hf "yzd-v/DWPose" "dw-ll_ucoco_384.onnx" "$CONTROLNET_DIR/dw-ll_ucoco_384.onnx" || true
fi

if [ ! -f "$CONTROLNET_DIR/yolox_l.onnx" ]; then
    echo "Downloading DW OpenPose detector..."
    download_hf "yzd-v/DWPose" "yolox_l.onnx" "$CONTROLNET_DIR/yolox_l.onnx" || true
fi

# Depth Anything v2
if [ ! -f "$CONTROLNET_DIR/depth_anything_v2_vitl.pth" ]; then
    echo "Downloading Depth Anything V2 (ViT-L)..."
    wget -c "https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth" \
        -O "$CONTROLNET_DIR/depth_anything_v2_vitl.pth" || true
fi

# Lineart Realistic
if [ ! -f "$CONTROLNET_DIR/control_v11p_sd15_lineart.pth" ]; then
    echo "Downloading Lineart Realistic ControlNet..."
    download_hf "lllyasviel/ControlNet-v1-1" "control_v11p_sd15_lineart.pth" "$CONTROLNET_DIR/control_v11p_sd15_lineart.pth" || true
fi

# ===================================
# CLIP MODELS
# ===================================
echo ""
echo ">>> Downloading CLIP Models..."

if [ ! -f "$CLIP_DIR/clip_g.safetensors" ]; then
    echo "Downloading CLIP-G..."
    download_hf "stabilityai/stable-diffusion-xl-base-1.0" "text_encoder_2/model.safetensors" "$CLIP_DIR/clip_g.safetensors" || true
fi

if [ ! -f "$CLIP_DIR/clip_l.safetensors" ]; then
    echo "Downloading CLIP-L..."
    download_hf "stabilityai/stable-diffusion-xl-base-1.0" "text_encoder/model.safetensors" "$CLIP_DIR/clip_l.safetensors" || true
fi

# ===================================
# IP-ADAPTER
# ===================================
echo ""
echo ">>> Downloading IP-Adapter Models..."

mkdir -p "$IPADAPTER_DIR"

if [ ! -f "$IPADAPTER_DIR/ip-adapter_sdxl.safetensors" ]; then
    echo "Downloading IP-Adapter SDXL..."
    download_hf "h94/IP-Adapter" "sdxl_models/ip-adapter_sdxl.safetensors" "$IPADAPTER_DIR/ip-adapter_sdxl.safetensors" || true
fi

if [ ! -f "$IPADAPTER_DIR/ip-adapter-plus_sdxl_vit-h.safetensors" ]; then
    echo "Downloading IP-Adapter Plus SDXL..."
    download_hf "h94/IP-Adapter" "sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors" "$IPADAPTER_DIR/ip-adapter-plus_sdxl_vit-h.safetensors" || true
fi

# ===================================
# UPSCALE MODELS
# ===================================
echo ""
echo ">>> Downloading Upscale Models..."

if [ ! -f "$UPSCALE_DIR/RealESRGAN_x4plus.pth" ]; then
    echo "Downloading RealESRGAN 4x..."
    wget -c "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth" -O "$UPSCALE_DIR/RealESRGAN_x4plus.pth" || true
fi

if [ ! -f "$UPSCALE_DIR/RealESRGAN_x4plus_anime_6B.pth" ]; then
    echo "Downloading RealESRGAN 4x Anime..."
    wget -c "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth" -O "$UPSCALE_DIR/RealESRGAN_x4plus_anime_6B.pth" || true
fi

# ===================================
# LORAS
# ===================================
echo ""
echo ">>> LoRA Models"
echo "Note: High-quality LoRAs are typically available on CivitAI."
echo "Please download your preferred LoRAs manually from:"
echo "  https://civitai.com/models"
echo ""
echo "Popular categories:"
echo "  - Detail Enhancement LoRAs"
echo "  - Lighting & Style LoRAs"
echo "  - Character & Pose LoRAs"
echo ""

# Create a download list for reference
cat > /workspace/DOWNLOAD_INSTRUCTIONS.txt << 'EOL'
========================================
MANUAL MODEL DOWNLOADS
========================================

This template includes open-source base models. For premium/specialized models:

RECOMMENDED CHECKPOINTS:
1. Visit https://civitai.com/ or https://huggingface.co/
2. Download your preferred SDXL checkpoints
3. Place in: /workspace/ComfyUI/models/checkpoints/

Popular options:
  - Realistic Vision XL v7
  - Juggernaut XL v9
  - DreamShaper XL
  - AAM XL (Anime)

RECOMMENDED LORAS:
1. Browse https://civitai.com/models?types=LORA
2. Download detail/quality LoRAs
3. Place in: /workspace/ComfyUI/models/loras/

Useful categories:
  - Detail enhancers
  - Lighting improvements
  - Style modifiers
  - Quality boosters

CONTROLNET MODELS:
Most essential ControlNets are auto-downloaded.
Additional models: https://huggingface.co/lllyasviel

VIDEO MODELS (for AnimateDiff/Wan):
Will be downloaded via ComfyUI Manager on first use.

========================================
EOL

echo ""
echo "Created /workspace/DOWNLOAD_INSTRUCTIONS.txt for reference"

# Create download flag
touch "$DOWNLOAD_FLAG"

echo ""
echo "========================================="
echo "Model Download Complete!"
echo "========================================="
echo "Base models installed. See DOWNLOAD_INSTRUCTIONS.txt"
echo "for information on downloading premium checkpoints."
echo "========================================="
