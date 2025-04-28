# ---------- Dockerfile ----------
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

# 1. 基础依赖
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git wget curl python3 python3-pip python3-venv && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# 创建并激活虚拟环境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 2. Python 包（按 CUDA 12.2 对应 wheel 安装 Torch）
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir \
 torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 \
 && pip install --no-cache-dir vllm bitsandbytes accelerate

 # 3. 安装 FlashInfer 加速采样模块
RUN pip install --no-cache-dir flashinfer-python==0.2.2

# 4. 环境变量（可按需修改）
ENV MODEL_PATH=/models/phi4-gptq-int4
ENV VLLM_PORT=6085
WORKDIR /workspace

# 5. 默认启动 vLLM OpenAI-兼容 API
CMD ["bash", "-c", "\
python -m vllm.entrypoints.openai.api_server \
 --model ${MODEL_PATH} \
 --tensor-parallel-size 1 \
 --gpu-memory-utilization 0.9 \
 --port ${VLLM_PORT}"]

