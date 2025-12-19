# GitHub Actions - Advanced Configuration Guide

## Advanced Features Overview

This guide covers enterprise-grade features for scalable, secure CI/CD pipelines.

## 1. Matrix Strategies

### Basic Matrix

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
        os: [ubuntu-latest, windows-latest]
    
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      
      - run: npm test
```

### Conditional Matrix Inclusions

```yaml
strategy:
  matrix:
    include:
      - os: ubuntu-latest
        node-version: 16.x
      - os: ubuntu-latest
        node-version: 18.x
      - os: windows-latest
        node-version: 20.x
  exclude:
    - os: windows-latest
      node-version: 16.x  # Skip old Node on Windows
```

### Exclude Matrix Combinations

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    node-version: [16.x, 18.x, 20.x]
  exclude:
    - os: macos-latest
      node-version: 16.x
```

## 2. Reusable Workflows

### Create Reusable Workflow

Create `.github/workflows/test.yml`:

```yaml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        type: string
        required: true
        default: '18'
    secrets:
      npm-token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          registry-url: 'https://npm.pkg.github.com'
      
      - run: npm install
        env:
          NODE_AUTH_TOKEN: ${{ secrets.npm-token }}
      
      - run: npm test
```

### Call Reusable Workflow

```yaml
jobs:
  test-node-18:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '18'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}

  test-node-20:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '20'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

## 3. Custom Actions

### Create Custom Action

Create `.github/actions/deploy/action.yml`:

```yaml
name: 'Deploy Application'
description: 'Deploy to production'

inputs:
  environment:
    description: 'Deployment environment'
    required: true
  version:
    description: 'Application version'
    required: true

outputs:
  deployment-url:
    description: 'URL of deployed application'
    value: ${{ steps.deploy.outputs.url }}

runs:
  using: 'composite'
  steps:
    - name: Deploy
      id: deploy
      shell: bash
      run: |
        echo "Deploying ${{ inputs.version }} to ${{ inputs.environment }}"
        DEPLOY_URL="https://${{ inputs.environment }}.example.com"
        echo "url=$DEPLOY_URL" >> $GITHUB_OUTPUT
```

### Use Custom Action

```yaml
- uses: ./.github/actions/deploy
  with:
    environment: staging
    version: ${{ github.sha }}
```

## 4. Environment Secrets & Variables

### Organization-Level Secrets

Set in: Organization Settings > Secrets and variables > Actions

```yaml
jobs:
  deploy:
    environment: production
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.PROD_API_KEY }}
        run: deploy.sh
```

### Repository Variables

```yaml
jobs:
  build:
    env:
      APP_NAME: ${{ vars.APP_NAME }}
      BUILD_ENV: ${{ vars.BUILD_ENVIRONMENT }}
    steps:
      - run: echo "Building ${{ env.APP_NAME }}"
```

### Environment Protection Rules

```yaml
deploy:
  environment:
    name: production
    url: https://app.example.com
  # Requires manual approval (configure in Settings > Environments)
  steps:
    - run: deploy.sh
```

## 5. Conditional Job Execution

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  # Only run on PRs
  comment-pr:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: 'Build completed successfully'
            })

  # Only on main branch
  deploy-production:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - run: deploy.sh

  # Only on version tags
  release:
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - run: publish.sh
```

## 6. Container Jobs

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    
    # Run job in custom Docker container
    container:
      image: node:18-alpine
      options: --cpus 2 --memory 4g
      env:
        NODE_ENV: test
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    
    steps:
      - uses: actions/checkout@v4
      - run: npm install
      - run: npm test
        env:
          DATABASE_URL: postgres://postgres:postgres@postgres:5432/test
```

## 7. Cache Management

### Basic Caching

```yaml
- uses: actions/cache@v3
  with:
    path: node_modules/
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

### Multiple Cache Keys

```yaml
- uses: actions/cache@v3
  id: cache
  with:
    path: |
      node_modules/
      ~/.npm
      build/
    key: ${{ runner.os }}-build-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-build-
      ${{ runner.os }}-

- name: Cache hit
  if: steps.cache.outputs.cache-hit == 'true'
  run: echo "Cache hit! Using cached dependencies"
```

### Docker Layer Caching

