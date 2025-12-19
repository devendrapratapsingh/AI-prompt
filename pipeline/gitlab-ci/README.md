# GitLab CI/CD - Complete Enterprise-Grade Platform Guide

## Overview

GitLab CI/CD is a powerful, native CI/CD platform integrated directly into GitLab, providing unlimited CI/CD minutes for public repositories and scalable CI/CD for enterprise deployments. It offers flexibility with shared runners, self-hosted runners, and Kubernetes integration for modern application delivery.

### Key Capabilities
- **Native GitLab Integration**: Automatic pipeline triggers on any GitLab event
- **Flexible Runner Architecture**: Shared runners, group runners, instance runners, self-hosted runners
- **Container-Native**: Native Docker, Docker-in-Docker, and Kubernetes executors
- **Artifact & Cache Management**: Intelligent caching, artifact versioning, dependency management
- **Environment Tracking**: Multi-environment deployments with approval gates
- **Review Applications**: Automatic preview environments for merge requests
- **Parent-Child Pipelines**: Complex pipeline orchestration and dependencies
- **Protected Environments**: Enforce approval policies for production deployments
- **Security-First**: SAST, DAST, dependency scanning, container scanning
- **Performance Optimized**: Parallel testing, matrix builds, fast artifact delivery
- **Advanced Scheduling**: Scheduled pipelines, manual triggers, conditional execution
- **High Availability**: Distributed runner configuration, load balancing
- **Compliance & Audit**: Full audit logs, RBAC, compliance reporting

## Prerequisites

- GitLab account (free, self-managed, or enterprise)
- Repository with code
- Basic YAML syntax knowledge
- For shared runners: GitLab.com or self-managed GitLab instance
- For self-hosted runners: Linux (Ubuntu/CentOS), macOS, or Windows machine with network access

## System Requirements

### GitLab-Hosted Runners (GitLab.com)
- **Shared Runners**: Free tier with usage limits, unlimited on premium
- **OS Support**: Ubuntu (latest), Debian, CentOS
- **Memory**: 3.5GB RAM per job
- **CPU**: 1 vCPU per job
- **Concurrency**: Varies by plan (free: 120 minutes/month)

### Self-Hosted Runners
- **Minimum**: 2 CPU cores, 4GB RAM, 20GB disk space
- **Recommended**: 4+ CPU cores, 8GB+ RAM, 100GB+ disk space for production
- **OS Support**: Linux (Ubuntu 20.04+, CentOS 7+), macOS (10.13+), Windows Server 2016+
- **Network**: Outbound HTTPS (443) to GitLab instance
- **Docker**: Optional (required for Docker executor)
- **Kubernetes**: Optional (required for Kubernetes executor)

### Executor Options
- **Shell**: Direct script execution on runner machine
- **Docker**: Container-based isolation with Docker engine
- **Docker Machine**: On-demand VM provisioning (deprecated)
- **Kubernetes**: Native Kubernetes pod execution
- **SSH**: Remote execution via SSH
- **VirtualBox**: VM-based isolation (macOS)
- **Parallels**: Parallels Desktop-based execution (macOS)

## Installation & Setup Guide

### Step 1: Install GitLab Runner

**Ubuntu/Debian:**
```bash
# Add GitLab repository
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

# Install runner
sudo apt-get install gitlab-runner

# Start service
sudo systemctl start gitlab-runner
sudo systemctl enable gitlab-runner

# Verify installation
gitlab-runner --version
```

**CentOS/RHEL:**
```bash
# Add repository
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash

# Install
sudo yum install gitlab-runner

# Start and enable
sudo systemctl start gitlab-runner
sudo systemctl enable gitlab-runner
```

**macOS (Homebrew):**
```bash
brew install gitlab-runner
brew services start gitlab-runner
gitlab-runner start
```

**Using Docker:**
```bash
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest
```

