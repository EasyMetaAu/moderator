# =====================  Makefile  ===================== #
# 默认目标：显示帮助信息
.DEFAULT_GOAL := help

# -------- 可自定义变量 --------
MODEL_DIR := models/phi4-gptq-int4
HF_MODEL  := jakiAJK/microsoft-phi-4_GPTQ-int4
COMPOSE   := docker compose
PORT      := 6085            # OpenAI-兼容 API 暴露端口

# -------- 帮助信息 --------
.PHONY: help
help:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@echo "  help       - Show this help message"
	@echo "  prereqs    - Install/check CLI dependencies (pipx + huggingface-cli)"
	@echo "  download   - Download the phi-4 GPTQ-int4 model (skip if exists)"
	@echo "  build      - Build the Docker image (runs download first)"
	@echo "  up         - Start the vLLM service in background"
	@echo "  down       - Stop the vLLM service"
	@echo "  restart    - Restart the vLLM service (down then up)"
	@echo "  logs       - Tail the last 80 lines of service logs"
	@echo "  ps         - List running containers"
	@echo ""
	@echo "Examples:"
	@echo "  make             # show help"
	@echo "  make download    # fetch model"
	@echo "  make build       # build Docker image"
	@echo "  make up          # launch service"
	@echo "  make logs        # view logs"
	@echo ""

# -------- 0. 依赖检查（pipx → huggingface-cli）--------
.PHONY: prereqs
prereqs:
	@echo "🔎 Checking dependencies …"
	@if command -v huggingface-cli >/dev/null ; then \
		echo "✔ huggingface-cli already present." ; \
	else \
		echo "🤖 huggingface-cli not found – installing via pipx …" ; \
		if command -v pipx >/dev/null ; then \
			pipx install --force 'huggingface_hub[cli]' ; \
		else \
			sudo apt update && sudo apt install -y pipx && \
			pipx ensurepath && \
			pipx install --force 'huggingface_hub[cli]' ; \
		fi ; \
	fi
	@command -v huggingface-cli >/dev/null || (echo "❌ huggingface-cli still not available. Aborting."; exit 1)
	@echo "✔ Dependencies ready."

# -------- 1. 模型下载（若已存在则跳过）--------
.PHONY: download
download: prereqs
	@if [ -d "$(MODEL_DIR)" ]; then \
		echo "✔ Model already exists – skip download."; \
	else \
		echo "⤵  Downloading $(HF_MODEL) …"; \
		mkdir -p $(MODEL_DIR) && \
		huggingface-cli download $(HF_MODEL) \
			--local-dir $(MODEL_DIR) ; \
	fi

# -------- 2. Docker 构建 --------
.PHONY: build
build: download
	@$(COMPOSE) build

# -------- 3. 后台启动服务 --------
.PHONY: up
up:
	@$(COMPOSE) up -d
	@echo "🚀 vLLM service is running on http://localhost:$(PORT)"

# -------- 4. 关闭服务 --------
.PHONY: down
down:
	@$(COMPOSE) down

# -------- 5. 重启服务 --------
.PHONY: restart
restart: down up
	@echo "🔄 Service restarted."

# -------- 6. 查看实时日志 --------
.PHONY: logs
logs:
	@$(COMPOSE) logs -f --tail=80

# -------- 7. 查看容器状态 --------
.PHONY: ps
ps:
	@$(COMPOSE) ps
# ===================================================== #

