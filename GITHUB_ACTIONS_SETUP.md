# GitHub Actions Setup - Build Docker Image in the Cloud

This guide shows you how to build your Docker image using GitHub's fast internet instead of your local connection.

## One-Time Setup (5 minutes)

### 1. Create Docker Hub Access Token

1. Go to: https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name: `github-actions`
4. Permissions: `Read & Write`
5. Click "Generate"
6. **Copy the token** (you won't see it again!)

### 2. Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:

   **Secret 1:**
   - Name: `DOCKER_USERNAME`
   - Value: `aidude0541`

   **Secret 2:**
   - Name: `DOCKER_PASSWORD`
   - Value: `[paste the access token from step 1]`

### 3. Push Your Code to GitHub

```bash
cd /Users/mac/Desktop/Nig/runpod-comfyui-template

# Initialize git if not already done
git init

# Add GitHub remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Add all files
git add .

# Commit
git commit -m "Add ultra-optimized ComfyUI template with GitHub Actions"

# Push to GitHub (this will trigger the build!)
git push -u origin main
```

## How It Works

Once you push to GitHub:

1. ✅ **GitHub Actions automatically triggers** (you'll see it in the "Actions" tab)
2. ✅ **Builds the Docker image in 2-3 minutes** (using GitHub's fast internet)
3. ✅ **Pushes to Docker Hub** (aidude0541/comfyui-runpod:latest)
4. ✅ **No more slow local internet issues!**

## Manual Trigger (Optional)

You can also trigger builds manually without pushing code:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click **Build and Push Docker Image** workflow
4. Click **Run workflow** button
5. Select branch and click **Run workflow**

## Monitoring the Build

1. Go to **Actions** tab in your GitHub repository
2. Click on the running workflow
3. Watch the build progress in real-time
4. Build completes in **2-3 minutes**

## After Build Completes

Your image is now on Docker Hub:
- **Image**: `aidude0541/comfyui-runpod:latest`
- **Size**: 10-11 GB
- **Build time**: 2-3 minutes
- **Ready to deploy on RunPod!**

## Deploy on RunPod

1. Go to RunPod: https://www.runpod.io/console/pods
2. Click "Deploy"
3. Select GPU (e.g., RTX 4090)
4. Under "Custom Image":
   - Image: `aidude0541/comfyui-runpod:latest`
   - Exposed Ports: `8188,8888,7860,7861`
5. Click "Deploy"
6. Wait 5-10 minutes for first-run setup
7. Access services at the URLs shown

## Troubleshooting

### Build fails?
- Check that secrets are set correctly in GitHub Settings
- Verify Docker Hub token has Read & Write permissions
- Check the Actions log for specific error messages

### Want to rebuild?
Just push any change to GitHub:
```bash
git add .
git commit -m "Update"
git push
```

Or use the manual trigger in the Actions tab.

---

**No more waiting for slow uploads! GitHub builds and pushes everything for you!** 🚀
