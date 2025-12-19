# FastAPI CI/CD Pipeline - Azure Pipelines Example

## Overview
This example demonstrates a complete CI/CD pipeline for a FastAPI microservice using Azure Pipelines with Docker, PostgreSQL, Redis, and Azure Kubernetes Service deployment.

## Complete Pipeline Configuration

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - app/*
      - tests/*
      - requirements.txt

pr:
  branches:
    include:
      - main

variables:
  - group: production-secrets
  - name: pythonVersion
    value: '3.11'
  - name: vmImageName
    value: 'ubuntu-latest'
  - name: dockerRegistryServiceConnection
    value: 'myACRConnection'
  - name: imageRepository
    value: 'fastapi-app'
  - name: containerRegistry
    value: 'myregistry.azurecr.io'
  - name: dockerfilePath
    value: '$(Build.SourcesDirectory)/Dockerfile'
  - name: tag
    value: '$(Build.BuildId)'

stages:
  - stage: Build
    displayName: 'Build and Test'
    jobs:
      - job: Build
        displayName: 'Build FastAPI Application'
        pool:
          vmImage: $(vmImageName)
        
        services:
          postgres:
            image: postgres:15
            env:
              POSTGRES_PASSWORD: postgres
              POSTGRES_DB: testdb
            ports:
              - 5432:5432
          
          redis:
            image: redis:7
            ports:
              - 6379:6379
        
        steps:
          - task: UsePythonVersion@0
            displayName: 'Use Python $(pythonVersion)'
            inputs:
              versionSpec: '$(pythonVersion)'
              architecture: 'x64'
          
          - script: |
              python -m pip install --upgrade pip
              pip install -r requirements.txt
              pip install -r requirements-dev.txt
            displayName: 'Install dependencies'
          
          - script: |
              black --check app/ tests/
            displayName: 'Check code formatting with Black'
            continueOnError: true
          
          - script: |
              isort --check-only app/ tests/
            displayName: 'Check import sorting with isort'
            continueOnError: true
          
          - script: |
              ruff check app/ tests/
            displayName: 'Lint with Ruff'
            continueOnError: true
          
          - script: |
              flake8 app/ tests/ --max-line-length=120
            displayName: 'Lint with Flake8'
            continueOnError: true
          
          - script: |
              mypy app/ --ignore-missing-imports
            displayName: 'Type check with MyPy'
            continueOnError: true

  - stage: Test
    displayName: 'Testing Stage'
    dependsOn: Build
    jobs:
      - job: UnitTests
        displayName: 'Unit Tests'
        pool:
          vmImage: $(vmImageName)
        
        services:
          postgres:
            image: postgres:15
            env:
              POSTGRES_PASSWORD: postgres
              POSTGRES_DB: testdb
          redis:
            image: redis:7
        
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '$(pythonVersion)'
          
          - script: |
              pip install -r requirements.txt
              pip install -r requirements-dev.txt
            displayName: 'Install dependencies'
          
          - script: |
              pytest tests/unit/ -v \
                --cov=app \
                --cov-report=term \
                --cov-report=xml \
                --cov-report=html \
                --junitxml=junit/test-results.xml
            displayName: 'Run unit tests'
            env:
              DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
              REDIS_URL: redis://localhost:6379/0
          
          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/test-results.xml'
              testRunTitle: 'Python $(pythonVersion) Unit Tests'
          
          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/coverage.xml'
              reportDirectory: '$(System.DefaultWorkingDirectory)/**/htmlcov'

      - job: IntegrationTests
        displayName: 'Integration Tests'
        pool:
          vmImage: $(vmImageName)
        
        services:
          postgres:
            image: postgres:15
            env:
              POSTGRES_PASSWORD: postgres
              POSTGRES_DB: testdb
          redis:
            image: redis:7
        
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '$(pythonVersion)'
          
          - script: |
              pip install -r requirements.txt
              pip install -r requirements-dev.txt
            displayName: 'Install dependencies'
          
          - script: |
              pytest tests/integration/ -v --tb=short
            displayName: 'Run integration tests'
            env:
              DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
              REDIS_URL: redis://localhost:6379/0

      - job: APITests
        displayName: 'API Tests'
        pool:
          vmImage: $(vmImageName)
        
        services:
          postgres:
            image: postgres:15
            env:
              POSTGRES_PASSWORD: postgres
              POSTGRES_DB: testdb
          redis:
            image: redis:7
        
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '$(pythonVersion)'
          
          - script: |
              pip install -r requirements.txt
              pip install -r requirements-dev.txt
            displayName: 'Install dependencies'
          
          - script: |
              uvicorn app.main:app --host 0.0.0.0 --port 8000 &
              sleep 10
              pytest tests/api/ -v
            displayName: 'Run API tests'
            env:
              DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
              REDIS_URL: redis://localhost:6379/0

  - stage: Security
    displayName: 'Security Scanning'
    dependsOn: Build
    jobs:
      - job: SecurityScan
        displayName: 'Security Scanning'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '$(pythonVersion)'
          
          - script: |
              pip install safety pip-audit bandit
            displayName: 'Install security tools'
          
          - script: |
              safety check --json || true
            displayName: 'Safety dependency scan'
            continueOnError: true
          
          - script: |
              pip-audit --format json || true
            displayName: 'pip-audit scan'
            continueOnError: true
          
          - script: |
              bandit -r app/ -f json -o bandit-report.json || true
              bandit -r app/ -ll
            displayName: 'Bandit SAST scan'
            continueOnError: true
          
          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: 'bandit-report.json'
              ArtifactName: 'security-reports'

  - stage: Package
    displayName: 'Build Docker Image'
    dependsOn:
      - Test
      - Security
    condition: and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), eq(variables['Build.SourceBranch'], 'refs/heads/develop')))
    jobs:
      - job: DockerBuild
        displayName: 'Build and Push Docker Image'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: Docker@2
            displayName: 'Build Docker image'
            inputs:
              command: build
              repository: $(imageRepository)
              dockerfile: $(dockerfilePath)
              containerRegistry: $(dockerRegistryServiceConnection)
              tags: |
                $(tag)
                latest
          
          - task: Docker@2
            displayName: 'Push Docker image'
            inputs:
              command: push
              repository: $(imageRepository)
              containerRegistry: $(dockerRegistryServiceConnection)
              tags: |
                $(tag)
                latest
          
          - script: |
              docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy:latest image --severity HIGH,CRITICAL \
                $(containerRegistry)/$(imageRepository):$(tag)
            displayName: 'Trivy container scan'
            continueOnError: true

  - stage: DeployDev
    displayName: 'Deploy to Development'
    dependsOn: Package
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
    jobs:
      - deployment: DeployDev
        displayName: 'Deploy to Dev Environment'
        environment: 'fastapi-dev'
        pool:
          vmImage: $(vmImageName)
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureWebAppContainer@1
                  displayName: 'Deploy to Azure Web App for Containers'
                  inputs:
                    azureSubscription: 'MyAzureSubscription'
                    appName: 'fastapi-app-dev'
                    containers: '$(containerRegistry)/$(imageRepository):$(tag)'
                    configurationStrings: |
                      -DATABASE_URL "$(DEV_DATABASE_URL)" \
                      -REDIS_URL "$(DEV_REDIS_URL)"

  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Package
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployStaging
        displayName: 'Deploy to Staging Environment'
        environment: 'fastapi-staging'
        pool:
          vmImage: $(vmImageName)
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: Kubernetes@1
                  displayName: 'kubectl apply'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'fastapi-staging'
                    command: 'apply'
                    arguments: '-f k8s/staging/'
                
                - task: Kubernetes@1
                  displayName: 'Update deployment image'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'fastapi-staging'
                    command: 'set'
                    arguments: 'image deployment/fastapi-app fastapi=$(containerRegistry)/$(imageRepository):$(tag)'

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProduction
        displayName: 'Deploy to Production Environment'
        environment: 'fastapi-production'
        pool:
          vmImage: $(vmImageName)
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: Kubernetes@1
                  displayName: 'kubectl apply'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'fastapi-prod'
                    command: 'apply'
                    arguments: '-f k8s/production/'
                
                - task: Kubernetes@1
                  displayName: 'Update deployment image'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'fastapi-prod'
                    command: 'set'
                    arguments: 'image deployment/fastapi-app fastapi=$(containerRegistry)/$(imageRepository):$(tag)'
                
                - script: |
                    echo "Waiting for deployment to stabilize..."
                    sleep 60
                  displayName: 'Wait for deployment'
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
│   ├── routers/
│   ├── schemas/
│   └── services/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── api/
├── k8s/
│   ├── staging/
│   └── production/
├── Dockerfile
├── requirements.txt
├── requirements-dev.txt
├── azure-pipelines.yml
└── README.md
```

## Dockerfile

```dockerfile
FROM python:3.11-slim

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

