# Node.js Express CI/CD Pipeline - Azure Pipelines Example

## Overview
This example demonstrates a complete CI/CD pipeline for a Node.js Express microservice using Azure Pipelines with MongoDB, Redis, and Azure Kubernetes Service.

## Complete Pipeline Configuration

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pr:
  branches:
    include:
      - main

variables:
  - group: production-secrets
  - name: nodeVersion
    value: '18.x'
  - name: vmImageName
    value: 'ubuntu-latest'
  - name: dockerRegistryServiceConnection
    value: 'myACRConnection'
  - name: imageRepository
    value: 'express-app'
  - name: containerRegistry
    value: 'myregistry.azurecr.io'
  - name: dockerfilePath
    value: '$(Build.SourcesDirectory)/Dockerfile'
  - name: tag
    value: '$(Build.BuildId)'

stages:
  - stage: Build
    displayName: 'Build Stage'
    jobs:
      - job: Build
        displayName: 'Build Node.js Application'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: NodeTool@0
            displayName: 'Install Node.js'
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: |
              node --version
              npm --version
            displayName: 'Display versions'
          
          - task: Cache@2
            displayName: 'Cache npm packages'
            inputs:
              key: 'npm | "$(Agent.OS)" | package-lock.json'
              path: '$(Pipeline.Workspace)/.npm'
              restoreKeys: |
                npm | "$(Agent.OS)"
          
          - script: |
              npm ci --cache $(Pipeline.Workspace)/.npm
              npm run build
            displayName: 'npm install and build'
          
          - task: PublishBuildArtifacts@1
            displayName: 'Publish build artifacts'
            inputs:
              PathtoPublish: 'dist'
              ArtifactName: 'dist'
              publishLocation: 'Container'

  - stage: Test
    displayName: 'Test Stage'
    dependsOn: Build
    jobs:
      - job: UnitTests
        displayName: 'Unit Tests'
        pool:
          vmImage: $(vmImageName)
        
        services:
          mongodb:
            image: mongo:6
            ports:
              - 27017:27017
          
          redis:
            image: redis:7
            ports:
              - 6379:6379
        
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: |
              npm run test:unit -- --coverage --ci --reporters=default --reporters=jest-junit
            displayName: 'Run unit tests'
            env:
              MONGODB_URI: mongodb://localhost:27017/testdb
              REDIS_URL: redis://localhost:6379
          
          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/junit.xml'
              testRunTitle: 'Unit Tests'
              mergeTestResults: true
              failTaskOnFailedTests: true
          
          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/coverage/cobertura-coverage.xml'
              reportDirectory: '$(System.DefaultWorkingDirectory)/**/coverage'

      - job: IntegrationTests
        displayName: 'Integration Tests'
        pool:
          vmImage: $(vmImageName)
        
        services:
          mongodb:
            image: mongo:6
          redis:
            image: redis:7
        
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: npm run test:integration
            displayName: 'Run integration tests'
            env:
              MONGODB_URI: mongodb://localhost:27017/testdb
              REDIS_URL: redis://localhost:6379

      - job: E2ETests
        displayName: 'E2E Tests'
        pool:
          vmImage: $(vmImageName)
        
        services:
          mongodb:
            image: mongo:6
          redis:
            image: redis:7
        
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: |
              npm ci
              npm start &
              sleep 10
              npm run test:e2e
            displayName: 'Run E2E tests'
            env:
              MONGODB_URI: mongodb://localhost:27017/testdb
              REDIS_URL: redis://localhost:6379

  - stage: Quality
    displayName: 'Code Quality'
    dependsOn: Build
    jobs:
      - job: CodeQuality
        displayName: 'Code Quality Checks'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: npm run lint
            displayName: 'ESLint'
            continueOnError: true
          
          - script: npm run format:check
            displayName: 'Prettier check'
            continueOnError: true
          
          - script: npm run type-check
            displayName: 'TypeScript check'
            continueOnError: true

  - stage: Security
    displayName: 'Security Scanning'
    dependsOn: Build
    jobs:
      - job: SecurityScan
        displayName: 'Security Scans'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: |
              npm audit --audit-level=high || true
              npm audit --json > npm-audit.json || true
            displayName: 'npm audit'
            continueOnError: true
          
          - script: |
              npm install -g snyk
              snyk test --json > snyk-report.json || true
            displayName: 'Snyk security scan'
            env:
              SNYK_TOKEN: $(SNYK_TOKEN)
            continueOnError: true
          
          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: 'snyk-report.json'
              ArtifactName: 'security-reports'

  - stage: Package
    displayName: 'Build Docker Image'
    dependsOn:
      - Test
      - Quality
      - Security
    condition: and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), eq(variables['Build.SourceBranch'], 'refs/heads/develop')))
    jobs:
      - job: DockerBuild
        displayName: 'Build and Push Docker Image'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: Docker@2
            displayName: 'Login to ACR'
            inputs:
              command: login
              containerRegistry: $(dockerRegistryServiceConnection)
          
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
              arguments: '--build-arg NODE_VERSION=$(nodeVersion)'
          
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
        environment: 'express-dev'
        pool:
          vmImage: $(vmImageName)
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureWebAppContainer@1
                  displayName: 'Deploy to Azure Web App'
                  inputs:
                    azureSubscription: 'MyAzureSubscription'
                    appName: 'express-app-dev'
                    containers: '$(containerRegistry)/$(imageRepository):$(tag)'
                    configurationStrings: |
                      -NODE_ENV "development" \
                      -MONGODB_URI "$(DEV_MONGODB_URI)" \
                      -REDIS_URL "$(DEV_REDIS_URL)"

  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Package
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployStaging
        displayName: 'Deploy to Staging Environment'
        environment: 'express-staging'
        pool:
          vmImage: $(vmImageName)
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: Kubernetes@1
                  displayName: 'Deploy to AKS'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'express-staging'
                    command: 'apply'
                    arguments: '-f k8s/staging/'
                
                - task: Kubernetes@1
                  displayName: 'Update image'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'express-staging'
                    command: 'set'
                    arguments: 'image deployment/express-app express=$(containerRegistry)/$(imageRepository):$(tag)'

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProduction
        displayName: 'Deploy to Production Environment'
        environment: 'express-production'
        pool:
          vmImage: $(vmImageName)
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: Kubernetes@1
                  displayName: 'Deploy to AKS'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'express-prod'
                    command: 'apply'
                    arguments: '-f k8s/production/'
                
                - task: Kubernetes@1
                  displayName: 'Update image'
                  inputs:
                    connectionType: 'Azure Resource Manager'
                    azureSubscriptionEndpoint: 'MyAzureSubscription'
                    azureResourceGroup: 'my-resource-group'
                    kubernetesCluster: 'my-aks-cluster'
                    namespace: 'express-prod'
                    command: 'set'
                    arguments: 'image deployment/express-app express=$(containerRegistry)/$(imageRepository):$(tag)'
```

## Dockerfile

```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY . .
RUN npm run build

FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache dumb-init

RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

COPY --from=builder --chown=appuser:appuser /app/dist ./dist
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser package*.json ./

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["dumb-init", "node", "dist/index.js"]
```

## Key Features

1. **Multi-Stage Pipeline**: Build → Test → Quality → Security → Package → Deploy
2. **Azure Integration**: ACR, AKS, Web Apps
3. **Caching**: npm package caching for faster builds
4. **Testing**: Unit, Integration, E2E tests with coverage
5. **Security**: npm audit, Snyk, Trivy scanning
6. **Multi-Environment**: Dev, Staging, Production

## Running Locally

```bash
npm install
npm test
npm run dev
npm run lint
```

## Deployment

- Push to `develop` → Auto-deploy to Dev
- Push to `main` → Deploy to Staging (manual approve Production)
