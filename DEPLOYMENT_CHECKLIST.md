# RunPod Template Deployment Checklist

Use this checklist to ensure a smooth deployment process.

## Pre-Build Checklist

- [ ] Docker installed and running
- [ ] NVIDIA Docker runtime installed (for local testing)
- [ ] Docker Hub account created
- [ ] RunPod account created
- [ ] (Optional) Custom workflows added to `workflows/` directory
- [ ] (Optional) Modified scripts in `scripts/` directory for your needs

## Build Process

- [ ] Run `./build.sh` or manually build:
  ```bash
  docker build -t your-username/comfyui-runpod:latest .
  ```
- [ ] (Optional) Test locally:
  ```bash
  docker-compose up
  # OR
  docker run -it --gpus all -p 8188:8188 -p 8888:8888 your-username/comfyui-runpod:latest
  ```
- [ ] Verify ComfyUI loads at http://localhost:8188
- [ ] Verify Jupyter loads at http://localhost:8888

## Push to Docker Hub

- [ ] Login to Docker Hub:
  ```bash
  docker login
  ```
- [ ] Push image:
  ```bash
  docker push your-username/comfyui-runpod:latest
  ```
- [ ] Verify image appears in your Docker Hub repositories

## Create RunPod Template

- [ ] Navigate to [RunPod Templates](https://www.runpod.io/console/serverless/user/templates)
- [ ] Click "New Template"
- [ ] Fill in details:
  - **Template Name**: `ComfyUI Pro (AI-Toolkit + Video)`
  - **Container Image**: `your-username/comfyui-runpod:latest`
  - **Docker Command**: (leave empty)
  - **Container Disk**: `150 GB`
  - **Volume Disk**: (optional, for persistent storage)
  - **Expose HTTP Ports**: `8188, 8888, 7860`
  - **Expose TCP Ports**: (leave empty)
  - **Environment Variables**: (optional, none required by default)

- [ ] Click "Save Template"
- [ ] Note your template ID from the URL

## Deploy Link

Your shareable deploy link format:
```
https://runpod.io/console/deploy?template=YOUR_TEMPLATE_ID
```

- [ ] Test the deploy link
- [ ] Bookmark or save the deploy link

## First Deployment Test

- [ ] Deploy a pod using your template
- [ ] Wait for pod to start (2-5 minutes)
- [ ] Access ComfyUI at `https://YOUR_POD_ID-8188.proxy.runpod.net`
- [ ] Verify auto-download of base models completes
- [ ] Access Jupyter at `https://YOUR_POD_ID-8888.proxy.runpod.net`
- [ ] Test generating an image in ComfyUI
- [ ] Check ComfyUI Manager is accessible
- [ ] Verify GPU is detected (check ComfyUI console logs)

## Post-Deployment Configuration

- [ ] Download preferred checkpoints via ComfyUI Manager
- [ ] Test workflow loading
- [ ] Upload test training images via Jupyter (if using AI-Toolkit)
- [ ] Verify all custom nodes loaded without errors
- [ ] (Optional) Attach network volume for persistent storage
- [ ] (Optional) Configure auto-shutdown to save costs

## Optional: Network Volume Setup

For persistent storage across pod restarts:

- [ ] Create a Network Volume in RunPod
- [ ] Set mount path to `/runpod-volume`
- [ ] Attach to your pod
- [ ] Verify startup script creates symlinks
- [ ] Test that models persist after pod restart

## Troubleshooting

If you encounter issues:

- [ ] Check pod logs in RunPod console
- [ ] Access Jupyter terminal to check service status
- [ ] Verify GPU availability: `nvidia-smi`
- [ ] Check ComfyUI logs: `tail -f /workspace/ComfyUI/comfyui.log`
- [ ] Restart services via pod console if needed

## Cost Optimization

- [ ] Set auto-pause/stop timers in RunPod
- [ ] Use Spot instances for training (cheaper)
- [ ] Use On-Demand for production workflows
- [ ] Monitor GPU utilization to select right tier
- [ ] Delete unused pods when not in use

## Security Checklist

- [ ] Don't expose sensitive ports publicly
- [ ] Use RunPod's proxy URLs (already secured)
- [ ] Don't commit sensitive data to Docker image
- [ ] Consider setting Jupyter password (edit start.sh)
- [ ] Use network volumes for sensitive training data

---

## Quick Reference

**Build**: `./build.sh`

**Local Test**: `docker-compose up`

**Push**: `docker push your-username/comfyui-runpod:latest`

**Template URL**: https://www.runpod.io/console/serverless/user/templates

**Deploy Link**: `https://runpod.io/console/deploy?template=YOUR_TEMPLATE_ID`

---

**Ready?** Start with the pre-build checklist and work your way down!
