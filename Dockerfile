# RunPod ComfyUI Template with AI-Toolkit and Video Extensions
# Optimized for RTX 4090/5090

# Use pre-built PyTorch image to save build time and resources
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV SHELL=/bin/bash

# Set working directory
WORKDIR /workspace

# Install additional system dependencies (git, wget, curl already in base image)
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    libmagic1 \
    aria2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter for file management
RUN pip install --no-cache-dir jupyter jupyterlab notebook && \
    rm -rf /root/.cache/pip

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI

# Install ComfyUI dependencies
WORKDIR /workspace/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Install additional packages for video processing
RUN pip install --no-cache-dir \
    opencv-python \
    imageio \
    imageio-ffmpeg \
    av \
    moviepy \
    insightface \
    onnxruntime-gpu && \
    rm -rf /root/.cache/pip

# Install ComfyUI Manager
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Copy installation scripts
COPY scripts/install_custom_nodes.sh /workspace/scripts/
COPY scripts/install_ai_toolkit.sh /workspace/scripts/
COPY scripts/download_models.sh /workspace/scripts/
COPY scripts/start.sh /workspace/scripts/

# Make scripts executable
RUN chmod +x /workspace/scripts/*.sh

# Install custom nodes
RUN bash /workspace/scripts/install_custom_nodes.sh

# Install AI-Toolkit
RUN bash /workspace/scripts/install_ai_toolkit.sh

# Create necessary directories
RUN mkdir -p /workspace/ComfyUI/models/checkpoints \
    /workspace/ComfyUI/models/loras \
    /workspace/ComfyUI/models/vae \
    /workspace/ComfyUI/models/controlnet \
    /workspace/ComfyUI/models/upscale_models \
    /workspace/ComfyUI/models/clip \
    /workspace/ComfyUI/models/ipadapter \
    /workspace/ComfyUI/input \
    /workspace/ComfyUI/output \
    /workspace/training_data

# Copy workflow files (copy directory to ensure it exists)
COPY workflows /workspace/workflows_temp
RUN mkdir -p /workspace/ComfyUI/user/default/workflows && \
    cp -r /workspace/workflows_temp/* /workspace/ComfyUI/user/default/workflows/ 2>/dev/null || true && \
    rm -rf /workspace/workflows_temp

# Expose ports
EXPOSE 8188 8888 7860

# Set environment variables for optimization
ENV PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128
ENV CUDA_MODULE_LOADING=LAZY

# Start script
CMD ["/bin/bash", "/workspace/scripts/start.sh"]
