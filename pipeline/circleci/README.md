# CircleCI - Complete Enterprise-Grade CI/CD Guide

## Overview

CircleCI is a modern cloud-based CI/CD platform that automates build, test, and deployment workflows. It integrates seamlessly with GitHub and Bitbucket, offering powerful Docker support and scalable infrastructure.

### Key Capabilities
- **Fast Builds**: Parallel job execution across multiple containers
- **Docker-First**: Native Docker support with caching
- **Workflows**: Complex multi-job orchestration with dependencies
- **Approval Gates**: Manual approvals for production deployments
- **Environment Isolation**: Each job runs in its own container
- **SSH Rerun**: Rerun failed jobs with SSH access for debugging
- **Caching**: Layer caching for faster builds
- **Artifacts**: Store and retrieve build outputs
- **Orbs**: Reusable automation packages
- **Security**: Secret management, RBAC, audit logs
- **Integrations**: Slack, GitHub, Bitbucket, AWS, Azure, GCP

## Prerequisites

- CircleCI account (free or paid)
- GitHub or Bitbucket repository
- Basic understanding of YAML
- Docker knowledge (optional but recommended)

## System Requirements

### Execution Environment
- Docker-based containers
- macOS, Linux, Windows options available
- Resource classes from Small to xlarge
- 1 GB - 32 GB RAM available

## Installation & Setup

### Step 1: Connect Repository

1. Go to [circleci.com](https://circleci.com)
2. Sign up with GitHub/Bitbucket
3. Authorize CircleCI access
4. Select projects to build

### Step 2: Create .circleci/config.yml

```yaml
version: 2.1

jobs:
  build:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - run: npm ci
      - run: npm run build

  test:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - run: npm ci
      - run: npm test

workflows:
  version: 2
  build_and_test:
    jobs:
      - build
      - test:
          requires:
            - build
```

## Complete Configuration

```yaml
version: 2.1

orbs:
  node: circleci/node@5.0.0
  docker: circleci/docker@2.2.0
  kubernetes: circleci/kubernetes@1.3.1

# Job definitions
jobs:
  build:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - node/install-packages:
          pkg-manager: npm
          cache-version: v1
      - run:
          name: Build application
          command: npm run build
      - persist_to_workspace:
          root: .
          paths:
            - dist
            - node_modules

  unit-test:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - attach_workspace:
          at: .
      - run:
          name: Run unit tests
          command: npm run test:unit -- --coverage
      - store_test_results:
          path: test-results
      - store_artifacts:
          path: coverage

  integration-test:
    docker:
      - image: cimg/node:18.0
      - image: cimg/postgres:14.0
        environment:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
    steps:
      - checkout
      - attach_workspace:
          at: .
      - run:
          name: Run integration tests
          command: npm run test:integration
      - store_test_results:
          path: test-results

  code-quality:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - attach_workspace:
          at: .
      - run:
          name: Lint code
          command: npm run lint
      - run:
          name: Check formatting
          command: npm run format:check

  security-scan:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - attach_workspace:
          at: .
      - run:
          name: Audit dependencies
          command: npm audit --audit-level=moderate
          when: always

  build-docker:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - setup_remote_docker
      - docker/build:
          image: myorg/myapp
          tag: $CIRCLE_SHA1
      - docker/push:
          image: myorg/myapp
          tag: $CIRCLE_SHA1

  deploy-staging:
    docker:
      - image: cimg/base:2023.11
    environment:
      ENVIRONMENT: staging
    steps:
      - attach_workspace:
          at: .
      - run:
          name: Deploy to staging
          command: |
            set -x
            echo "Deploying to staging..."
            ./scripts/deploy.sh staging

  deploy-production:
    docker:
      - image: cimg/base:2023.11
    environment:
      ENVIRONMENT: production
    steps:
      - attach_workspace:
          at: .
      - run:
          name: Deploy to production
          command: |
            set -x
            echo "Deploying to production..."
            ./scripts/deploy.sh production

# Workflows
workflows:
  version: 2
  build_test_deploy:
    jobs:
      - build
      - unit-test:
          requires:
            - build
      - integration-test:
          requires:
            - build
      - code-quality:
          requires:
            - build
      - security-scan:
          requires:
            - build
      - build-docker:
          requires:
            - unit-test
            - integration-test
            - code-quality
            - security-scan
          filters:
            branches:
              only:
                - main
                - develop

      - deploy-staging:
          requires:
            - build-docker
          filters:
            branches:
              only:
                - develop
          type: approval

      - deploy-production:
          requires:
            - build-docker
          filters:
            branches:
              only:
                - main
          type: approval
```

## Advanced Features

### Context Variables

```yaml
jobs:
  deploy:
    docker:
      - image: cimg/base:2023.11
    steps:
      - checkout
      - run:
          name: Deploy with context secrets
          command: |
            echo "Using API key: $API_KEY"
            ./deploy.sh
```

### Matrix Builds

```yaml
jobs:
  test:
    docker:
      - image: cimg/node:<< matrix.node-version >>
    matrix:
      parameters:
        node-version: ["16", "18", "20"]
    steps:
      - checkout
      - run: npm ci
      - run: npm test
```

### Orbs Usage

```yaml
orbs:
  node: circleci/node@5.0.0
  aws-cli: circleci/aws-cli@3.1.0
  docker: circleci/docker@2.2.0

jobs:
  deploy:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/setup
      - run: aws s3 cp dist/ s3://my-bucket/ --recursive
```

## Security Best Practices

### Using Secrets

1. Go to Project Settings → Environment Variables
2. Add sensitive variables (marked as protected)
3. Reference with `$VARIABLE_NAME`

```yaml
jobs:
  deploy:
    steps:
      - run:
          name: Deploy
          command: |
            export API_KEY=$API_KEY
            ./deploy.sh
```

### Restrict Access

```yaml
jobs:
  deploy-production:
    steps:
      - run: echo "Deployment started"
    context: production-secrets  # Requires approval
```

## Notifications

### Slack Integration

```yaml
steps:
  - run:
      name: Notify Slack on failure
      when: on_fail
      command: |
        curl -X POST $SLACK_WEBHOOK \
          -H 'Content-Type: application/json' \
          -d '{"text":"Build failed: '$CIRCLE_BUILD_URL'"}'
```

## Troubleshooting

### SSH Rerun

In CircleCI UI, click "Rerun Job" → "Rerun Job with SSH"

Connect with:
```bash
ssh -p 64535 -l circleci ip-address
```

### View Logs

```bash
# Check Circle CI logs directly from CLI
curl https://circleci.com/api/v1.1/project/github/user/repo/latest/artifacts \
  -H "Circle-Token: $CIRCLE_TOKEN"
```

## FAQ

**Q: How do I cache Docker layers?**
A: CircleCI automatically caches Docker layers.

**Q: Can I use my own infrastructure?**
A: Yes, use CircleCI Runner for self-hosted execution.

**Q: What's the artifact storage limit?**
A: Default 1 GB, larger plans available.

## Resources

- [CircleCI Documentation](https://circleci.com/docs/)
- [CircleCI Orbs Registry](https://circleci.com/orbs/)
- [Configuration Reference](https://circleci.com/docs/configuration-reference/)
