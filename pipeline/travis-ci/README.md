# Travis CI - Complete Enterprise-Grade Guide

## Overview

Travis CI is a hosted CI/CD platform that integrates with GitHub to automatically run tests and deploy applications. It's particularly popular for open-source projects and offers excellent support for multiple programming languages.

### Key Capabilities
- **GitHub Integration**: Seamless integration with GitHub repositories
- **Multi-Language Support**: Java, Python, Node.js, Go, Ruby, PHP, etc.
- **Matrix Testing**: Test across multiple language versions and OS
- **Build Matrix**: Parallel execution across environments
- **Docker Support**: Native Docker build and deployment
- **Deployment Integration**: Direct integration with AWS, Heroku, Azure, GCP
- **Pull Request Testing**: Automatic PR validation
- **Notifications**: Email, Slack, custom webhooks
- **Build Artifacts**: Upload and manage build outputs
- **SSH Access**: Debug builds with SSH access

## Prerequisites

- GitHub account with repository
- Travis CI account (free for public repos)
- Basic understanding of YAML
- For deployments: cloud account (AWS, GCP, Azure, Heroku)

## Installation & Setup

### Step 1: Connect GitHub

1. Go to [travis-ci.com](https://travis-ci.com)
2. Sign in with GitHub
3. Authorize Travis CI
4. Select repositories to build

### Step 2: Create .travis.yml

```yaml
language: node_js

node_js:
  - "18"
  - "20"

install:
  - npm ci

script:
  - npm run build
  - npm test

deploy:
  provider: heroku
  api_key: $HEROKU_API_KEY
  app: my-app
  on:
    branch: main
```

## Complete Configuration

```yaml
language: node_js

node_js:
  - "18"
  - "20"

dist: focal
os: linux

services:
  - docker
  - postgresql

addons:
  postgresql: "14"

branches:
  only:
    - main
    - develop

env:
  global:
    - NODE_ENV=production
    - DATABASE_URL=postgresql://localhost/test_db
  matrix:
    - SUITE=unit
    - SUITE=integration

install:
  - npm ci --prefer-offline

before_script:
  - npm run db:migrate

script:
  - if [ "$SUITE" = "unit" ]; then npm run test:unit; fi
  - if [ "$SUITE" = "integration" ]; then npm run test:integration; fi
  - npm run lint
  - npm run build

after_success:
  - npm run coverage:report
  - bash <(curl -s https://codecov.io/bash)

after_failure:
  - cat test-results.log

cache:
  npm: true
  directories:
    - node_modules

deploy:
  - provider: s3
    access_key_id: $AWS_ACCESS_KEY_ID
    secret_access_key: $AWS_SECRET_ACCESS_KEY
    bucket: my-artifacts
    local_dir: dist
    skip_cleanup: true
    on:
      branch: main

  - provider: heroku
    api_key: $HEROKU_API_KEY
    app: my-staging-app
    on:
      branch: develop

  - provider: heroku
    api_key: $HEROKU_API_KEY
    app: my-production-app
    on:
      branch: main

notifications:
  email: true
  slack:
    secure: YOUR_ENCRYPTED_SLACK_WEBHOOK
  webhooks:
    - https://webhooks.example.com/travis
```

## Advanced Features

### Build Stages

```yaml
stages:
  - name: Build
    if: type = push OR type = pull_request
  - name: Test
    if: type = push OR type = pull_request
  - name: Deploy Staging
    if: branch = develop AND type = push
  - name: Deploy Production
    if: branch = main AND type = push
  - name: Notify
    if: always()

jobs:
  include:
    # Build Stage
    - stage: Build
      name: "Build Application"
      script:
        - npm run build

    # Test Stage
    - stage: Test
      name: "Unit Tests"
      script:
        - npm run test:unit

    - stage: Test
      name: "Integration Tests"
      script:
        - npm run test:integration
      services:
        - postgresql

    - stage: Test
      name: "Code Quality"
      script:
        - npm run lint
        - npm run format:check

    # Deploy Staging
    - stage: Deploy Staging
      name: "Deploy to Staging"
      script: skip
      deploy:
        provider: heroku
        api_key: $HEROKU_API_KEY
        app: my-staging-app

    # Deploy Production
    - stage: Deploy Production
      name: "Deploy to Production"
      script: skip
      deploy:
        provider: heroku
        api_key: $HEROKU_API_KEY
        app: my-production-app

    # Notify
    - stage: Notify
      name: "Send Notifications"
      script:
        - |
          curl -X POST $SLACK_WEBHOOK \
            -H 'Content-Type: application/json' \
            -d '{"text":"Build completed"}'
```

### Docker Builds

```yaml
language: minimal

services:
  - docker

before_script:
  - docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

script:
  - docker build -t myorg/myapp:$TRAVIS_COMMIT .
  - docker run myorg/myapp:$TRAVIS_COMMIT npm test

after_success:
  - docker push myorg/myapp:$TRAVIS_COMMIT
  - |
    if [ "$TRAVIS_BRANCH" = "main" ]; then
      docker tag myorg/myapp:$TRAVIS_COMMIT myorg/myapp:latest
      docker push myorg/myapp:latest
    fi
```

## Deployment

### AWS Deployment

```yaml
deploy:
  provider: codedeploy
  access_key_id: $AWS_ACCESS_KEY_ID
  secret_access_key: $AWS_SECRET_ACCESS_KEY
  bucket: my-deployment-bucket
  key: dist.zip
  application: my-app
  deployment_group: production
  region: us-east-1
  on:
    branch: main
```

### Kubernetes Deployment

```yaml
deploy:
  provider: script
  script: ./deploy-k8s.sh
  on:
    branch: main
```

Script (deploy-k8s.sh):
```bash
#!/bin/bash
kubectl set image deployment/myapp \
  myapp=myorg/myapp:$TRAVIS_COMMIT \
  -n production
kubectl rollout status deployment/myapp -n production
```

## Security Best Practices

### Encrypted Variables

```bash
# Install Travis CLI
gem install travis

# Encrypt variable
travis encrypt MY_SECRET=value --add env.global
```

### Secure Deployment Keys

```yaml
before_deploy:
  - openssl aes-256-cbc -K $encrypted_key -iv $encrypted_iv -in deploy_key.enc -out deploy_key -d
  - chmod 600 deploy_key
  - ssh-add deploy_key

deploy:
  provider: script
  script: ./deploy.sh
  on:
    branch: main
```

## Notifications

### Slack

```yaml
notifications:
  slack:
    secure: YOUR_ENCRYPTED_WEBHOOK_URL
    on_success: always
    on_failure: always
    on_pull_requests: true
```

### Custom Webhooks

```yaml
notifications:
  webhooks:
    urls:
      - https://hooks.slack.com/services/YOUR/WEBHOOK
    on_success: always
    on_failure: always
```

## FAQ

**Q: How do I skip tests for specific commits?**
A: Add `[skip ci]` or `[ci skip]` in commit message.

**Q: Can I run builds in parallel?**
A: Yes, use build matrix with multiple node_js versions.

**Q: How do I access logs?**
A: Logs are displayed in real-time on Travis CI website.

**Q: What's the build timeout?**
A: Default 50 minutes for free tier, adjustable for paid.

## Resources

- [Travis CI Documentation](https://docs.travis-ci.com/)
- [Build Configuration Reference](https://docs.travis-ci.com/user/build-config/)
- [Deployment Guide](https://docs.travis-ci.com/user/deployment/)
- [Environment Variables](https://docs.travis-ci.com/user/environment-variables/)
