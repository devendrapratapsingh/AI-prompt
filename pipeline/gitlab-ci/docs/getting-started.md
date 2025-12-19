# GitLab CI/CD - Getting Started Guide

## Quick Start (5-10 minutes)

### Step 1: Create Your First Pipeline File (2 min)

1. In your repository root, create `.gitlab-ci.yml`:
```bash
touch .gitlab-ci.yml
```

2. Add a simple pipeline:
```yaml
# .gitlab-ci.yml
stages:
  - build

hello_world:
  stage: build
  script:
    - echo "Hello, GitLab CI/CD!"
```

3. Commit and push:
```bash
git add .gitlab-ci.yml
git commit -m "Add GitLab CI/CD pipeline"
git push origin main
```

### Step 2: View Your Pipeline (1 min)

1. Go to your GitLab project
2. Click "CI/CD" → "Pipelines" in the left sidebar
3. Click on the running pipeline
4. Click on the job to see the output

### Step 3: Add Build and Test Stages (2 min)

```yaml
stages:
  - build
  - test

build_job:
  stage: build
  script:
    - echo "Building application..."
    - ls -la

test_job:
  stage: test
  script:
    - echo "Running tests..."
    - echo "All tests passed!"
```

### Step 4: Set Up Your Language (2 min)

**For Node.js:**
```yaml
build:node:
  image: node:18
  stage: build
  before_script:
    - node --version
    - npm --version
  script:
    - npm ci
    - npm run build
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour
```

**For Python:**
```yaml
build:python:
  image: python:3.11
  stage: build
  before_script:
    - python --version
    - pip install --upgrade pip
  script:
    - pip install -r requirements.txt
    - python -m pytest
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .pip-cache/
```

**For Go:**
```yaml
build:go:
  image: golang:1.21
  stage: build
  before_script:
    - go version
  script:
    - go mod download
    - go build -v ./...
    - go test -v ./...
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .go/pkg/mod/
```

**For Java:**
```yaml
build:java:
  image: maven:3.9-eclipse-temurin-17
  stage: build
  script:
    - mvn clean compile
    - mvn test
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .m2/repository/
```

### Step 5: Add Docker Build (2 min)

```yaml
docker:build:
  stage: package
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
```

## Common Use Cases

### Multi-Stage Pipeline with Artifacts

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test:
  stage: test
  dependencies:
    - build
  script:
    - npm run test

deploy:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploying application..."
    - rsync -avz dist/ user@server:/var/www/
  only:
    - main
```

### Testing with Services (Database)

```yaml
test:integration:
  image: node:18
  services:
    - name: postgres:15
      alias: postgres
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
    DATABASE_URL: postgres://testuser:testpass@postgres:5432/testdb
  script:
    - npm ci
    - npm run test:integration
```

### Matrix Testing

```yaml
test:
  image: node:$NODE_VERSION
  parallel:
    matrix:
      - NODE_VERSION: ['16', '18', '20']
  script:
    - npm ci
    - npm test
```

### Conditional Execution

```yaml
deploy:staging:
  stage: deploy
  script:
    - echo "Deploying to staging..."
  only:
    - develop
  when: always

deploy:production:
  stage: deploy
  script:
    - echo "Deploying to production..."
  only:
    - main
  when: manual
```

## Using GitLab Runners

### Shared Runners (GitLab.com)
- Available automatically on GitLab.com
- Free tier includes 400 CI/CD minutes per month
- No setup required

### Self-Hosted Runners

#### Install Runner (Ubuntu/Debian)
```bash
# Add GitLab repository
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

# Install runner
sudo apt-get install gitlab-runner

# Verify installation
gitlab-runner --version
```

#### Register Runner
```bash
# Interactive registration
sudo gitlab-runner register

