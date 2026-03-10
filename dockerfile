# 1. Base Image
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-devel

# Install system dependencies (git, ffmpeg for video handling, etc.)
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy uv binaries from astral-sh
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /workspace

# 2. Clone the repository
RUN git clone https://github.com/Lightricks/LTX-2.git
WORKDIR /workspace/LTX-2

# 3. Sync the environment using uv
RUN uv sync

# Add the .venv to the system PATH so it's activated permanently in the container
ENV PATH="/workspace/LTX-2/.venv/bin:$PATH"

# 4. Install huggingface-cli for the downloads
RUN pip install --no-cache-dir "huggingface_hub[cli]"

# 5. Bring in your execution files
COPY prompts.txt .
COPY run_pipeline.sh .
RUN chmod +x run_pipeline.sh

# Mount volumes to save the models and output videos permanently
VOLUME ["/workspace/LTX-2/LTX-Models", "/workspace/LTX-2/Gemma-Models", "/workspace/LTX-2/outputs"]

CMD ["./run_pipeline.sh"]