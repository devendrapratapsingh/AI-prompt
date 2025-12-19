# Drone CI - Complete Container-Native CI/CD Guide

## Overview

Drone is a self-service Continuous Integration platform that uses Docker containers to run your tests and build applications. It can be deployed on Kubernetes or Linux, and integrates with GitHub, GitLab, Gitea, and Bitbucket.

### Key Capabilities
- **Container-Native**: All builds run in Docker containers
- **Self-Hosted**: Run on your own infrastructure
- **Cloud-Agnostic**: Works with any cloud provider
- **Kubernetes Support**: Deploy natively on Kubernetes
- **Distributed Builds**: Scale across multiple agents
- **Simple YAML**: Easy-to-understand pipeline syntax
- **Plugins**: Extensive plugin ecosystem
- **Secrets Management**: Built-in secret management
- **Matrix Builds**: Test multiple configurations in parallel

## Prerequisites

- Docker installed
- Source repository (GitHub, GitLab, Gitea, Bitbucket)
- For self-hosted: Linux server or Kubernetes cluster
- Basic Docker knowledge

## Installation & Setup

### Step 1: Install Drone

**Docker Compose:**
```yaml
version: '3.8'
services:
  drone-server:
    image: drone/drone:latest
    container_name: drone-server
    ports:
      - "80:80"
      - "443:443"
    environment:
      - DRONE_GITHUB_SERVER=https://github.com
      - DRONE_GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
      - DRONE_GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
      - DRONE_RPC_SECRET=$(openssl rand -hex 16)
      - DRONE_SERVER_HOST=drone.example.com
      - DRONE_SERVER_PROTO=https
    volumes:
      - drone-data:/data
    restart: unless-stopped

  drone-runner:
    image: drone/drone-runner-docker:latest
    container_name: drone-runner
    ports:
      - "3000:3000"
    environment:
      - DRONE_RPC_HOST=drone-server
      - DRONE_RPC_PROTO=http
      - DRONE_RPC_SECRET=$(openssl rand -hex 16)
      - DRONE_RUNNER_CAPACITY=2
      - DRONE_RUNNER_NAME=docker-runner
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - drone-server
    restart: unless-stopped

volumes:
  drone-data:
```

### Step 2: Create .drone.yml

```yaml
kind: pipeline
type: docker
name: ci-pipeline

trigger:
  branch:
    - main
    - develop
  event:
    - push
    - pull_request

steps:
  - name: build
    image: node:18-alpine
    commands:
      - npm ci
      - npm run build

  - name: test
    image: node:18-alpine
    commands:
      - npm test -- --coverage

  - name: lint
    image: node:18-alpine
    commands:
      - npm run lint

  - name: docker-build
    image: plugins/docker
    settings:
      username:
        from_secret: docker_username
      password:
        from_secret: docker_password
      repo: myorg/myapp
      tags:
        - latest
        - ${DRONE_COMMIT_SHA:0:8}
```

## Complete Configuration

```yaml
kind: pipeline
type: docker
name: complete-ci-pipeline

trigger:
  branch:
    include:
      - main
      - develop
      - feature/*

variables:
  - shared_volume: /workspace

workspace:
  base: /workspace
  path: src

steps:
  # Build Stage
  - name: build
    image: node:18-alpine
    commands:
      - npm ci --prefer-offline
      - npm run build
    volumes:
      - name: workspace
        path: /workspace

  # Test Stage
  - name: unit-test
    image: node:18-alpine
    commands:
      - npm test:unit -- --coverage
    volumes:
      - name: workspace
        path: /workspace
    depends_on:
      - build

  - name: integration-test
    image: node:18-alpine
    commands:
      - npm test:integration
    volumes:
      - name: workspace
        path: /workspace
    depends_on:
      - build

  # Quality Stage
  - name: code-quality
    image: node:18-alpine
    commands:
      - npm run lint
      - npm run format:check
    volumes:
      - name: workspace
        path: /workspace
    depends_on:
      - build

  # Docker Build
  - name: docker-build
    image: plugins/docker
    settings:
      username:
        from_secret: docker_username
      password:
        from_secret: docker_password
      repo: registry.example.com/myapp
      tags:
        - ${DRONE_COMMIT_SHA:0:8}
        - latest
    volumes:
      - name: docker
        path: /var/run/docker.sock
    depends_on:
      - unit-test
      - code-quality

  # Deploy Staging
  - name: deploy-staging
    image: alpine:latest
    environment:
      DEPLOY_KEY:
        from_secret: deploy_key
    commands:
      - apk add --no-cache openssh-client rsync
      - mkdir -p ~/.ssh && echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
      - chmod 600 ~/.ssh/deploy_key
      - rsync -avz -e "ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no" dist/ deploy@staging:/app/
    when:
      branch: develop
      event: push
    depends_on:
      - docker-build

  # Deploy Production
  - name: deploy-production
    image: alpine:latest
    environment:
      DEPLOY_KEY:
        from_secret: prod_deploy_key
    commands:
      - apk add --no-cache openssh-client rsync
      - mkdir -p ~/.ssh && echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
      - chmod 600 ~/.ssh/deploy_key
      - rsync -avz -e "ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no" dist/ deploy@prod:/app/
    when:
      branch: main
      event: push
    depends_on:
      - docker-build

volumes:
  - name: workspace
    temp: {}
  - name: docker
    host:
      path: /var/run/docker.sock

# Matrix builds
---
kind: pipeline
type: docker
name: matrix-tests

matrix:
  include:
    - NODE_VERSION: "16"
    - NODE_VERSION: "18"
    - NODE_VERSION: "20"

steps:
  - name: test
    image: node:${NODE_VERSION}-alpine
    commands:
      - npm ci
      - npm test
```

## Kubernetes Integration

```yaml
kind: pipeline
type: kubernetes
name: k8s-pipeline

steps:
  - name: deploy
    image: alpine/helm:latest
    commands:
      - helm upgrade --install myapp ./helm-chart
        --namespace production
        --values values.yaml
```

## Secrets Management

```bash
# Add secret via CLI
drone secret add -repository myorg/myrepo \
  -name docker_username -value myusername

drone secret add -repository myorg/myrepo \
  -name docker_password -value mypassword
```

Use in pipeline:
```yaml
environment:
  DOCKER_USERNAME:
    from_secret: docker_username
  DOCKER_PASSWORD:
    from_secret: docker_password
```

## FAQ

**Q: How do I run builds in parallel?**
A: Omit depends_on, Drone runs independent steps in parallel

**Q: Can I reuse steps across pipelines?**
A: Not directly, but you can create helper Docker images

**Q: What's the maximum execution time?**
A: Configurable per repository

**Q: How do I scale Drone?**
A: Add multiple runner instances

## Resources

- [Drone Documentation](https://docs.drone.io/)
- [Drone Plugins](https://plugins.drone.io/)
- [Configuration Reference](https://docs.drone.io/pipeline/overview/)
