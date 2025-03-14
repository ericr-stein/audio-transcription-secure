FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/lib/x86_64-linux-gnu/
ENV PATH=$PATH:/usr/local/cuda/bin
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        wget \
        software-properties-common \
        && rm -rf /var/lib/apt/lists/*

# Install Python3 and pip
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install cuDNN 8 explicitly.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libcublas-12-2 \
        libcudnn8 \
        libcudnn8-dev \
        && rm -rf /var/lib/apt/lists/*

COPY . .

# Install Python dependencies using pip.
RUN python3 -m pip install --no-cache-dir -r requirements.txt

RUN chmod +x startup.sh
RUN sed -i 's/\r$//' /app/startup.sh

EXPOSE 8080

CMD ["./startup.sh"]
