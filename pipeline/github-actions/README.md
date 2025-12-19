# GitHub Actions - Complete CI/CD Platform Guide

## Overview

GitHub Actions is a native CI/CD platform integrated directly into GitHub, enabling automated workflows for building, testing, and deploying applications. It offers unlimited free minutes for public repositories and competitive pricing for private repositories.

### Key Capabilities
- **Native GitHub Integration**: Workflows trigger on any GitHub event (push, PR, release)
- **Rich Marketplace**: 10,000+ pre-built actions for common tasks
- **Matrix Testing**: Run tests across multiple OS, language versions, and environments
- **Container Support**: Native Docker and Kubernetes integration
- **Reusable Workflows**: Share workflow templates across repositories
- **Self-Hosted Runners**: Run workflows on your own infrastructure
- **Secrets Management**: Built-in encrypted secret storage
- **Artifact Management**: Upload/download artifacts between jobs
- **Status Checks**: Enforce required checks before merging PRs

## Prerequisites

- GitHub account (free or paid)
- Repository with code to automate
- Basic understanding of YAML syntax
- For self-hosted runners: Linux, macOS, or Windows machine with network access

## System Requirements

### GitHub-Hosted Runners
- **Ubuntu**: ubuntu-latest, ubuntu-22.04, ubuntu-20.04
- **Windows**: windows-latest, windows-2022, windows-2019
- **macOS**: macos-latest, macos-13, macos-12

### Self-Hosted Runners
- Minimum: 2 GB RAM, 2 CPU cores
- Recommended: 4 GB RAM, 4 CPU cores for production workloads
- Network: Outbound HTTPS access to github.com

## Installation & Setup

### Step 1: Create Workflow File

Create `.github/workflows/ci-cd.yml` in your repository:

```bash
mkdir -p .github/workflows
```

### Step 2: Define Your First Workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up environment
        run: echo "Building application"
```

### Step 3: Commit and Push

```bash
git add .github/workflows/ci-cd.yml
git commit -m "Add CI/CD workflow"
git push origin main
```

### Step 4: Monitor Workflow Execution

1. Go to your repository on GitHub
2. Click "Actions" tab
3. View workflow run details, logs, and status

## Configuration Walkthrough

### Trigger Events

```yaml
on:
  # Trigger on push to main and develop
  push:
    branches: [ main, develop ]
    paths:
      - 'src/**'
      - '.github/workflows/**'
  
  # Trigger on pull requests
  pull_request:
    branches: [ main, develop ]
  
  # Trigger on releases
  release:
    types: [ published, created, edited ]
  
  # Scheduled triggers (cron)
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  
  # Manual trigger
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
```

### Jobs and Steps

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    
    # Matrix strategy for multiple configurations
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
        os: [ubuntu-latest, windows-latest]
    
    # Environment variables
    env:
      REGISTRY: ghcr.io
      IMAGE_NAME: ${{ github.repository }}
    
    steps:
      # Checkout code
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for better analysis
      
      # Setup environment
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      # Build step
      - name: Build application
        run: npm run build
      
      # Test step
      - name: Run tests
        run: npm test -- --coverage
      
      # Upload artifacts
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          flags: unittests
          fail_ci_if_error: true
```

## CI/CD Pipeline Stages

### Stage 1: Build
```yaml
build:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    - run: npm ci
    - run: npm run build
    - uses: actions/upload-artifact@v4
      with:
        name: build-artifact
        path: dist/
        retention-days: 5
```

### Stage 2: Test
```yaml
test:
  runs-on: ubuntu-latest
  needs: build
  strategy:
    matrix:
      test-suite: [unit, integration, e2e]
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
    - run: npm ci
    - run: npm run test:${{ matrix.test-suite }}
    - uses: actions/upload-artifact@v4
      if: failure()
      with:
        name: test-results-${{ matrix.test-suite }}
        path: test-results/
```

### Stage 3: Code Quality
```yaml
code-quality:
  runs-on: ubuntu-latest
  needs: build
  steps:
    - uses: actions/checkout@v4
    - name: SonarQube Analysis
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Stage 4: Security Scan
```yaml
security-scan:
  runs-on: ubuntu-latest
  needs: build
  steps:
    - uses: actions/checkout@v4
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
    
    - name: Run OWASP Dependency Check
      uses: dependency-check/Dependency-Check_Action@main
      with:
        project: 'MyProject'
        path: '.'
        format: 'JSON'
```

### Stage 5: Deploy
```yaml
deploy:
  runs-on: ubuntu-latest
  needs: [build, test, security-scan]
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  environment:
    name: production
    url: https://app.example.com
  steps:
    - uses: actions/checkout@v4
    
    - name: Download build artifact
      uses: actions/download-artifact@v4
      with:
        name: build-artifact
    
    - name: Deploy to production
      env:
        DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
      run: |
        mkdir -p ~/.ssh
        echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
        chmod 600 ~/.ssh/deploy_key
        ssh-keyscan -H ${{ secrets.DEPLOY_HOST }} >> ~/.ssh/known_hosts
        scp -i ~/.ssh/deploy_key -r ./dist/ deploy@${{ secrets.DEPLOY_HOST }}:/app/
        ssh -i ~/.ssh/deploy_key deploy@${{ secrets.DEPLOY_HOST }} 'cd /app && ./restart.sh'
