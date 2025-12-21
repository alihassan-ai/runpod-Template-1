#!/bin/bash
set -e

echo "========================================="
echo "Installing AI-Toolkit for LoRA Training"
echo "========================================="

cd /workspace

# Clone AI-Toolkit
if [ ! -d "ai-toolkit" ]; then
    echo "Cloning AI-Toolkit repository..."
    git clone https://github.com/ostris/ai-toolkit.git
    cd ai-toolkit
else
    echo "AI-Toolkit already exists, updating..."
    cd ai-toolkit
    git pull
fi

# Install AI-Toolkit dependencies
echo "Installing AI-Toolkit dependencies..."
pip install -r requirements.txt

# Install additional dependencies for Flux/SDXL training
pip install -q \
    huggingface-hub \
    wandb \
    tensorboard \
    bitsandbytes \
    lycoris-lora \
    peft \
    prodigyopt

# Create config directory
mkdir -p /workspace/ai-toolkit/config

# Create a default training config for SDXL LoRA
cat > /workspace/ai-toolkit/config/sdxl_lora_template.yaml << 'EOL'
job: extension
config:
  name: sdxl_lora_training
  process:
    - type: sd_trainer
      training_folder: /workspace/training_data
      device: cuda:0
      network:
        type: lora
        linear: 16
        linear_alpha: 16
      save:
        dtype: float16
        save_every: 250
        max_step_saves_to_keep: 3
      datasets:
        - folder_path: /workspace/training_data/input
          caption_ext: txt
          caption_type: filename
          resolution: [1024, 1024]
          batch_size: 1
      train:
        steps: 1500
        lr: 1e-4
        lr_scheduler: constant
        optimizer: adamw8bit
        gradient_accumulation_steps: 1
      model:
        name_or_path: stabilityai/stable-diffusion-xl-base-1.0
        is_xl: true
      sample:
        sampler: ddpm
        sample_every: 250
        width: 1024
        height: 1024
        prompts:
          - "a photo of [trigger]"
        neg: "blurry, low quality"
        seed: 42
        walk_seed: true
        guidance_scale: 7
        sample_steps: 20
EOL

# Create a default training config for Flux LoRA
cat > /workspace/ai-toolkit/config/flux_lora_template.yaml << 'EOL'
job: extension
config:
  name: flux_lora_training
  process:
    - type: sd_trainer
      training_folder: /workspace/training_data
      device: cuda:0
      network:
        type: lora
        linear: 16
        linear_alpha: 16
      save:
        dtype: float16
        save_every: 250
        max_step_saves_to_keep: 3
      datasets:
        - folder_path: /workspace/training_data/input
          caption_ext: txt
          caption_type: filename
          resolution: [1024, 1024]
          batch_size: 1
      train:
        steps: 1500
        lr: 4e-4
        lr_scheduler: constant
        optimizer: adamw8bit
        gradient_accumulation_steps: 1
      model:
        name_or_path: black-forest-labs/FLUX.1-dev
        is_flux: true
      sample:
        sampler: flowmatch
        sample_every: 250
        width: 1024
        height: 1024
        prompts:
          - "a photo of [trigger]"
        seed: 42
        walk_seed: true
        guidance_scale: 3.5
        sample_steps: 20
EOL

# Create a simple launcher script
cat > /workspace/ai-toolkit/launch_training.sh << 'EOL'
#!/bin/bash
echo "AI-Toolkit Training Launcher"
echo "=============================="
echo ""
echo "Available configs:"
ls -1 /workspace/ai-toolkit/config/*.yaml
echo ""
read -p "Enter config filename (or full path): " config_file

if [ ! -f "$config_file" ]; then
    config_file="/workspace/ai-toolkit/config/$config_file"
fi

if [ -f "$config_file" ]; then
    echo "Starting training with $config_file..."
    python run.py "$config_file"
else
    echo "Config file not found: $config_file"
    exit 1
fi
EOL

chmod +x /workspace/ai-toolkit/launch_training.sh

# Create training data directories
mkdir -p /workspace/training_data/input
mkdir -p /workspace/training_data/output

echo ""
echo "========================================="
echo "AI-Toolkit Installation Complete!"
echo "========================================="
echo "Training configs created at: /workspace/ai-toolkit/config/"
echo "Place training images in: /workspace/training_data/input/"
echo "Launch training with: bash /workspace/ai-toolkit/launch_training.sh"
echo "========================================="
