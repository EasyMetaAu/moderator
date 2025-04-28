# ---------- Dockerfile ----------
FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

# 1. 基础依赖
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git wget curl python3 python3-pip && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# 2. Python 包（按 CUDA 12.2 对应 wheel 安装 Torch）
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir \
        torch==2.2.1+cu121 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121 \
 && pip install --no-cache-dir vllm bitsandbytes accelerate flashinfer

 # 3. 安装 FlashInfer 加速采样模块
RUN pip install --no-cache-dir flashinfer

# 4. 环境变量（可按需修改）
ENV MODEL_PATH=/models/phi4-gptq-int4
ENV VLLM_PORT=6085
WORKDIR /workspace

# 5. 默认启动 vLLM OpenAI-兼容 API
CMD ["bash", "-c", "\
python -m vllm.entrypoints.openai.api_server \
 --model ${MODEL_PATH} \
 --tensor-parallel-size 1 \
 --port ${VLLM_PORT}"]