# You'll be prompted for:
# - GitLab instance URL: https://gitlab.com
# - Registration token: (found in Project → Settings → CI/CD → Runners)
# - Description: my-runner
# - Tags: docker,linux
# - Executor: docker
# - Default Docker image: alpine:latest
```

#### Start Runner
```bash
sudo gitlab-runner start
```

## Environment Variables & Secrets

### Predefined Variables
```yaml
build:
  script:
    - echo "Project: $CI_PROJECT_NAME"
    - echo "Branch: $CI_COMMIT_BRANCH"
    - echo "Commit: $CI_COMMIT_SHORT_SHA"
    - echo "Registry: $CI_REGISTRY_IMAGE"
```

### Custom Variables (Project Settings)
1. Go to Project → Settings → CI/CD
2. Expand "Variables"
3. Add variable (e.g., `API_KEY`)
4. Mark as "Protected" or "Masked" as needed

### Using Secrets
```yaml
deploy:
  script:
    - echo "Using API key: $API_KEY"
    - echo "Database: $DATABASE_URL"
  only:
    - main
```

## Caching

### Dependencies Cache
```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/
```

### Global Cache
```yaml
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
```

### Per-Job Cache
```yaml
build:
  cache:
    key: build-cache
    paths:
      - dist/
  script:
    - npm run build

test:
  cache:
    key: test-cache
    paths:
      - node_modules/
  script:
    - npm test
```

## Artifacts

### Basic Artifacts
```yaml
build:
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week
```

### Test Reports
```yaml
test:
  script:
    - npm run test -- --coverage
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

## Troubleshooting

### Pipeline Not Running
1. Check `.gitlab-ci.yml` syntax: Project → CI/CD → Editor → Validate
2. Verify runner availability: Project → Settings → CI/CD → Runners
3. Check branch protection rules

### Job Failing
1. Click on failed job to view logs
2. Check "before_script" commands
3. Verify Docker image availability
4. Check variable values (masked variables won't show)

### Cache Not Working
1. Ensure cache key is consistent
2. Check runner has disk space
3. Try clearing cache: Project → CI/CD → Pipelines → Clear runner caches

### Services Not Connecting
1. Use service alias in connection strings
2. Add health checks or delays
3. Verify network connectivity

## Best Practices

### 1. Use Specific Image Tags
```yaml
# Bad
image: node:latest

# Good
image: node:18.17.1
```

### 2. Fail Fast
```yaml
stages:
  - validate
  - build
  - test

validate:
  stage: validate
  script:
    - npm run lint
```

### 3. Use Templates
```yaml
.test_template:
  image: node:18
  before_script:
    - npm ci
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/

test:unit:
  extends: .test_template
  script:
    - npm run test:unit

test:integration:
  extends: .test_template
  script:
    - npm run test:integration
```

### 4. Optimize Pipeline Duration
- Use cache effectively
- Run jobs in parallel
- Use smaller Docker images
- Avoid unnecessary dependencies

### 5. Secure Your Pipeline
- Mark sensitive variables as "Masked"
- Use "Protected" variables for sensitive branches
- Don't commit secrets
- Scan dependencies regularly

## Next Steps

1. **Read the full documentation**: [README.md](../README.md)
2. **Explore examples**: Check the `examples/` directory
3. **Advanced configuration**: See `docs/advanced-configuration.md`
4. **Set up automated deployment**: Use deployment jobs
5. **Integrate security scanning**: Add SAST, DAST, dependency scanning

## Quick Reference

### Common Commands
```bash
# Validate .gitlab-ci.yml locally
gitlab-runner exec docker test

# Lint GitLab CI config
curl --header "Content-Type: application/json" \
  https://gitlab.com/api/v4/ci/lint --data '{"content": "$(cat .gitlab-ci.yml)"}'

# View runner status
gitlab-runner status

# Clear runner cache
gitlab-runner cache-clear
```

### Useful Links
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [.gitlab-ci.yml Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [Predefined Variables](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)
- [GitLab Runner](https://docs.gitlab.com/runner/)

## Support

For issues or questions:
- Check [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- Visit [GitLab Community Forum](https://forum.gitlab.com/)
- Open an issue in your project
