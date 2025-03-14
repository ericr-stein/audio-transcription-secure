# Use a more specific base image that includes CUDA.
FROM nvidia/cuda:12.4.1-cudnn8-runtime-ubuntu22.04

# Set environment variables (crucial for correct behavior)
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/lib/x86_64-linux-gnu/
ENV PATH=$PATH:/usr/local/cuda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /app

# Install system dependencies.  apt-get update should *always* be in the same RUN as the installs.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        wget \
        software-properties-common \
        && rm -rf /var/lib/apt/lists/* # Clean up to reduce image size

# Install NVIDIA CUDA toolkit keyring (if needed for your base image)
# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb && \
#    dpkg -i cuda-keyring_1.1-1_all.deb && \
#     rm cuda-keyring_1.1-1_all.deb # Clean up

# If your base image *doesn't* have cuDNN, uncomment this.  Check version compatibility.
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#       cudnn9-cuda-12 && \
#     rm -rf /var/lib/apt/lists/* # Clean up

# Copy project files
COPY . .

# Install Python dependencies with uv. The uvx is not necessary.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/
RUN uv venv
ENV PATH="/app/.venv/bin:$PATH"
RUN uv sync --frozen

# Make startup script executable
RUN chmod +x startup.sh

# Expose the port NiceGUI will run on
EXPOSE 8080

# Start the application using the startup script
CMD ["./startup.sh"]