**Kubernetes:**
```bash
# Add Helm repository
helm repo add gitlab https://charts.gitlab.io
helm repo update

# Install
helm install gitlab-runner gitlab/gitlab-runner \
  --set gitlabUrl=https://gitlab.example.com/ \
  --set gitlabToken=YOUR_TOKEN \
  --set runners.tags="k8s\,docker" \
  --set runners.image=ubuntu:latest
```

### Step 2: Register Runner

**Interactive Registration:**
```bash
sudo gitlab-runner register \
  --url https://gitlab.com/ \
  --token YOUR_REGISTRATION_TOKEN \
  --executor docker \
  --docker-image ubuntu:latest \
  --docker-tlsverify=false \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --description "Docker Runner - Production" \
  --tag-list "docker,production" \
  --run-untagged=false \
  --locked=false \
  --docker-privileged=false
```

**Kubernetes Registration:**
```bash
gitlab-runner register \
  --url https://gitlab.example.com/ \
  --token YOUR_REGISTRATION_TOKEN \
  --executor kubernetes \
  --kubernetes-host https://k8s.example.com:6443 \
  --kubernetes-token k8s_token_here \
  --description "Kubernetes Runner" \
  --tag-list "k8s,production"
```

**Via GitLab UI:**
1. Go to Project → Settings → CI/CD → Runners
2. Click "Create runner"
3. Configure runner details
4. Select executor type
5. Follow registration instructions

### Step 3: Configure .gitlab-ci.yml

Create in repository root:

```bash
mkdir -p .gitlab/ci
cat > .gitlab-ci.yml << 'EOF'
# Pipeline configuration
stages:
  - build
  - test
  - quality
  - security
  - deploy

# Global variables
variables:
  REGISTRY: registry.gitlab.com
  IMAGE_NAME: $CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME

# Default configuration for all jobs
default:
  image: node:18-alpine
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_or_timeout_failure

# Define jobs...
EOF

git add .gitlab-ci.yml
git commit -m "feat: add GitLab CI/CD pipeline configuration"
git push origin main
```

### Step 4: Monitor Pipeline Execution

1. Go to Project → CI/CD → Pipelines
2. Click on pipeline ID to see execution details
3. View individual job logs, artifacts, and results
4. Monitor real-time execution progress

## Configuration Walkthrough

### Trigger Rules and Events

```yaml
# Push events on specific branches
on_push_main:
  script: echo "Building main branch"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "push"'

# Merge request events
on_merge_request:
  script: echo "Testing merge request"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'

# Scheduled pipelines
nightly_build:
  script: echo "Nightly build"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "schedule"'

# Manual trigger
manual_deploy:
  script: echo "Manual deployment"
  when: manual

# Tag events (releases)
on_release:
  script: echo "Release build"
  rules:
    - if: '$CI_COMMIT_TAG'
      when: always
```

### Variables and Secrets

```yaml
# Global variables
variables:
  ENV: production
  LOG_LEVEL: info

jobs_with_variables:
  variables:
    # Override globally
    ENV: staging
    # Job-specific
    NODE_ENV: development
  
  script:
    - echo "Building in $ENV environment"
    - npm ci
    - npm run build
  
  # Access secrets
  secrets:
    DATABASE_URL:
      vault: db_connection_string
    API_KEY:
      vault: third_party_api_key
```

**Setting Secrets in GitLab:**
1. Project → Settings → CI/CD → Variables
2. Add variable with key and value
3. Enable "Protect variable" for production use
4. Enable "Mask variable" to hide in logs

### Job Dependencies

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script: npm run build

test:
  stage: test
  needs: ["build"]  # Only run after build succeeds
  script: npm test

deploy:
  stage: deploy
  needs: ["test"]  # Can depend on multiple jobs
  script: ./deploy.sh
```

### Matrix Builds

```yaml
test:
  stage: test
  parallel:
    matrix:
      - NODE_VERSION: ["16", "18", "20"]
        DATABASE: ["postgres", "mysql"]
  
  image: node:$NODE_VERSION-alpine
  
  script:
    - npm ci
    - npm test
