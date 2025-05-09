# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.11

RUN pip install --no-cache-dir pipenv

WORKDIR /workspace

# Avoid interactive prompts & ensure deterministic builds
ENV PIPENV_VENV_IN_PROJECT=1