```yaml
- uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    cache-from: type=registry,ref=myimage:buildcache
    cache-to: type=registry,ref=myimage:buildcache,mode=max
```

## 8. Artifacts & Releases

### Upload Artifacts

```yaml
- name: Upload test results
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: |
      coverage/
      test-reports/
    retention-days: 30
    compression-level: 9

- name: Upload debug logs
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: debug-logs-${{ github.run_id }}
    path: logs/
```

### Download Artifacts

```yaml
- name: Download artifacts
  uses: actions/download-artifact@v4
  with:
    name: test-results
    path: ./results

- name: Display artifacts
  run: ls -la ./results
```

### Create Release

```yaml
- name: Create GitHub Release
  if: startsWith(github.ref, 'refs/tags/')
  uses: softprops/action-gh-release@v1
  with:
    body_path: CHANGELOG.md
    files: |
      dist/app-${{ github.ref_name }}.zip
      dist/app-${{ github.ref_name }}.tar.gz
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 9. OIDC & Trusted Deployments

### AWS Deployment with OIDC

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT:role/github-actions-role
          aws-region: us-east-1
      
      - name: Deploy
        run: |
          aws ecs update-service --cluster prod --service myapp
```

### Azure Deployment with OIDC

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

- name: Deploy to Azure
  run: |
    az webapp deployment source config-zip --resource-group mygroup --name myapp --src-path deployment.zip
```

## 10. Notifications & Webhooks

### Slack Notifications

```yaml
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1.24.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Build failed",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Build Status: FAILED*\nCommit: ${{ github.sha }}\nAuthor: ${{ github.actor }}"
            }
          }
        ]
      }
```

### Custom Webhook

```yaml
- name: Send webhook
  run: |
    curl -X POST https://api.example.com/notify \
      -H 'Content-Type: application/json' \
      -d '{
        "status": "success",
        "commit": "${{ github.sha }}",
        "timestamp": "'$(date -u +'%Y-%m-%dT%H:%M:%SZ')'"
      }'
```

## 11. Performance Tuning

### Parallelize Jobs

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  test:
    needs: build  # Waits for build to complete
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-suite: [unit, integration, e2e]
    steps:
      - run: npm run test:${{ matrix.test-suite }}

  # Run in parallel, only needs test
  deploy:
    needs: test  # Waits for all test jobs
    runs-on: ubuntu-latest
    steps:
      - run: deploy.sh
```

### Fail Fast

```yaml
strategy:
  fail-fast: true  # Cancel other jobs if one fails
  matrix:
    node-version: [16, 18, 20]
```

### Timeouts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
      - name: Build
        timeout-minutes: 15
        run: npm run build
```

## 12. GitHub Script Integration

```yaml
- uses: actions/github-script@v7
  with:
    script: |
      // Get PR details
      const { data: pullRequest } = await github.rest.pulls.get({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: context.issue.number
      });
      
      console.log('PR Title:', pullRequest.title);
      console.log('Author:', pullRequest.user.login);
      
      // Add comment
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: '✅ All checks passed!'
      });
```

## 13. Status Checks & Branch Protection

### Required Status Checks

Configure in: Repository Settings > Branches > Branch protection rules

1. Require status checks to pass before merging
2. Select: `build`, `test`, `security`
3. Require branches to be up to date before merging

### Enforce CODEOWNERS

Create `.github/CODEOWNERS`:
```
* @backend-team
/frontend/* @frontend-team
/docs/* @docs-team
```

## 14. Monitoring & Analytics

### Workflow Insights

- Repository > Insights > Actions
- View: Success rate, run time, job duration
- Filter by: Workflow, branch, actor

### Workflow Run Artifacts

```yaml
- name: Archive logs
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: logs-${{ strategy.job-index }}
    path: logs/
    retention-days: 90
```

## Tips for Enterprise Scale

1. **Use Reusable Workflows** for consistency
2. **Cache Aggressively** to reduce build times
3. **Parallelize Jobs** for faster feedback
4. **Use Branch Protection** to enforce quality
5. **Monitor Build Times** and optimize regularly
6. **Implement OIDC** for secure cloud access
7. **Use Environments** for deployment controls
8. **Document Everything** in workflow comments
9. **Test Locally** with act before pushing
10. **Review Logs** regularly for optimization opportunities