```

## CI/CD Pipeline Stages

### Stage 1: Build
```yaml
build:
  stage: build
  image: node:18-alpine
  
  script:
    - echo "Installing dependencies..."
    - npm ci --prefer-offline --no-audit
    
    - echo "Building application..."
    - npm run build
    
    - echo "Build verification..."
    - if [ ! -d "dist" ]; then echo "Build failed"; exit 1; fi
  
  artifacts:
    paths:
      - dist/
      - node_modules/.bin/
    expire_in: 1 day
    name: "build-$CI_COMMIT_SHORT_SHA"
  
  cache:
    key:
      files:
        - package-lock.json
      prefix: build
    paths:
      - node_modules/
    policy: pull-push
  
  tags:
    - docker
  
  only:
    - main
    - develop
    - merge_requests
```

### Stage 2: Test
```yaml
unit-test:
  stage: test
  image: node:18-alpine
  needs: ["build"]
  
  script:
    - npm ci --prefer-offline
    - npm run test:unit -- --coverage --reporter=json --reporters=json-summary
  
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
      junit: coverage/junit.xml
    paths:
      - coverage/
    expire_in: 30 days

integration-test:
  stage: test
  image: node:18-alpine
  needs: ["build"]
  
  services:
    - name: postgres:14-alpine
      alias: database
    - name: redis:7-alpine
      alias: cache
  
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: test
    POSTGRES_PASSWORD: test
    REDIS_URL: redis://cache:6379/0
  
  script:
    - npm ci --prefer-offline
    - npm run test:integration
  
  allow_failure: true

e2e-test:
  stage: test
  image: mcr.microsoft.com/playwright:v1.40.0
  needs: ["build"]
  
  script:
    - npm ci --prefer-offline
    - npx playwright install
    - npm run test:e2e
  
  artifacts:
    paths:
      - test-results/
    reports:
      junit: test-results/junit.xml
    when: always
```

### Stage 3: Code Quality
```yaml
code-quality:
  stage: quality
  image: node:18-alpine
  needs: ["build"]
  
  script:
    - npm ci --prefer-offline
    - npm run lint
    - npm run lint:css
    - npm run lint:json
  
  artifacts:
    reports:
      codequality: codequality.json
    expire_in: 30 days
  
  allow_failure: true

sonarqube-analysis:
  stage: quality
  image: sonarsource/sonar-scanner-cli:latest
  needs: ["build"]
  
  script:
    - sonar-scanner
      -Dsonar.projectKey=$CI_PROJECT_NAME
      -Dsonar.sources=src
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.login=$SONAR_TOKEN
      -Dsonar.gitlab.project_id=$CI_PROJECT_ID
      -Dsonar.gitlab.commit_sha=$CI_COMMIT_SHA
  
  allow_failure: true

metrics-report:
  stage: quality
  image: node:18-alpine
  needs: ["build"]
  
  script:
    - npm ci --prefer-offline
    - npm run test -- --coverage
    - npm run build:report
  
  artifacts:
    paths:
      - metrics/
```

### Stage 4: Security
```yaml
sast:
  stage: security
  image: returntocorp/semgrep:latest
  needs: ["build"]
  
  script:
    - semgrep --json --output=semgrep-report.json --config=p/owasp-top-ten src/
  
  artifacts:
    reports:
      sast: semgrep-report.json
    expire_in: 30 days
  
  allow_failure: true

dependency-check:
  stage: security
  image: node:18-alpine
  needs: ["build"]
  
  script:
    - npm audit --json > audit-report.json || true
    - npm list --depth=0
  
  artifacts:
    paths:
      - audit-report.json
    expire_in: 30 days
  
  allow_failure: true

container-scan:
  stage: security
  image: aquasec/trivy:latest
  needs: ["build"]
  
  script:
    - trivy fs --format json --output trivy-report.json .
    - trivy config --format json --output config-report.json .
  
  artifacts:
    reports:
      container_scanning: trivy-report.json
    expire_in: 30 days
  
  allow_failure: true

secret-scan:
  stage: security
  image: zricethezav/gitleaks:latest
  
  script:
    - gitleaks detect --source . --exit-code 1 --report-format json --report-path secrets-report.json || true
  
  artifacts:
    paths:
      - secrets-report.json
    expire_in: 30 days
  
  allow_failure: true
