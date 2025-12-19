# Bitbucket Pipelines - Complete Enterprise-Grade CI/CD Guide

## Overview

Bitbucket Pipelines is Atlassian's native CI/CD platform integrated into Bitbucket Cloud. It uses Docker containers for builds and integrates seamlessly with Bitbucket repositories, Jira, and other Atlassian products.

### Key Capabilities
- **Docker-Based**: All builds run in Docker containers
- **Git-Based Configuration**: bitbucket-pipelines.yml in repository
- **Parallel Builds**: Run multiple jobs in parallel
- **Environments**: Manage secrets per environment
- **Deployment Environments**: Track deployments across environments
- **Merge Checks**: Run checks on pull requests before merge
- **Artifacts**: Store build outputs
- **SSH**: SSH debugging of failed builds
- **Scheduled Builds**: Cron-based pipeline triggers
- **Integration**: Jira, Slack, AWS, Azure, GCP

## Prerequisites

- Bitbucket Cloud account
- Git repository on Bitbucket
- Basic YAML knowledge
- For deployments: cloud account (AWS, Azure, GCP)

## Installation & Setup

### Step 1: Enable Pipelines

1. Go to Bitbucket repository
2. Pipelines → Settings
3. Enable pipelines
4. Grant necessary permissions

### Step 2: Create bitbucket-pipelines.yml

```yaml
image: node:18

pipelines:
  default:
    - step:
        name: Build
        script:
          - npm ci
          - npm run build

  branches:
    main:
      - step:
          name: Test
          script:
            - npm test
      - step:
          name: Deploy Production
          trigger: manual
          deployment: Production
          script:
            - ./deploy.sh production

    develop:
      - step:
          name: Test & Deploy Staging
          script:
            - npm test
            - ./deploy.sh staging
```

## Complete Configuration

```yaml
image: node:18

clone:
  depth: full

definitions:
  steps:
    - step: &build-step
        name: Build
        script:
          - npm ci
          - npm run build
        artifacts:
          - dist/**

    - step: &test-step
        name: Test
        script:
          - npm test -- --coverage
        after-script:
          - |
            if [ -d coverage ]; then
              bash <(curl -s https://codecov.io/bash)
            fi

    - step: &quality-step
        name: Code Quality
        script:
          - npm run lint
          - npm run format:check

    - step: &security-step
        name: Security Scan
        script:
          - npm audit --audit-level=moderate || true

    - step: &deploy-step
        name: Deploy
        script:
          - echo "Deploying to $ENVIRONMENT"
          - ./scripts/deploy.sh $ENVIRONMENT
        trigger: manual

pipelines:
  default:
    - step: *build-step
    - parallel:
        - step: *test-step
        - step: *quality-step
        - step: *security-step

  branches:
    develop:
      - step: *build-step
      - parallel:
          - step: *test-step
          - step: *quality-step
      - step:
          <<: *deploy-step
          name: Deploy to Staging
          deployment: Staging
          script:
            - npm ci
            - npm run build
            - ./scripts/deploy.sh staging

    main:
      - step: *build-step
      - parallel:
          - step: *test-step
          - step: *quality-step
          - step: *security-step
      - step:
          name: Build Docker
          services:
            - docker
          script:
            - docker build -t myapp:$BITBUCKET_COMMIT .
            - docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
            - docker tag myapp:$BITBUCKET_COMMIT myorg/myapp:latest
            - docker push myorg/myapp:latest
      - step:
          <<: *deploy-step
          name: Deploy to Production
          deployment: Production
          script:
            - ./scripts/deploy.sh production

  pull-requests:
    '**':
      - step:
          name: PR Build & Test
          script:
            - npm ci
            - npm run build
            - npm test

  custom:
    nightly:
      - step:
          name: Nightly Build
          script:
            - npm ci
            - npm run build:full
            - npm run test:extended

definitions:
  services:
    docker:
      memory: 1024
    postgres:
      image: postgres:14
      variables:
        POSTGRES_PASSWORD: password
        POSTGRES_DB: test_db

  caches:
    npm: ~/.npm

options:
  max-time: 60
```

## Deployment Environments

```yaml
pipelines:
  branches:
    main:
      - step:
          name: Deploy to Production
          deployment: Production
          trigger: manual
          script:
            - ./deploy.sh production
          after-script:
            - curl $HEALTH_CHECK_URL
```

## Docker Integration

```yaml
image: atlassian/default-image:latest

services:
  - docker

pipelines:
  branches:
    main:
      - step:
          name: Build and Push Docker Image
          script:
            - docker build -t $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/myapp:$BITBUCKET_COMMIT .
            - docker login -u AWS -p $(aws ecr get-login-password) $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
            - docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/myapp:$BITBUCKET_COMMIT
```

## FAQ

**Q: How do I use environment variables?**
A: Set in Repository → Settings → Pipelines → Environment variables

**Q: Can I run builds in parallel?**
A: Yes, use parallel syntax in steps

**Q: What's the build timeout?**
A: Default 120 minutes for Bitbucket Cloud

**Q: How do I cache dependencies?**
A: Use definitions.caches section

## Resources

- [Bitbucket Pipelines Documentation](https://bitbucket.org/product/features/pipelines)
- [Configuration Reference](https://support.atlassian.com/bitbucket-cloud/docs/bitbucket-pipelines-configuration-reference/)
- [YAML Syntax](https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors-and-aliases/)
