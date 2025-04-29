# Content Moderation API

A high-performance content moderation system powered by vLLM and phi-4-mini-instruct model, providing OpenAI-compatible API endpoints for text content safety analysis.

## 🚀 Features

- **High Performance**: Powered by vLLM with phi-4-mini-instruct model
- **OpenAI-Compatible API**: Easy integration with existing systems
- **Strict Safety Standards**: Comprehensive content moderation
- **Production-Ready**: Optimized for stability and reliability

## 🛠️ Technical Stack

- **Model**: phi-4-mini-instruct
- **Inference Engine**: vLLM
- **API**: OpenAI-compatible REST API

## 🚀 Getting Started

### Prerequisites

- Docker
- NVIDIA GPU with CUDA support
- Make (optional, for convenience)

### Quick Start

```bash
# Install dependencies and download model
make prereqs
make download

# Build and start the service
make build
make up

# Check service status
make ps
```

The API will be available at `http://localhost:6085/v1/chat/completions`

### Manual Setup

1. Build the Docker image:
```bash
docker compose build
```

2. Start the service:
```bash
docker compose up -d
```

### API Usage

Example request:
```python
import requests

response = requests.post(
    "http://localhost:6085/v1/chat/completions",
    json={
        "messages": [
            {
                "role": "user",
                "content": "Your text to analyze"
            }
        ],
        "temperature": 0,
        "max_tokens": 50
    }
)

print(response.json())
```

Example response:
```json
{
    "label": "SAFE",
    "reason": "None"
}
```

## 📋 Content Categories

The system analyzes text for:
- Violence or threats
- Hate speech or discriminatory language
- Pornographic or sexually explicit material
- Child sexual abuse material (CSAM)
- Terrorism or promotion of extremism
- Criminal activities

## 🔜 Roadmap

- [ ] Regional-specific moderation rules
- [ ] Batch processing support
- [ ] JSON output error handling

## 📄 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
