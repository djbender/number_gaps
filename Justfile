# Get the current git SHA
git_sha := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`

# Docker image base name
image_name := "registry.dokku.djbender.com/number_gaps"

# List available recipes
default:
    @just --list

# Build Docker image with git SHA for AMD64 and ARM64 platforms
build:
    docker buildx build --platform linux/amd64,linux/arm64 --build-arg GIT_SHA={{git_sha}} -t {{image_name}}:{{git_sha}} -t {{image_name}}:latest --push .

# Deploy to Dokku using SHA-tagged image
deploy:
    dokku git:from-image {{image_name}}:{{git_sha}}

# Build, and deploy
release: build deploy
