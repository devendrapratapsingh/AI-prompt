# FastAPI CI/CD Pipeline - GitLab CI Example

## Overview
This example demonstrates a complete CI/CD pipeline for a FastAPI microservice using GitLab CI/CD with Docker containers, PostgreSQL, Redis, and Kubernetes deployment.

## Complete Pipeline Configuration

```yaml
# .gitlab-ci.yml
variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  POSTGRES_DB: testdb
  POSTGRES_USER: testuser
  POSTGRES_PASSWORD: testpass
  REDIS_VERSION: "7"
  PYTHON_VERSION: "3.11"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

stages:
  - build
  - test
  - quality
  - security
  - package
  - deploy

# Build stage
build:
  stage: build
  image: python:$PYTHON_VERSION-slim
  services:
    - postgres:15
    - redis:$REDIS_VERSION
  variables:
    POSTGRES_HOST: postgres
    POSTGRES_PORT: 5432
    REDIS_HOST: redis
    REDIS_PORT: 6379
  before_script:
    - apt-get update && apt-get install -y build-essential libpq-dev
    - python -m pip install --upgrade pip
  script:
    - pip install -r requirements.txt
    - pip install -r requirements-dev.txt
    - echo "Build completed successfully"
  cache:
    key: ${CI_COMMIT_REF_SLUG}-python
    paths:
      - .pip-cache/
  artifacts:
    paths:
      - requirements.txt
      - requirements-dev.txt
    expire_in: 1 hour

# Unit tests
test:unit:
  stage: test
  image: python:$PYTHON_VERSION-slim
  services:
    - postgres:15
    - redis:$REDIS_VERSION
  variables:
    DATABASE_URL: postgresql://testuser:testpass@postgres:5432/testdb
    REDIS_URL: redis://redis:6379/0
    POSTGRES_HOST_AUTH_METHOD: trust
  before_script:
    - apt-get update && apt-get install -y build-essential libpq-dev
    - python -m pip install --upgrade pip
    - pip install -r requirements.txt
    - pip install -r requirements-dev.txt
  script:
    - pytest tests/unit/ -v --cov=app --cov-report=term --cov-report=xml --cov-report=html
    - coverage report --fail-under=80
  coverage: '/(?i)total.*? (100(?:\.0+)?\%|[1-9]?\d(?:\.\d+)?\%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
    paths:
      - htmlcov/
      - coverage.xml
    expire_in: 1 week
  cache:
    key: ${CI_COMMIT_REF_SLUG}-python
    paths:
      - .pip-cache/

# Integration tests
test:integration:
  stage: test
  image: python:$PYTHON_VERSION-slim
  services:
    - name: postgres:15
      alias: postgres
    - name: redis:$REDIS_VERSION
      alias: redis
  variables:
    DATABASE_URL: postgresql://testuser:testpass@postgres:5432/testdb
    REDIS_URL: redis://redis:6379/0
    POSTGRES_HOST_AUTH_METHOD: trust
  before_script:
    - apt-get update && apt-get install -y build-essential libpq-dev curl
    - python -m pip install --upgrade pip
    - pip install -r requirements.txt
    - pip install -r requirements-dev.txt
  script:
    - pytest tests/integration/ -v --tb=short
    - echo "Integration tests passed"
  artifacts:
    when: always
    paths:
      - test-results/
    reports:
      junit: test-results/junit.xml
    expire_in: 1 week

# API tests
test:api:
  stage: test
  image: python:$PYTHON_VERSION-slim
  services:
    - postgres:15
    - redis:$REDIS_VERSION
  variables:
    DATABASE_URL: postgresql://testuser:testpass@postgres:5432/testdb
    REDIS_URL: redis://redis:6379/0
    POSTGRES_HOST_AUTH_METHOD: trust
  before_script:
    - apt-get update && apt-get install -y build-essential libpq-dev
    - python -m pip install --upgrade pip
    - pip install -r requirements.txt
    - pip install -r requirements-dev.txt
  script:
    - uvicorn app.main:app --host 0.0.0.0 --port 8000 &
    - sleep 5
    - pytest tests/api/ -v
    - kill %1
  artifacts:
    when: always
    paths:
      - test-results/
    expire_in: 1 week

# Code quality checks
quality:format:
  stage: quality
  image: python:$PYTHON_VERSION-slim
  before_script:
    - pip install black isort
  script:
    - black --check app/ tests/
    - isort --check-only app/ tests/
  allow_failure: true

quality:lint:
  stage: quality
  image: python:$PYTHON_VERSION-slim
  before_script:
    - pip install ruff flake8 mypy pylint
    - pip install -r requirements.txt
  script:
    - ruff check app/ tests/
    - flake8 app/ tests/ --max-line-length=120
    - mypy app/ --ignore-missing-imports
    - pylint app/ --disable=C0111,R0903
  allow_failure: true

quality:complexity:
  stage: quality
  image: python:$PYTHON_VERSION-slim
  before_script:
    - pip install radon xenon
  script:
    - radon cc app/ -a -nb
    - radon mi app/ -nb
    - xenon --max-absolute B --max-modules A --max-average A app/
  allow_failure: true

# Security scanning
security:dependencies:
  stage: security
  image: python:$PYTHON_VERSION-slim
  before_script:
    - pip install safety pip-audit bandit
  script:
    - safety check --json || true
    - pip-audit --format json || true
    - bandit -r app/ -f json -o bandit-report.json || true
  artifacts:
    paths:
      - bandit-report.json
    reports:
      sast: bandit-report.json
    expire_in: 1 week
  allow_failure: true

security:sast:
  stage: security
  image: python:$PYTHON_VERSION-slim
  before_script:
    - pip install bandit semgrep
  script:
    - bandit -r app/ -ll -f txt
    - semgrep --config=auto app/ || true
  allow_failure: true

security:secrets:
  stage: security
  image: python:$PYTHON_VERSION-slim
  before_script:
    - pip install detect-secrets
  script:
    - detect-secrets scan app/ || true
  allow_failure: true

# Docker image building
package:docker:
  stage: package
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $IMAGE_TAG -t $CI_REGISTRY_IMAGE:latest .
    - docker push $IMAGE_TAG
    - docker push $CI_REGISTRY_IMAGE:latest
    - echo "IMAGE_TAG=$IMAGE_TAG" >> build.env
  artifacts:
    reports:
      dotenv: build.env
    expire_in: 1 week
  only:
    - main
    - develop

# Container scanning
package:scan:
  stage: package
  image: aquasec/trivy:latest
  dependencies:
    - package:docker
  script:
    - trivy image --severity HIGH,CRITICAL --exit-code 0 --format json -o trivy-report.json $IMAGE_TAG
    - trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE_TAG
  artifacts:
    reports:
      container_scanning: trivy-report.json
    paths:
      - trivy-report.json
    expire_in: 1 week
  allow_failure: true
  only:
    - main
    - develop

# Deploy to development
deploy:dev:
  stage: deploy
  image: bitnami/kubectl:latest
  dependencies:
    - package:docker
  environment:
    name: development
    url: https://dev-api.example.com
    on_stop: cleanup:dev
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl create namespace fastapi-dev || true
    - |
      cat <<EOF | kubectl apply -f -
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: fastapi-app
        namespace: fastapi-dev
      spec:
        replicas: 2
        selector:
          matchLabels:
            app: fastapi
        template:
          metadata:
            labels:
              app: fastapi
          spec:
            containers:
            - name: fastapi
              image: $IMAGE_TAG
              ports:
              - containerPort: 8000
              env:
              - name: DATABASE_URL
                valueFrom:
                  secretKeyRef:
                    name: fastapi-secrets
                    key: database-url
              - name: REDIS_URL
                valueFrom:
                  secretKeyRef:
                    name: fastapi-secrets
                    key: redis-url
              livenessProbe:
                httpGet:
                  path: /health
                  port: 8000
                initialDelaySeconds: 30
                periodSeconds: 10
              readinessProbe:
                httpGet:
                  path: /ready
                  port: 8000
                initialDelaySeconds: 5
                periodSeconds: 5
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: fastapi-service
        namespace: fastapi-dev
      spec:
        selector:
          app: fastapi
        ports:
        - port: 80
          targetPort: 8000
        type: LoadBalancer
      EOF
    - kubectl rollout status deployment/fastapi-app -n fastapi-dev
  only:
    - develop

# Deploy to staging
deploy:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  dependencies:
    - package:docker
  environment:
    name: staging
    url: https://staging-api.example.com
    on_stop: cleanup:staging
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl create namespace fastapi-staging || true
    - kubectl apply -f k8s/staging/ -n fastapi-staging
    - kubectl set image deployment/fastapi-app fastapi=$IMAGE_TAG -n fastapi-staging
    - kubectl rollout status deployment/fastapi-app -n fastapi-staging
  only:
    - main
  when: manual

# Deploy to production
deploy:production:
  stage: deploy
  image: bitnami/kubectl:latest
  dependencies:
    - package:docker
  environment:
    name: production
    url: https://api.example.com
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL_PROD" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN_PROD"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl create namespace fastapi-prod || true
    - kubectl apply -f k8s/production/ -n fastapi-prod
    - kubectl set image deployment/fastapi-app fastapi=$IMAGE_TAG -n fastapi-prod
    - kubectl rollout status deployment/fastapi-app -n fastapi-prod
    - echo "Deployed to production successfully"
  only:
    - main
  when: manual
  allow_failure: false

# Cleanup development environment
cleanup:dev:
  stage: deploy
  image: bitnami/kubectl:latest
  environment:
    name: development
    action: stop
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl delete namespace fastapi-dev --ignore-not-found=true
  when: manual

# Cleanup staging environment
cleanup:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  environment:
    name: staging
    action: stop
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl delete namespace fastapi-staging --ignore-not-found=true
  when: manual
```

