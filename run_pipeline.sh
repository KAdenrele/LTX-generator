#!/bin/bash
set -e

# Define directories mapped to your host machine
MODEL_DIR="/workspace/LTX-2/LTX-Models"
GEMMA_DIR="/workspace/LTX-2/Gemma-Models"
OUTPUT_DIR="/workspace/LTX-2/outputs"

mkdir -p "$OUTPUT_DIR"

echo "--- Step 1: Downloading Specific LTX-2.3 Models ---"
# Selectively download ONLY the files you explicitly requested
huggingface-cli download Lightricks/LTX-2.3 \
    ltx-2.3-22b-dev.safetensors \
    ltx-2.3-spatial-upscaler-x2-1.0.safetensors \
    ltx-2.3-spatial-upscaler-x1.5-1.0.safetensors \
    ltx-2.3-temporal-upscaler-x2-1.0.safetensors \
    ltx-2.3-22b-distilled-lora-384.safetensors \
    --local-dir "$MODEL_DIR"

echo "--- Step 2: Downloading Gemma Text Encoder ---"
# LTX-2.3 requires the Gemma text encoder to interpret your prompts.
if [ -z "$HF_TOKEN" ]; then
    echo "[!] Warning: HF_TOKEN is not set. Gemma download might fail if it's a gated model."
fi
# Note: Ensure you have accepted Google's terms on Hugging Face for Gemma 2!
huggingface-cli download google/gemma-3-12b-it --local-dir "$GEMMA_DIR" --token "$HF_TOKEN"

echo "--- Step 3: Processing Prompts ---"
if [ ! -f "prompts.txt" ]; then
    echo "[!] Error: prompts.txt not found!"
    exit 1
fi

# Disable exit-on-error so the loop continues even if one prompt fails
set +e

while IFS= read -r prompt || [ -n "$prompt" ]; do
    prompt=$(echo "$prompt" | xargs)

    if [[ -z "$prompt" || "$prompt" == \#* ]]; then
        continue
    fi

    # Create safe filename and skip if it already exists
    SAFE_NAME=$(echo "$prompt" | cut -c 1-50 | tr -dc '[:alnum:]_ ' | tr ' ' '_').mp4
    OUTPUT_FILE="$OUTPUT_DIR/$SAFE_NAME"

    if [ -f "$OUTPUT_FILE" ]; then
        echo "[*] Skipping (already exists): $SAFE_NAME"
        continue
    fi

    echo ""
    echo "[->] Generating video for: '$prompt'"
    
    # Run the official LTX pipeline using the explicit file paths
    python -m ltx_pipelines.ti2vid_two_stages \
        --checkpoint-path "$MODEL_DIR/ltx-2.3-22b-dev.safetensors" \
        --distilled-lora "$MODEL_DIR/ltx-2.3-22b-distilled-lora-384.safetensors" 0.8 \
        --spatial-upsampler-path "$MODEL_DIR/ltx-2.3-spatial-upscaler-x2-1.0.safetensors" \
        --gemma-root "$GEMMA_DIR" \
        --prompt "$prompt" \
        --output-path "$OUTPUT_FILE"

done < prompts.txt

echo "--- Pipeline Complete! ---"