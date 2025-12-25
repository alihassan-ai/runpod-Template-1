# RunPod ComfyUI Template with AI-Toolkit

A fully pre-configured RunPod template for ComfyUI with AI-Toolkit for LoRA training, video generation nodes, and essential models. Optimized for RTX 4090/5090.

## Features

- **ComfyUI** with ComfyUI Manager pre-installed
- **AI-Toolkit** for easy Flux/SDXL LoRA training via web UI
- **Model & Nodes Manager** - One-click installation of custom nodes and easy model downloads
- **Video Generation Nodes**: AnimateDiff, VideoHelperSuite, Frame Interpolation
- **Essential Custom Nodes**: IPAdapter Plus, Impact Pack, ControlNet Aux, and more (install via UI)
- **Jupyter Lab** for easy file management and uploads
- **Fast Runtime Installation** - Custom nodes install quickly on RunPod's fast internet
- **Persistent storage** support for RunPod network volumes
- **Optimized** for RTX 4090/5090 with CUDA 12.1
- **Smaller Docker Image** - Faster builds, faster deployments

## Available Custom Nodes (Install via UI)

Custom nodes are now installed at runtime through the Model & Nodes Manager interface. This provides faster deployments and uses RunPod's superior internet connection.

### Video & Animation
- ComfyUI-VideoHelperSuite
- ComfyUI-AnimateDiff-Evolved
- ComfyUI-Frame-Interpolation
- ComfyUI-AnimateLCM

### Image Processing
- ComfyUI-IPAdapter_plus
- ComfyUI-Impact-Pack
- ComfyUI-ControlNet-Aux
- ComfyUI-Advanced-ControlNet

### Utilities
- ComfyUI-Manager (model installation, updates)
- ComfyUI-Custom-Scripts
- WAS Node Suite
- Efficiency Nodes
- rgthree-comfy

### Quality Enhancement
- ComfyUI-SUPIR
- ComfyUI_UltimateSDUpscale
- ComfyUI_essentials

## Pre-Downloaded Models

On first startup, the following models are automatically downloaded:

- **Checkpoints:**
  - SDXL Base 1.0 (base model)
  - WAI-NSFW Illustrious SDXL v1.4.0
  - Premium SDXL checkpoints (from CivitAI)
- SDXL VAE
- SD 1.5 VAE
- ControlNet models:
  - SDXL Canny & Depth
  - OpenPose (SD 1.5)
  - DW OpenPose (Depth-Weighted)
  - Depth Anything V2 (ViT-L)
  - Lineart Realistic
- CLIP-G and CLIP-L
- IP-Adapter SDXL models
- RealESRGAN upscalers

## Directory Structure

```
/workspace/
├── ComfyUI/                    # Main ComfyUI installation
│   ├── custom_nodes/           # All custom nodes
│   ├── models/                 # Model files
│   │   ├── checkpoints/        # Stable Diffusion checkpoints
│   │   ├── loras/              # LoRA models
│   │   ├── vae/                # VAE models
│   │   ├── controlnet/         # ControlNet models
│   │   ├── ipadapter/          # IP-Adapter models
│   │   └── upscale_models/     # Upscaler models
│   ├── input/                  # Input images
│   └── output/                 # Generated images
├── ai-toolkit/                 # AI-Toolkit for training
│   ├── config/                 # Training configurations
│   └── launch_training.sh      # Training launcher script
├── training_data/              # Your training datasets
│   ├── input/                  # Place training images here
│   └── output/                 # Trained models output
└── scripts/                    # Setup scripts
```

## Building and Deploying to RunPod

### Step 1: Build the Docker Image

```bash
# Navigate to the template directory
cd runpod-comfyui-template

# Build the Docker image
docker build -t your-dockerhub-username/comfyui-runpod:latest .

# Test locally (optional)
docker run -it --gpus all -p 8188:8188 -p 8888:8888 \
    your-dockerhub-username/comfyui-runpod:latest
```

