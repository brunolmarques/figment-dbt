.PHONY: install deps clean compile run test lint run-test po

# Install dependencies
install:
	pipenv install

# Install dbt dependencies
deps:
	pipenv run dbt deps

# Clean dbt artifacts
clean:
	pipenv run dbt clean

# Compile dbt models
compile:
	pipenv run dbt compile

# Build dbt models
build:
	pipenv run dbt build

# Run dbt models
run:
	pipenv run dbt run

# Run dbt tests
test:
	pipenv run dbt test

# Run dbt linter
lint:
	pipenv run dbt lint

# Clean and reinstall everything
reset: clean
	rm -rf dbt_packages/*
	pipenv install
	pipenv run dbt deps

# Generate dbt docs and serve
docs:
	pipenv run dbt docs generate
	pipenv run dbt docs serve

# Git push current branch to origin
po:
	git push -u origin $$(git branch --show-current)

# Show help
help:
	@echo "Available commands:"
	@echo "  make install    - Install pipenv dependencies"
	@echo "  make deps       - Install dbt dependencies"
	@echo "  make clean      - Clean dbt artifacts"
	@echo "  make compile    - Compile dbt models"
	@echo "  make build      - Build dbt models"
	@echo "  make run        - Run dbt models"
	@echo "  make test       - Run dbt models and then run tests"
	@echo "  make lint       - Run dbt linter"
	@echo "  make reset      - Clean and reinstall everything"
	@echo "  make docs       - Generate dbt docs and serve"
	@echo "  make po         - Push current branch to origin"
	@echo "  make help       - Show this help message" 