```

### Stage 5: Deploy
```yaml
deploy-staging:
  stage: deploy
  image: alpine:latest
  needs:
    - build
    - unit-test
    - code-quality
    - sast
  
  environment:
    name: staging
    url: https://staging.example.com
    deployment_tier: staging
    kubernetes:
      namespace: staging
  
  script:
    - apk add --no-cache curl openssh-client rsync git
    - mkdir -p ~/.ssh
    - echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
    - chmod 600 ~/.ssh/deploy_key
    - ssh-keyscan -H $DEPLOY_HOST >> ~/.ssh/known_hosts 2>/dev/null
    
    - echo "Deploying to staging environment..."
    - rsync -avz -e "ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no" dist/ deploy@$DEPLOY_HOST:/app/staging/
    - ssh -i ~/.ssh/deploy_key deploy@$DEPLOY_HOST "cd /app/staging && bash deploy.sh"
    
    - echo "Running health checks..."
    - curl -f https://staging.example.com/health || exit 1
  
  only:
    - develop
  
  when: manual
  
  on_failure:
    script:
      - curl -X POST $SLACK_WEBHOOK -d '{"text":"Staging deployment failed"}'

deploy-production:
  stage: deploy
  image: alpine:latest
  needs:
    - build
    - unit-test
    - code-quality
    - sast
    - integration-test
  
  environment:
    name: production
    url: https://app.example.com
    deployment_tier: production
    auto_stop_in: never
    kubernetes:
      namespace: production
  
  script:
    - apk add --no-cache curl openssh-client rsync git
    - mkdir -p ~/.ssh
    - echo "$PROD_DEPLOY_KEY" > ~/.ssh/deploy_key
    - chmod 600 ~/.ssh/deploy_key
    - ssh-keyscan -H $PROD_DEPLOY_HOST >> ~/.ssh/known_hosts 2>/dev/null
    
    - echo "Creating pre-deployment backup..."
    - ssh -i ~/.ssh/deploy_key deploy@$PROD_DEPLOY_HOST "cd /app/production && bash backup.sh"
    
    - echo "Deploying to production environment..."
    - rsync -avz -e "ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no" dist/ deploy@$PROD_DEPLOY_HOST:/app/production/
    - ssh -i ~/.ssh/deploy_key deploy@$PROD_DEPLOY_HOST "cd /app/production && bash deploy.sh"
    
    - echo "Running comprehensive health checks..."
    - |
      for i in {1..30}; do
        if curl -f https://app.example.com/health; then
          echo "Health check passed"
          exit 0
        fi
        echo "Health check attempt $i failed, retrying in 10 seconds..."
        sleep 10
      done
      exit 1
  
  only:
    - main
  
  when: manual
  
  retry:
    max: 1
    when:
      - runner_system_failure
```

## Tool Integrations

### Docker Integration

```yaml
docker-build-and-push:
  stage: build
  image: docker:24-dind
  services:
    - docker:24-dind
  
  variables:
    DOCKER_HOST: tcp://docker:2375
    DOCKER_TLS_CERTDIR: ""
    DOCKER_DRIVER: overlay2
  
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -t $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    - if [ "$CI_COMMIT_BRANCH" = "main" ]; then
        docker push $CI_REGISTRY_IMAGE:latest;
      fi
  
  after_script:
    - docker logout
```

### Kubernetes Deployment

```yaml
deploy-k8s:
  stage: deploy
  image: bitnami/kubectl:latest
  
  script:
    - kubectl config use-context $KUBE_CONTEXT
    - kubectl set image deployment/myapp myapp=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n production
    - kubectl rollout status deployment/myapp -n production --timeout=5m
  
  environment:
    name: kubernetes-production
    kubernetes:
      namespace: production
