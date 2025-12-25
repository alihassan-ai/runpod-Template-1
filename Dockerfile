# RunPod ComfyUI Template - Ultra-Fast Build
# Code-only image - all dependencies install at runtime on RunPod's fast internet

FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV SHELL=/bin/bash
ENV PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128
ENV CUDA_MODULE_LOADING=LAZY

WORKDIR /workspace

# Install minimal system dependencies only (no Python packages yet!)
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    libmagic1 \
    aria2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI code only (no dependencies installed yet)
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    cd /workspace/ComfyUI && \
    rm -rf .git && \
    mkdir -p custom_nodes

# Copy all scripts and workflows
COPY scripts/ /workspace/scripts/
COPY workflows/ /workspace/ComfyUI/user/default/workflows/

# Create directories and set permissions
RUN chmod +x /workspace/scripts/*.sh /workspace/scripts/*.py && \
    mkdir -p \
        /workspace/ComfyUI/models/checkpoints \
        /workspace/ComfyUI/models/loras \
        /workspace/ComfyUI/models/vae \
        /workspace/ComfyUI/models/controlnet \
        /workspace/ComfyUI/models/upscale_models \
        /workspace/ComfyUI/models/clip \
        /workspace/ComfyUI/models/ipadapter \
        /workspace/ComfyUI/input \
        /workspace/ComfyUI/output \
        /workspace/training_data

# ============================================================================
# ULTRA-OPTIMIZED BUILD STRATEGY
# ============================================================================
# This image contains ONLY code - NO dependencies installed during build!
#
# Everything installs automatically on first pod startup:
# - ComfyUI dependencies (via first_run_setup.sh)
# - Video processing packages (via first_run_setup.sh)
# - ComfyUI Manager (via first_run_setup.sh)
# - Jupyter, Gradio (via first_run_setup.sh)
# - Custom Nodes (optional, via UI at port 7860)
# - AI-Toolkit (optional, via UI at port 7860)
#
# Benefits:
# - Build time: ~2-3 MINUTES (instead of 6+ hours!)
# - Image size: ~10-11 GB (instead of 21 GB!)
# - Uses RunPod's super-fast internet for all installs
# - First startup: 5-10 minutes (automatic)
# ============================================================================

# Expose ports
EXPOSE 8188 8888 7860 7861

# Start script (runs first_run_setup.sh automatically on first startup)
CMD ["/bin/bash", "/workspace/scripts/start.sh"]
