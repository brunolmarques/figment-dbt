# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.11

RUN pip install --no-cache-dir pipenv

WORKDIR /workspace

# Avoid interactive prompts & ensure deterministic builds
ENV PIPENV_VENV_IN_PROJECT=1

COPY .devcontainer/git-aliases.conf /etc/git-aliases.conf
RUN git config --system include.path /etc/git-aliases.conf