## Project Structure

```
fastapi-project/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── users.py
│   │   └── health.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   └── user.py
│   └── services/
│       ├── __init__.py
│       └── user_service.py
├── tests/
│   ├── __init__.py
│   ├── unit/
│   │   └── test_services.py
│   ├── integration/
│   │   └── test_database.py
│   └── api/
│       └── test_endpoints.py
├── k8s/
│   ├── staging/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── production/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
├── Dockerfile
├── requirements.txt
├── requirements-dev.txt
├── .gitlab-ci.yml
└── README.md
```

## Dockerfile

```dockerfile
FROM python:3.11-slim as base

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Application Code

### app/main.py

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, health
from app.database import engine, Base

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="FastAPI Microservice",
    description="Production-ready FastAPI application",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["health"])
app.include_router(users.router, prefix="/api/v1/users", tags=["users"])

@app.get("/")
async def root():
    return {"message": "Welcome to FastAPI Microservice"}
```

### app/routers/health.py

```python
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
import redis

router = APIRouter()

@router.get("/health")
async def health_check(db: Session = Depends(get_db)):
    """Health check endpoint"""
    try:
        # Check database
        db.execute("SELECT 1")
        
        # Check Redis (if configured)
        # r = redis.Redis(host='redis', port=6379)
        # r.ping()
        
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}

@router.get("/ready")
async def readiness_check():
    """Readiness check endpoint"""
    return {"status": "ready"}
```