```

### Slack Notifications

```yaml
notify-slack:
  stage: .post
  image: curlimages/curl:latest
  when: always
  
  script:
    - |
      curl -X POST $SLACK_WEBHOOK_URL \
        -H 'Content-Type: application/json' \
        -d "{
          \"blocks\": [
            {
              \"type\": \"header\",
              \"text\": {
                \"type\": \"plain_text\",
                \"text\": \"Pipeline $CI_PIPELINE_ID - $CI_JOB_STATUS\"
              }
            },
            {
              \"type\": \"section\",
              \"fields\": [
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Project:*\n$CI_PROJECT_NAME\"
                },
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Branch:*\n$CI_COMMIT_BRANCH\"
                },
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Status:*\n$CI_JOB_STATUS\"
                },
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Duration:*\n$CI_JOB_DURATION\"
                }
              ]
            }
          ]
        }"
```

## Advanced Configuration

### Review Applications

```yaml
deploy-review:
  stage: deploy
  image: alpine:latest
  
  script:
    - apk add --no-cache curl
    - curl -X POST http://deploy-api/review \
        -H "Authorization: Bearer $DEPLOY_TOKEN" \
        -d "branch=$CI_COMMIT_REF_SLUG&sha=$CI_COMMIT_SHA"
  
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://review-${CI_ENVIRONMENT_SLUG}.example.com
    auto_stop_in: 7 days
  
  only:
    - merge_requests
  
  when: manual
```

### Parent-Child Pipelines

```yaml
# Parent pipeline
trigger-tests:
  stage: build
  trigger:
    include:
      - local: .gitlab/test-pipeline.yml
      - local: .gitlab/security-pipeline.yml
    strategy: depend
  
  variables:
    CHILD_COMMIT: $CI_COMMIT_SHA
    CHILD_BRANCH: $CI_COMMIT_BRANCH
```

## Enterprise Features

### Protected Environments

```yaml
deploy-production:
  stage: deploy
  environment:
    name: production
    deployment_tier: production
    # Requires manual approval
  
  only:
    - main
  
  when: manual
  
  # Must have "Maintainer" role
  allowed_to_deploy:
    - projects:
      - production
```

### Performance Optimization

```yaml
# Fast caching
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
  policy: pull-push

# Parallel test execution
test:
  parallel: 5
  script:
    - npm test -- --shard $CI_NODE_INDEX/$CI_NODE_TOTAL

# Artifacts for next stage
build:
  artifacts:
    paths:
      - dist/
    expire_in: 1 day
```

### High Availability

```bash
# Register multiple runners
for i in {1..5}; do
  gitlab-runner register \
    --url https://gitlab.example.com \
    --token TOKEN \
    --executor docker \
    --tag-list "ha,docker" \
    --description "HA Runner $i"
done
```

## Troubleshooting

### Runner Connection Issues
```bash
# Test runner connectivity
gitlab-runner verify --delete

# Check runner service
sudo systemctl status gitlab-runner

# View runner logs
gitlab-runner --debug run
```

### Pipeline Timeout
```yaml
# Increase job timeout
build:
  script: npm run build
  timeout: 1 hour
```

### Out of Memory
```bash
# Increase Docker memory limit
sudo usermod -a -G docker gitlab-runner
# Add to docker daemon config:
{
  "memory": "4g",
  "memory-swap": "4g"
}
```

## FAQ

**Q: How do I limit pipeline execution to specific runners?**
A: Use tags in your `.gitlab-ci.yml` and set corresponding tags on runners.

**Q: Can I cache dependencies between pipelines?**
A: Yes, use `cache` with `policy: pull-push` and specify cache key.

**Q: How do I implement complex branching logic?**
A: Use `rules` with conditions like `$CI_COMMIT_BRANCH`, `$CI_PIPELINE_SOURCE`.

**Q: What's the maximum artifact size?**
A: Default is 100MB, configurable in GitLab admin settings.

**Q: How can I speed up CI/CD?**
A: Use caching, parallel jobs, optimize dependencies, use fast images.

## Additional Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Runner Installation Guide](https://docs.gitlab.com/runner/install/)
- [CI/CD Best Practices](https://docs.gitlab.com/ee/ci/best_practices.html)
- [GitLab CI Examples](https://docs.gitlab.com/ee/ci/examples/)
- [Performance Optimization](https://docs.gitlab.com/ee/ci/runner/autoscaling.html)
  REGISTRY: registry.gitlab.com
  IMAGE_NAME: $CI_REGISTRY_IMAGE

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - echo "Building application"
  artifacts:
    paths:
      - dist/
    expire_in: 1 day

test:
  stage: test
  image: node:18
  script:
    - npm install
    - npm test
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'

deploy:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying to production"
  only:
    - main
  environment:
    name: production
    url: https://app.example.com
EOF
```