```

## Tool Integrations

### Docker Integration
```yaml
build-and-push:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to Docker Registry
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: myrepo/myapp:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### Kubernetes Deployment
```yaml
deploy-k8s:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'
    
    - name: Configure kubeconfig
      env:
        KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
      run: |
        mkdir -p ~/.kube
        echo "$KUBE_CONFIG" | base64 -d > ~/.kube/config
    
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/myapp myapp=myrepo/myapp:${{ github.sha }} -n production
        kubectl rollout status deployment/myapp -n production
```

### AWS Integration
```yaml
deploy-aws:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Deploy to ECS
      run: |
        aws ecs update-service --cluster prod-cluster --service my-service \
          --force-new-deployment
```

### Slack Notifications
```yaml
notify:
  runs-on: ubuntu-latest
  if: always()
  needs: [build, test, deploy]
  steps:
    - name: Send Slack notification
      uses: slackapi/slack-github-action@v1.24.0
      with:
        webhook-url: ${{ secrets.SLACK_WEBHOOK }}
        payload: |
          {
            "text": "Workflow ${{ job.status }}",
            "blocks": [
              {
                "type": "section",
                "text": {
                  "type": "mrkdwn",
                  "text": "*GitHub Actions Workflow* \n Status: ${{ job.status }} \n Repository: ${{ github.repository }} \n Branch: ${{ github.ref_name }}"
                }
              }
            ]
          }
```

## Enterprise Features

### Role-Based Access Control (RBAC)
```yaml
# GitHub Organization Settings
# - Owner: Full access to all repositories
# - Maintainer: Can modify repository settings, manage workflows
# - Write: Can create branches, commit changes, run workflows
# - Read: Can view workflows, run status
```

### Audit Logging
- All workflow runs are logged in GitHub audit log
- Access to Settings > Audit log in organization
- Export logs via API for compliance

### Secrets Management

**Add Secrets:**
1. Go to Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add secret key and value

**Use Secrets in Workflows:**
```yaml
steps:
  - name: Use secret
    env:
      MY_SECRET: ${{ secrets.MY_SECRET }}
    run: echo "Secret length: ${#MY_SECRET}"
```

**Organization Secrets:**
- Available to multiple repositories
- Settings > Secrets and variables > Actions (Organization level)

### Environment Protection Rules
```yaml
deploy:
  environment:
    name: production
    url: https://app.example.com
  # Requires manual approval before deployment
  # Settings > Environments > production > Required reviewers
```

## Performance Optimization

### Caching Dependencies
```yaml
- name: Cache Node.js dependencies
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Parallel Job Execution
```yaml
strategy:
  matrix:
    include:
      - node: 16
        os: ubuntu-latest
      - node: 18
        os: ubuntu-latest
      - node: 20
        os: ubuntu-latest
```

### Conditional Job Execution
```yaml
test:
  if: github.event_name == 'pull_request'
  runs-on: ubuntu-latest

deploy:
  if: github.ref == 'refs/heads/main'
  runs-on: ubuntu-latest
```

## Security Hardening

### Use pinned action versions
```yaml
# Good
- uses: actions/checkout@v4  # Pinned to major version

# Better
- uses: actions/checkout@44c82b93b3d5a059ad0107bee13284de5d4c6e5b  # Pinned to commit SHA
```

### Limit permissions
```yaml
permissions:
  contents: read
  pull-requests: read
  checks: write

jobs:
  build:
    permissions:
      contents: read
      packages: write
```

### Use OIDC for cloud authentication
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Assume AWS role
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT:role/github-actions-role
          aws-region: us-east-1
```

## High Availability & Disaster Recovery

### Self-Hosted Runners for HA
```yaml
runs-on:
  - self-hosted
  - linux
  - x64
```

### Backup Strategies
- Use git branches for workflow versioning
- Export critical workflows via API
- Maintain documentation in wiki

## Troubleshooting

### Common Issues

**Issue: Workflow not triggering**
- Verify YAML syntax (use GitHub's workflow editor)
- Check branch name matches trigger conditions
- Ensure file is in `.github/workflows/`

**Issue: Secret not available**
- Secrets are case-sensitive
- Must reference with `${{ secrets.SECRET_NAME }}`
- Confirm secret is set in Settings > Secrets

**Issue: Job timeout**
- Default timeout: 360 minutes
- Increase with `timeout-minutes: 600`
- Check for stuck processes in logs

**Issue: Out of disk space**
- Clean up artifacts: `run: df -h`
- Remove build artifacts: `run: rm -rf node_modules/`

### Debug Mode
```yaml
- name: Enable debug logging
  env:
    RUNNER_DEBUG: '1'
  run: npm test
```

## Links & Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Action Marketplace](https://github.com/marketplace?type=actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/guides/about-service-containers)
- [Security Hardening](https://docs.github.com/en/actions/security-guides)
- [Pricing & Free Minutes](https://github.com/pricing/features/actions)