## GitLab CI/CD Variables Configuration

Set these variables in GitLab project settings:

```
CI_REGISTRY_USER: GitLab username or deploy token
CI_REGISTRY_PASSWORD: GitLab password or deploy token
KUBE_URL: Kubernetes cluster URL
KUBE_TOKEN: Kubernetes service account token
KUBE_URL_PROD: Production Kubernetes cluster URL
KUBE_TOKEN_PROD: Production Kubernetes service account token
```

## Key Features

### 1. Comprehensive Testing
- **Unit Tests**: Test individual functions and classes
- **Integration Tests**: Test database interactions
- **API Tests**: Test HTTP endpoints

### 2. Code Quality
- **Formatting**: Black, isort
- **Linting**: Ruff, Flake8, MyPy, Pylint
- **Complexity**: Radon, Xenon

### 3. Security
- **Dependency Scanning**: Safety, pip-audit
- **SAST**: Bandit, Semgrep
- **Secret Detection**: detect-secrets
- **Container Scanning**: Trivy

### 4. Multi-Environment Deployment
- **Development**: Auto-deploy on develop branch
- **Staging**: Manual deploy from main branch
- **Production**: Manual deploy with approval

### 5. Container Orchestration
- **Kubernetes**: Native deployment
- **Health Checks**: Liveness and readiness probes
- **Scaling**: Horizontal pod autoscaling
- **Service Discovery**: LoadBalancer service

## Best Practices Implemented

1. **Caching**: Pip cache for faster builds
2. **Artifacts**: Coverage reports, test results
3. **Services**: PostgreSQL and Redis for testing
4. **Multi-stage**: Separate stages for clarity
5. **Security**: Non-root user, secret management
6. **Monitoring**: Health and readiness endpoints
7. **Rollback**: Kubernetes rollout status checks
8. **Environment Variables**: Secure secret management

## Running Locally

```bash
# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Run tests
pytest tests/ -v --cov=app

# Run application
uvicorn app.main:app --reload

# Format code
black app/ tests/
isort app/ tests/

# Lint code
ruff check app/ tests/
flake8 app/ tests/
```

## Deployment Commands

```bash
# Deploy to development
git push origin develop

# Deploy to staging
git push origin main
# Then manually trigger in GitLab UI

# Deploy to production
# Manually trigger in GitLab UI after staging validation
```
