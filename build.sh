#!/bin/bash

# RunPod ComfyUI Template Builder
# This script builds and optionally pushes the Docker image

set -e

echo "========================================="
echo "RunPod ComfyUI Template Builder"
echo "========================================="
echo ""

# Get Docker username
read -p "Enter your Docker Hub username: " DOCKER_USER

if [ -z "$DOCKER_USER" ]; then
    echo "Error: Docker username is required"
    exit 1
fi

IMAGE_NAME="$DOCKER_USER/comfyui-runpod"
TAG="latest"
FULL_IMAGE="$IMAGE_NAME:$TAG"

echo ""
echo "Building image: $FULL_IMAGE"
echo ""

# Build the image
docker build \
    --tag "$FULL_IMAGE" \
    --progress=plain \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "Build successful!"
    echo "========================================="
    echo "Image: $FULL_IMAGE"
    echo ""

    # Ask if user wants to push
    read -p "Push to Docker Hub? (y/n): " PUSH_CHOICE

    if [ "$PUSH_CHOICE" = "y" ] || [ "$PUSH_CHOICE" = "Y" ]; then
        echo ""
        echo "Logging in to Docker Hub..."
        docker login

        echo ""
        echo "Pushing image..."
        docker push "$FULL_IMAGE"

        echo ""
        echo "========================================="
        echo "Push successful!"
        echo "========================================="
        echo ""
        echo "Next steps:"
        echo "1. Go to: https://www.runpod.io/console/serverless/user/templates"
        echo "2. Click 'New Template'"
        echo "3. Enter these details:"
        echo "   - Template Name: ComfyUI Pro (AI-Toolkit + Video)"
        echo "   - Container Image: $FULL_IMAGE"
        echo "   - Container Disk: 150 GB"
        echo "   - Expose HTTP Ports: 8188, 8888, 7860"
        echo "4. Save and note your template ID"
        echo "5. Your deploy link will be:"
        echo "   https://runpod.io/console/deploy?template=YOUR_TEMPLATE_ID"
        echo ""
    else
        echo ""
        echo "Skipping push. To push later, run:"
        echo "  docker push $FULL_IMAGE"
        echo ""
    fi

    # Ask if user wants to test locally
    read -p "Test locally? (y/n): " TEST_CHOICE

    if [ "$TEST_CHOICE" = "y" ] || [ "$TEST_CHOICE" = "Y" ]; then
        echo ""
        echo "Starting local test..."
        echo "Access at:"
        echo "  - ComfyUI: http://localhost:8188"
        echo "  - Jupyter: http://localhost:8888"
        echo ""
        echo "Press Ctrl+C to stop"
        echo ""

        docker run -it --rm \
            --gpus all \
            -p 8188:8188 \
            -p 8888:8888 \
            -p 7860:7860 \
            "$FULL_IMAGE"
    fi

else
    echo ""
    echo "========================================="
    echo "Build failed!"
    echo "========================================="
    echo "Please check the error messages above."
    exit 1
fi