### Step 2: Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Push the image
docker push your-dockerhub-username/comfyui-runpod:latest
```

### Step 3: Create RunPod Template

1. Go to [RunPod Templates](https://www.runpod.io/console/serverless/user/templates)
2. Click "New Template"
3. Fill in the details:
   - **Template Name**: `ComfyUI + AI-Toolkit + Video Nodes`
   - **Image Name**: `your-dockerhub-username/comfyui-runpod:latest`
   - **Docker Command**: (leave empty, uses CMD from Dockerfile)
   - **Container Disk**: `150 GB`
   - **Expose HTTP Ports**: `8188, 8888, 7860, 7861`
   - **Expose TCP Ports**: (leave empty)

4. Click "Save Template"

### Step 4: Get Your Deploy Link

After creating the template, RunPod will generate a template ID. Your deploy link will be:

```
https://runpod.io/console/deploy?template=YOUR_TEMPLATE_ID
```

Share this link or use it yourself to deploy with one click.

## Usage

### Accessing Services

Once deployed on RunPod, access your services at:

- **ComfyUI**: `https://YOUR_POD_ID-8188.proxy.runpod.net`
- **Jupyter Lab**: `https://YOUR_POD_ID-8888.proxy.runpod.net`
- **Model & Nodes Manager**: `https://YOUR_POD_ID-7860.proxy.runpod.net`
- **AI-Toolkit**: `https://YOUR_POD_ID-7861.proxy.runpod.net` (if UI available)

Replace `YOUR_POD_ID` with your actual pod ID from RunPod.

### Installing Custom Nodes (First Time Setup)

**IMPORTANT:** On first deployment, you need to install custom nodes:

1. Open the **Model & Nodes Manager** at port 7860
2. Go to the "Custom Nodes" tab
3. Click the **"Install All Custom Nodes"** button
4. Wait 5-15 minutes for installation to complete (monitor progress in real-time)
5. Restart ComfyUI after installation completes

This one-time setup installs all 17 custom nodes and their dependencies using RunPod's fast internet connection.

### Using ComfyUI

1. Open ComfyUI in your browser
2. Load a workflow or create your own
3. Use ComfyUI Manager to install additional models
4. Generate images/videos

### Using Model & Nodes Manager

The Model & Nodes Manager provides an easy web interface for managing your ComfyUI installation:

#### Download Models Tab
1. Paste any model URL (HuggingFace, CivitAI, etc.)
2. Select the model type (Checkpoints, LoRAs, VAE, etc.)
3. Optionally specify a custom filename
4. Click Download
5. Models are automatically saved to the correct directory

#### Browse Models Tab
- View all installed models by category
- Check file sizes and manage your storage
- Refresh to see newly downloaded models

#### Custom Nodes Tab
- **Install All Custom Nodes**: One-click installation of all 17 custom nodes
- **Check Installation Status**: See which nodes are installed
- Real-time progress monitoring during installation
- Automatic dependency installation

### Training LoRAs with AI-Toolkit

#### Upload Training Images

1. Open Jupyter Lab
2. Navigate to `/workspace/training_data/input/`
3. Upload your training images (15-30 images recommended)
4. Optionally create `.txt` files with captions for each image

#### Configure Training

1. In Jupyter, open `/workspace/ai-toolkit/config/sdxl_lora_template.yaml` or `flux_lora_template.yaml`
2. Edit the configuration:
   - Set your trigger word
   - Adjust training steps (1000-2000 typical)
   - Configure learning rate
   - Set resolution

#### Start Training

Option 1 - Using Jupyter Terminal:
```bash
cd /workspace/ai-toolkit
bash launch_training.sh
```

Option 2 - Direct command:
```bash
cd /workspace/ai-toolkit
python run.py config/your_config.yaml
```

Trained LoRAs will be saved to `/workspace/training_data/output/`

### Downloading Additional Models

#### Via Model & Nodes Manager (Recommended)

1. Open Model & Nodes Manager at port 7860
2. Go to "Download" tab
3. Paste the model URL from HuggingFace or CivitAI
4. Select the model type
5. Click Download

#### Via ComfyUI Manager

