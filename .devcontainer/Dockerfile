# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.11-slim

# Avoid interactive prompts & ensure deterministic builds
ENV PIPENV_VENV_IN_PROJECT=1 \
    PIPENV_NOSPIN=1 \
    PYTHONUNBUFFERED=1

# Install pipenv
RUN pip install --no-cache-dir pipenv

# Copy only dependency manifests first (better layer caching)
COPY Pipfile* /workspace/

# Install deps – will be cached unless Pipfile.lock changes
RUN pipenv install --deploy --dev

# Copy the rest of the project
COPY . /workspace
WORKDIR /workspace

# Pre-download dbt packages so they’re cached too
RUN pipenv run dbt deps
