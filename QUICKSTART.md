# Quick Start Guide

Get your RunPod ComfyUI template up and running in minutes.

## Local Testing (Optional)

Test the template locally before deploying to RunPod:

```bash
# Build the image
docker build -t comfyui-runpod:latest .

# Run with docker-compose (recommended)
docker-compose up

# Or run directly
docker run -it --gpus all \
  -p 8188:8188 -p 8888:8888 -p 7860:7860 \
  comfyui-runpod:latest
```

Access locally at:
- ComfyUI: http://localhost:8188
- Jupyter: http://localhost:8888

## Deploy to RunPod

### Quick Deploy (3 Steps)

#### 1. Build & Push

```bash
# Set your Docker Hub username
DOCKER_USER="your-username"

# Build
docker build -t $DOCKER_USER/comfyui-runpod:latest .

# Login to Docker Hub
docker login

# Push
docker push $DOCKER_USER/comfyui-runpod:latest
```

#### 2. Create Template

1. Go to https://www.runpod.io/console/serverless/user/templates
2. Click **"New Template"**
3. Configure:
   ```
   Template Name: ComfyUI Pro (AI-Toolkit + Video)
   Container Image: your-username/comfyui-runpod:latest
   Container Disk: 150 GB
   Expose HTTP: 8188, 8888, 7860
   ```
4. Click **"Save Template"**

#### 3. Deploy

1. Note your template ID from the URL
2. Your deploy link: `https://runpod.io/console/deploy?template=YOUR_TEMPLATE_ID`
3. Click to deploy instantly!

## First Run Checklist

After deployment:

- [ ] Access ComfyUI (will auto-download models, ~15-30 min for ~35GB)
- [ ] Wait for initial model downloads to complete
- [ ] Test generation with pre-installed checkpoints
- [ ] (Optional) Download additional models via ComfyUI Manager
- [ ] Open Jupyter to upload training images (if training LoRAs)

## Common First Tasks

### Generate Your First Image

1. Open ComfyUI interface
2. Load default workflow (or create new)
3. Add a checkpoint from Manager if needed
4. Enter your prompt
5. Click "Queue Prompt"

### Download a Checkpoint

**Via ComfyUI Manager:**
1. Click "Manager" button
2. "Install Models" tab
3. Search for "Realistic Vision XL" or "DreamShaper XL"
4. Click Install

**Via Jupyter:**
1. Open Jupyter terminal
2. Navigate: `cd /workspace/ComfyUI/models/checkpoints`
3. Download: `wget https://huggingface.co/.../model.safetensors`

### Train Your First LoRA

1. Upload 15-30 images via Jupyter to `/workspace/training_data/input/`
2. Open Jupyter terminal
3. Edit config: `nano /workspace/ai-toolkit/config/sdxl_lora_template.yaml`
4. Update trigger word and settings
5. Run: `cd /workspace/ai-toolkit && bash launch_training.sh`
6. Wait 20-60 minutes (depends on GPU)
7. Find trained LoRA in `/workspace/training_data/output/`

## Recommended Settings

### For RTX 4090 (24GB)
```yaml
batch_size: 1-2
resolution: [1024, 1024]
gradient_accumulation: 1
steps: 1500
```

### For RTX 5090 (32GB)
```yaml
batch_size: 2-4
resolution: [1024, 1024]
gradient_accumulation: 1
steps: 2000
```

## Need Help?

- Check logs in Jupyter terminal
- Review `/workspace/DOWNLOAD_INSTRUCTIONS.txt` for model sources
- Restart services via RunPod console if needed

## Next Steps

- Explore custom workflows
- Install video generation models via Manager
- Configure AnimateDiff for video output
- Set up network volume for persistent storage

---

**You're all set!** Start creating amazing content with your fully-loaded ComfyUI instance.