### Step 2: Commit and Enable

```bash
git add .gitlab-ci.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

### Step 3: Monitor Pipeline

1. Go to your project on GitLab
2. Click "CI/CD" → "Pipelines"
3. Click on the pipeline run to view logs

## Configuration Walkthrough

### Pipeline Structure

```yaml
# Define stages
stages:
  - build
  - test
  - security
  - deploy

# Variables available to all jobs
variables:
  DOCKER_DRIVER: overlay2
  REGISTRY: registry.gitlab.com

# Define jobs
build_job:
  stage: build
  image: ubuntu:latest
  script:
    - apt-get update
    - apt-get install -y build-essential
    - make build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

test_job:
  stage: test
  image: node:18
  dependencies:
    - build_job
  script:
    - npm install
    - npm test
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

### Triggers and Rules

```yaml
# Trigger on specific events
build:
  stage: build
  script: make build
  only:
    - merge_requests
    - main
    - develop

# Use rules for complex conditions
deploy:
  stage: deploy
  script: deploy.sh
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: always
    - if: $CI_COMMIT_TAG
      when: always
    - when: never

# Manual trigger
manual_deploy:
  stage: deploy
  script: deploy.sh
  when: manual
```

## CI/CD Pipeline Stages

### Stage 1: Build

```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    paths:
      - dist/
  cache:
    paths:
      - node_modules/
    key:
      files:
        - package-lock.json
```

### Stage 2: Test

```yaml
test:
  stage: test
  image: node:18
  script:
    - npm install
    - npm run test -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test_matrix:
  stage: test
  image: node:$NODE_VERSION
  parallel:
    matrix:
      - NODE_VERSION: ["16", "18", "20"]
  script:
    - npm install
    - npm test
```

### Stage 3: Security

```yaml
security_scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy fs --format sarif --output trivy-results.sarif .
  artifacts:
    reports:
      sast: trivy-results.sarif

dependency_check:
  stage: security
  image: node:18
  script:
    - npm audit --production --json > npm-audit.json
  artifacts:
    reports:
      dependency_scanning: npm-audit.json

sast:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    - semgrep --config=p/security-audit --json --output=sast-report.json .
  artifacts:
    reports:
      sast: sast-report.json
```

### Stage 4: Deploy

```yaml
deploy_staging:
  stage: deploy
  image: alpine:latest
  script:
    - kubectl set image deployment/app app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n staging
    - kubectl rollout status deployment/app -n staging
  environment:
    name: staging
    url: https://staging.example.com
    kubernetes:
      namespace: staging
  only:
    - develop

deploy_production:
  stage: deploy
  image: alpine:latest
  script:
    - kubectl set image deployment/app app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n production
    - kubectl rollout status deployment/app -n production
  environment:
    name: production
    url: https://app.example.com
    kubernetes:
      namespace: production
  only:
    - main
  when: manual
```

## Tool Integrations

### Docker Integration

```yaml
build_image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  after_script:
    - docker logout
```

### Kubernetes Deployment

```yaml
deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context prod-cluster
    - kubectl set image deployment/myapp myapp=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - kubectl rollout status deployment/myapp
  environment:
    name: production
    kubernetes:
      namespace: production
```

### Slack Notifications

