# AI SaaS Starter Kit

Enterprise-grade AI Solutions Template with Django, HTMX, and NVIDIA DGX integration.

## 🎯 Overview

A production-ready template for building AI-powered web applications with:
- **Modern UI**: DaisyUI + Tailwind CSS + HTMX (no JavaScript framework needed)
- **Microservices Architecture**: Django frontend + FastAPI GPU inference backend
- **Three Environments**: Mac (dev) → Lenovo (staging) → AWS (production)
- **GPU-Ready**: NVIDIA DGX Spark integration with Docker GPU support

## 🏗️ Architecture
```
┌─────────────────────────────────┐
│ Lenovo/AWS (Django Stack)       │
│ ├─ Django + HTMX UI             │
│ ├─ Postgres Database            │
│ ├─ Redis Cache                  │
│ ├─ Celery Workers               │
│ └─ Flower Monitoring            │
└─────────────────────────────────┘
         │ HTTP Requests
         ↓
┌─────────────────────────────────┐
│ DGX Spark (Inference Stack)     │
│ ├─ FastAPI Server               │
│ ├─ NVIDIA NIMs (Llama, Mistral) │
│ └─ GPU Acceleration             │
└─────────────────────────────────┘
```

## 🚀 Quick Start

### Development (Mac)
```bash
# Clone repository
git clone https://github.com/JW-AI-Solutions/ai-saas-starter-kit.git
cd ai-saas-starter-kit

# Start services
docker-compose up --build

# Run migrations
docker-compose exec web python src/manage.py migrate

# Create superuser
docker-compose exec web python src/manage.py createsuperuser

# Visit http://localhost:8000
```

### Staging (Lenovo)
```bash
# On Lenovo server
sudo ./deploy/lenovo-setup.sh

# Access at http://lenovo.local:8000
```

### DGX Setup
```bash
# On DGX Spark
./deploy/dgx-setup.sh

# Or manually with Docker Compose
docker-compose -f docker-compose.dgx.yml up -d
```

## 📦 Tech Stack

### Frontend
- Django 5.0
- HTMX 2.0
- DaisyUI 4.0
- Tailwind CSS

### Backend
- PostgreSQL 15
- Redis Stack
- Celery 5.3
- Flower (monitoring)

### AI Infrastructure
- FastAPI
- NVIDIA NIMs
- Docker with GPU support

## 🔧 Configuration

### Environment Files

- `.envs/.local/.django` - Mac development
- `.envs/.staging/.django` - Lenovo staging
- `.envs/.production/.django` - AWS production

### Docker Compose Files

- `docker-compose.yml` - Development
- `docker-compose.staging.yml` - Staging (with Celery + Flower)
- `docker-compose.dgx.yml` - DGX inference server

## 📚 Project Structure
```
ai-saas-starter-kit/
├── src/                      # Django application
│   ├── config/               # Settings (base, local, staging, production)
│   ├── core/                 # Main app
│   │   ├── templates/        # HTML templates
│   │   ├── services.py       # DGX API client
│   │   └── views.py          # View logic
├── dgx-server/               # FastAPI inference server
│   └── main.py               # GPU inference endpoints
├── deploy/                   # Deployment scripts
│   ├── lenovo-setup.sh       # Automate Lenovo deployment
│   └── dgx-setup.sh          # Automate DGX setup
├── Dockerfile                # Django container
├── Dockerfile.dgx            # FastAPI container
└── docker-compose*.yml       # Orchestration configs
```

## 🎨 Features

- ✅ Modern responsive UI with sidebar navigation
- ✅ Async inference with HTMX (no page refresh)
- ✅ API client service for DGX communication
- ✅ Health monitoring endpoints
- ✅ Celery for background tasks
- ✅ Flower dashboard for task monitoring
- ✅ Production-ready settings split
- ✅ Docker GPU support
- ✅ Auto-restart on failure

## 🔐 Security

- Non-root container users
- Environment-based secrets
- CSRF protection
- Separate staging/production configs
- Network isolation via Docker

## 📊 Monitoring

- **Django Admin**: `http://localhost:8000/admin`
- **Flower Dashboard**: `http://localhost:5555`
- **RedisInsight**: `http://localhost:8001`
- **FastAPI Docs**: `http://dgx-ip:8000/docs`

## 🧪 Development Workflow

1. **Develop on Mac** with hot reload
2. **Push to GitHub**
3. **Auto-deploy to Lenovo** (staging)
4. **Test with production-like setup**
5. **Deploy to AWS** (production)

## 📖 Documentation

- [Django Settings Guide](src/config/settings/)
- [DGX API Client](src/core/services.py)
- [FastAPI Endpoints](dgx-server/main.py)

## 🤝 Contributing

This is a template repository. Fork it and customize for your projects!

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Credits

Built for enterprise AI/ML solutions engineering portfolios.
