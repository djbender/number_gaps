# Get the current git SHA
git_sha := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`

# Docker image tag
image_tag := "registry.dokku.djbender.com/number_gaps"

# List available recipes
default:
    @just --list

# Build Docker image with git SHA
build:
    docker build --build-arg GIT_SHA={{git_sha}} -t {{image_tag}} .

# Push Docker image
push:
    docker push {{image_tag}}

# Deploy to Dokku
deploy:
    dokku git:from-image number-gaps {{image_tag}}:latest

# Build, push, and deploy
release: build push deploy
