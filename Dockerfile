# syntax=docker/dockerfile:1
FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_SYSTEM_PYTHON=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY pyproject.toml ./

# Install dependencies with uv
RUN uv pip install --no-cache -e .

# Install gunicorn for production
RUN uv pip install gunicorn==21.2.0

# Copy application code
COPY src/ ./src/

# Create directories
RUN mkdir -p /app/staticfiles /app/media

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Default command (development)
CMD ["python", "src/manage.py", "runserver", "0.0.0.0:8000"]