## Azure Resources Setup

### Create Azure Resources

```bash
# Resource Group
az group create --name myResourceGroup --location eastus

# Azure Container Registry
az acr create --resource-group myResourceGroup \
  --name myregistry --sku Basic

# AKS Cluster
az aks create \
  --resource-group myResourceGroup \
  --name my-aks-cluster \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Connect ACR to AKS
az aks update \
  --resource-group myResourceGroup \
  --name my-aks-cluster \
  --attach-acr myregistry
```

### Azure Pipeline Variables

Set these in Azure DevOps Pipeline Library:

```
Production Secrets:
- DEV_DATABASE_URL: Connection string for dev database
- DEV_REDIS_URL: Redis connection for dev
- STAGING_DATABASE_URL: Connection string for staging
- STAGING_REDIS_URL: Redis connection for staging
- PROD_DATABASE_URL: Connection string for production
- PROD_REDIS_URL: Redis connection for production
```

## Key Features

### 1. Multi-Stage Pipeline
- Build with dependencies and linting
- Comprehensive testing (unit, integration, API)
- Security scanning
- Docker packaging
- Multi-environment deployment

### 2. Azure Integration
- Azure Container Registry
- Azure Kubernetes Service
- Azure Web Apps for Containers
- Azure Key Vault for secrets

### 3. Testing & Quality
- Code coverage with Cobertura
- Multiple test types
- Code formatting checks
- Type checking with MyPy

### 4. Security
- Dependency scanning (Safety, pip-audit)
- SAST with Bandit
- Container scanning with Trivy

### 5. Deployment Strategy
- Automatic dev deployment
- Manual staging approval
- Manual production approval
- Health checks post-deployment

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

# Lint
ruff check app/ tests/
flake8 app/ tests/
```

## Deployment

1. Push to `develop` branch for dev deployment
2. Create PR to `main` for staging
3. Merge to `main` triggers staging deployment
4. Manually approve production deployment in Azure DevOps

## Best Practices

1. **Service Connections**: Configure in Azure DevOps
2. **Environment Approvals**: Set up in Environments section
3. **Variable Groups**: Organize secrets by environment
4. **Branch Policies**: Require PR reviews for main
5. **Retention Policies**: Configure build retention