```yaml
success_notification:
  stage: deploy
  image: curlimages/curl:latest
  script:
    - |
      curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"Pipeline succeeded for $CI_PROJECT_NAME\"}" \
        $SLACK_WEBHOOK_URL
  when: on_success

failure_notification:
  stage: deploy
  image: curlimages/curl:latest
  script:
    - |
      curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"Pipeline failed for $CI_PROJECT_NAME\"}" \
        $SLACK_WEBHOOK_URL
  when: on_failure
```

## Enterprise Features

### Role-Based Access Control (RBAC)

GitLab Project Settings > Members:
- Owner: Full access
- Maintainer: Manage repository, CI/CD settings
- Developer: Push commits, create branches
- Reporter: View pipelines, download artifacts
- Guest: View public pipelines

### Secret Management

```bash
# Go to Settings > CI/CD > Variables
# Add variables with types:
# - File: Large files (keys, certificates)
# - Variable: Text values (tokens, URLs)

# Use in pipeline:
script:
  - export DATABASE_URL=$DB_URL
  - export API_KEY=$API_KEY_FILE
```

### Protected Variables

```yaml
deploy:
  script: deploy.sh
  variables:
    DEPLOY_TOKEN: $PROTECTED_TOKEN  # Only on protected branches
  only:
    - main
    - tags
```

### Audit Logging

- Go to Admin Area > Audit Log (for instance)
- Project > Audit Events (for project)
- All CI/CD actions are logged automatically

## Performance Optimization

### Caching

```yaml
cache:
  paths:
    - node_modules/
    - .npm/
  key:
    files:
      - package-lock.json
    prefix: ${CI_COMMIT_REF_SLUG}
```

### Artifacts

```yaml
artifacts:
  paths:
    - dist/
    - coverage/
  expire_in: 30 days
  reports:
    coverage_report:
      coverage_format: cobertura
      path: coverage/cobertura-coverage.xml
```

### Parallel Jobs

```yaml
test:
  parallel: 5
  script:
    - npm test -- --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
```

### Matrix Strategy

```yaml
test:
  parallel:
    matrix:
      - IMAGE: ["node:16", "node:18", "node:20"]
        TEST_SUITE: ["unit", "integration", "e2e"]
  image: $IMAGE
  script:
    - npm run test:$TEST_SUITE
```

## Security Hardening

### Container Scanning

```yaml
container_scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --format sarif --output container-scan.sarif $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: container-scan.sarif
```

### Pipeline Policies

```yaml
# Require approval for production
deploy_production:
  script: deploy.sh
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
```

### IP Allowlisting for Runners

Settings > CI/CD > Runners:
- Restrict runner access to specific IP ranges
- Use protected runners for production

## High Availability & Disaster Recovery

### Multiple Runners

```bash
# Install multiple runners across different machines
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
gitlab-runner register
```

### Backup Pipelines

```yaml
backup_job:
  script:
    - mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME > backup.sql
  artifacts:
    paths:
      - backup.sql
  only:
    - schedules
```

## Troubleshooting

### Common Issues

**Pipeline not starting**
- Check .gitlab-ci.yml syntax (Pipelines > Create new)
- Verify CI/CD is enabled (Settings > CI/CD > General)
- Ensure runners are active (Admin > Runners)

**Job fails with permission denied**
- Check runner has access to resources
- Verify secrets and variables are set
- Check file permissions in script

**Slow pipeline execution**
- Enable caching for dependencies
- Use artifact dependencies wisely
- Parallelize test jobs with matrix

**Docker build fails**
- Ensure Docker registry credentials are set
- Check Dockerfile exists in repository
- Verify Docker service is running

### Debug Mode

```yaml
debug_job:
  script:
    - echo "Runner: $CI_RUNNER_ID"
    - echo "Commit: $CI_COMMIT_SHA"
    - echo "Branch: $CI_COMMIT_BRANCH"
    - env | sort
```

## Links & Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [CI/CD Pipeline Configuration Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [GitLab Runners](https://docs.gitlab.com/runner/)
- [Security Best Practices](https://docs.gitlab.com/ee/security/)
- [Performance Tuning](https://docs.gitlab.com/ee/ci/large_windows_machines.html)
- [GitLab Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)