1. In ComfyUI, click the "Manager" button
2. Go to "Install Models"
3. Search and install models directly

#### Manual Download via Jupyter

1. Open Jupyter Lab terminal
2. Navigate to the appropriate model directory:
   ```bash
   cd /workspace/ComfyUI/models/checkpoints  # For checkpoints
   cd /workspace/ComfyUI/models/loras        # For LoRAs
   ```
3. Download using wget or curl:
   ```bash
   wget https://huggingface.co/path/to/model.safetensors
   ```

#### Using Jupyter File Upload

1. Navigate to the target folder in Jupyter
2. Click the upload button
3. Select and upload your model files

## Persistent Storage (Network Volumes)

To keep your models and outputs between pod restarts:

1. Create a Network Volume in RunPod
2. Attach it to your pod at `/runpod-volume`
3. The startup script will automatically:
   - Move models to persistent storage
   - Create symlinks for seamless access
   - Preserve outputs across restarts

## Optimization Tips

### For RTX 4090/5090

- Models load faster with `fp16` precision
- Use `--highvram` flag if you have 24GB+ VRAM
- Enable `xformers` for memory efficiency (included)

### Memory Management

Edit `/workspace/scripts/start.sh` and adjust:

```bash
export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128
```

For 48GB GPUs, increase to:
```bash
export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.8,max_split_size_mb:256
```

## Troubleshooting

### ComfyUI Won't Start

Check logs in Jupyter terminal:
```bash
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188
```

### Missing Nodes Error

1. Go to ComfyUI Manager
2. Click "Install Missing Nodes"
3. Restart ComfyUI

### Models Not Loading

Check if models exist:
```bash
ls -lh /workspace/ComfyUI/models/checkpoints/
ls -lh /workspace/ComfyUI/models/loras/
```

Manually download if needed using Jupyter.

### GPU Not Detected

Ensure RunPod pod has GPU selected. Check with:
```bash
nvidia-smi
```

## Customization

### Adding More Custom Nodes

Custom nodes are now managed through the Model & Nodes Manager UI. To add additional nodes to the one-click installer:

1. Edit `scripts/model_downloader.py`
2. Add your node to the `CUSTOM_NODES` list:
   ```python
   {"name": "YourNodeName", "url": "https://github.com/username/YourNode.git"},
   ```
3. Rebuild and push the Docker image

Alternatively, you can manually install nodes via Jupyter:
```bash
cd /workspace/ComfyUI/custom_nodes
git clone https://github.com/username/CustomNode.git
cd CustomNode && pip install -r requirements.txt
```

### Pre-downloading Specific Models

Edit `scripts/download_models.sh` and add download commands:

```bash
download_hf "repo/name" "model.safetensors" "$CHECKPOINT_DIR/model.safetensors"
```

### Custom Workflows

Place `.json` workflow files in `workflows/` directory before building. They'll be available in ComfyUI.

## System Requirements

### Minimum
- GPU: RTX 3080 (10GB VRAM)
- RAM: 16GB
- Storage: 150GB container disk

### Recommended
- GPU: RTX 4090/5090 (24GB+ VRAM)
- RAM: 32GB+
- Storage: 150GB container disk + network volume for persistence

## Ports Reference

- **8188**: ComfyUI web interface
- **8888**: Jupyter Lab
- **7860**: Model & Nodes Manager
- **7861**: AI-Toolkit UI (if available)

## License

This template bundles multiple open-source projects. Please respect individual licenses:

- ComfyUI: GPL-3.0
- AI-Toolkit: Apache-2.0
- Individual custom nodes: Various (check each repository)

## Credits

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [AI-Toolkit](https://github.com/ostris/ai-toolkit)
- [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager)
- All custom node developers

## Support

For issues specific to this template, check:
1. RunPod pod logs
2. Jupyter terminal outputs
3. ComfyUI console

For ComfyUI or node-specific issues, refer to their respective GitHub repositories.

---

**Ready to deploy?** Build the image, push to Docker Hub, create your RunPod template, and start generating!
