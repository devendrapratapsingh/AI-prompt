# Azure Pipelines - Advanced Configuration Guide

## Table of Contents
- [Multi-Stage Pipelines](#multi-stage-pipelines)
- [Templates and Reusability](#templates-and-reusability)
- [Variables and Parameters](#variables-and-parameters)
- [Deployment Strategies](#deployment-strategies)
- [Caching](#caching)
- [Service Connections](#service-connections)
- [Environments and Approvals](#environments-and-approvals)
- [Security Best Practices](#security-best-practices)
- [Performance Optimization](#performance-optimization)

## Multi-Stage Pipelines

### Complex Stage Dependencies

```yaml
stages:
  - stage: Build
    jobs:
      - job: BuildApp
        steps:
          - script: echo Building...

  - stage: TestStage
    dependsOn: Build
    jobs:
      - job: UnitTests
        steps:
          - script: echo Unit tests...
      
      - job: IntegrationTests
        steps:
          - script: echo Integration tests...

  - stage: DeployDev
    dependsOn: TestStage
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
    jobs:
      - deployment: DeployToDev
        environment: development
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo Deploying to dev...

  - stage: DeployProd
    dependsOn: TestStage
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployToProd
        environment: production
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo Deploying to prod...
```

### Parallel Stages

```yaml
stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - script: echo Building...

  - stage: Test
    dependsOn: Build
    jobs:
      - job: SecurityScan
        steps:
          - script: echo Security scanning...
      
      - job: PerformanceTest
        steps:
          - script: echo Performance testing...
      
      - job: IntegrationTest
        steps:
          - script: echo Integration testing...
```

## Templates and Reusability

### Job Templates

**templates/build-template.yml:**
```yaml
parameters:
  - name: nodeVersion
    type: string
    default: '18.x'
  - name: buildCommand
    type: string
    default: 'npm run build'

jobs:
  - job: Build
    pool:
      vmImage: 'ubuntu-latest'
    steps:
      - task: NodeTool@0
        inputs:
          versionSpec: ${{ parameters.nodeVersion }}
      
      - script: npm ci
        displayName: 'Install dependencies'
      
      - script: ${{ parameters.buildCommand }}
        displayName: 'Build application'
```

**azure-pipelines.yml:**
```yaml
trigger:
  - main

stages:
  - stage: Build
    jobs:
      - template: templates/build-template.yml
        parameters:
          nodeVersion: '20.x'
          buildCommand: 'npm run build:prod'
```

### Step Templates

**templates/test-steps.yml:**
```yaml
parameters:
  - name: testCommand
    type: string
    default: 'npm test'

steps:
  - script: ${{ parameters.testCommand }}
    displayName: 'Run tests'
  
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    inputs:
      testResultsFormat: 'JUnit'
      testResultsFiles: '**/test-results.xml'
```

**Usage:**
```yaml
jobs:
  - job: Test
    steps:
      - template: templates/test-steps.yml
        parameters:
          testCommand: 'npm run test:ci'
```

### Variable Templates

**templates/variables.yml:**
```yaml
variables:
  - name: buildConfiguration
    value: 'Release'
  - name: vmImageName
    value: 'ubuntu-latest'
  - name: dockerRegistry
    value: 'myregistry.azurecr.io'
```

**Usage:**
```yaml
variables:
  - template: templates/variables.yml

stages:
  - stage: Build
    variables:
      - template: templates/variables.yml
```

## Variables and Parameters

### Runtime Parameters

```yaml
parameters:
  - name: environment
    displayName: 'Target Environment'
    type: string
    default: 'dev'
    values:
      - dev
      - staging
      - production
  
  - name: runTests
    displayName: 'Run Tests'
    type: boolean
    default: true

stages:
  - stage: Deploy
    displayName: 'Deploy to ${{ parameters.environment }}'
    jobs:
      - job: Deploy
        steps:
          - script: echo Deploying to ${{ parameters.environment }}
  
  - ${{ if eq(parameters.runTests, true) }}:
    - stage: Test
      jobs:
        - job: Test
          steps:
            - script: echo Running tests
```

### Variable Groups

```yaml
variables:
  - group: 'production-vars'
  - group: 'database-credentials'
  - name: 'customVar'
    value: 'customValue'

stages:
  - stage: Deploy
    jobs:
      - job: Deploy
        steps:
          - script: |
              echo $(DATABASE_URL)
              echo $(API_KEY)
```

### Output Variables

```yaml
jobs:
  - job: GenerateVersion
    steps:
      - script: |
          VERSION=$(date +%Y%m%d)-$(Build.BuildId)
          echo "##vso[task.setvariable variable=AppVersion;isOutput=true]$VERSION"
        name: SetVersion
  
  - job: UseVersion
    dependsOn: GenerateVersion
    variables:
      version: $[ dependencies.GenerateVersion.outputs['SetVersion.AppVersion'] ]
    steps:
      - script: echo Version is $(version)
```

## Deployment Strategies

### Canary Deployment

```yaml
- deployment: DeployCanary
  environment: production
  strategy:
    canary:
      increments: [10, 25, 50]
      deploy:
        steps:
          - script: kubectl set image deployment/app app=myapp:$(tag) --namespace=prod
      
      routeTraffic:
        steps:
          - script: kubectl patch svc app -p '{"spec":{"selector":{"version":"canary"}}}'
      
      postRouteTraffic:
        steps:
          - script: sleep 300
          - script: ./monitor-metrics.sh
```

### Blue-Green Deployment

```yaml
- deployment: DeployBlueGreen
  environment: production
  strategy:
    runOnce:
      preDeploy:
        steps:
          - script: kubectl apply -f k8s/green-deployment.yml
      
      deploy:
        steps:
          - script: kubectl wait --for=condition=available deployment/app-green
      
      routeTraffic:
        steps:
          - script: kubectl patch svc app -p '{"spec":{"selector":{"version":"green"}}}'
      
      postRouteTraffic:
        steps:
          - script: sleep 60
          - script: kubectl delete deployment app-blue
```

### Rolling Deployment

```yaml
- deployment: DeployRolling
  environment: production
  strategy:
    rolling:
      maxParallel: 2
      preDeploy:
        steps:
          - script: echo Pre-deployment checks
      
      deploy:
        steps:
          - script: kubectl set image deployment/app app=myapp:$(tag)
      
      postDeploy:
        steps:
          - script: echo Post-deployment verification
```

## Caching

### Dependency Caching

**npm:**
```yaml
- task: Cache@2
  displayName: 'Cache npm packages'
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    path: '$(Pipeline.Workspace)/.npm'
    restoreKeys: |
      npm | "$(Agent.OS)"
      npm
```

**Maven:**
```yaml
- task: Cache@2
  displayName: 'Cache Maven packages'
  inputs:
    key: 'maven | "$(Agent.OS)" | **/pom.xml'
    path: '$(Pipeline.Workspace)/.m2/repository'
    restoreKeys: |
      maven | "$(Agent.OS)"
      maven
```

**Go:**
```yaml
- task: Cache@2
  displayName: 'Cache Go modules'
  inputs:
    key: 'go | "$(Agent.OS)" | go.sum'
    path: '$(Pipeline.Workspace)/go/pkg/mod'
    restoreKeys: |
      go | "$(Agent.OS)"
```

### Docker Layer Caching

```yaml
- task: Docker@2
  displayName: 'Build with cache'
  inputs:
    command: build
    dockerfile: '**/Dockerfile'
    arguments: |
      --cache-from $(containerRegistry)/$(imageRepository):latest
      --build-arg BUILDKIT_INLINE_CACHE=1
    tags: |
      $(tag)
      latest
```

## Service Connections

### Azure Resource Manager

```yaml
- task: AzureCLI@2
  displayName: 'Azure CLI Task'
  inputs:
    azureSubscription: 'MyAzureSubscription'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az group create --name myResourceGroup --location eastus
      az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

### Kubernetes

```yaml
- task: Kubernetes@1
  displayName: 'kubectl apply'
  inputs:
    connectionType: 'Kubernetes Service Connection'
    kubernetesServiceEndpoint: 'k8s-production'
    namespace: 'default'
    command: 'apply'
    arguments: '-f k8s/deployment.yml'
```

### Docker Registry

```yaml
- task: Docker@2
  displayName: 'Login to Docker Hub'
  inputs:
    command: login
    containerRegistry: 'dockerHubConnection'

- task: Docker@2
  displayName: 'Push to Docker Hub'
  inputs:
    command: push
    repository: 'myorg/myapp'
    containerRegistry: 'dockerHubConnection'
    tags: $(tag)
```

## Environments and Approvals

### Create Environment with Approvals

1. Go to **Pipelines** → **Environments**
2. Click **New environment**
3. Name: "production"
4. Click **Approvals and checks**
5. Add approvers

### Manual Approval Gates

```yaml
- deployment: DeployProduction
  environment: production
  strategy:
    runOnce:
      deploy:
        steps:
          - script: echo Deploying to production
```

### Branch Control

Configure in Environment → **Approvals and checks** → **Branch control**
- Allowed branches: `main`, `release/*`

## Security Best Practices

### Secure Secrets with Azure Key Vault

```yaml
- task: AzureKeyVault@2
  displayName: 'Fetch secrets from Key Vault'
  inputs:
    azureSubscription: 'MyAzureSubscription'
    KeyVaultName: 'my-keyvault'
    SecretsFilter: 'DATABASE-URL,API-KEY'
    RunAsPreJob: true

- script: |
    echo Using database: $(DATABASE-URL)
  displayName: 'Use secrets'
```

### Conditional Secrets

```yaml
- script: |
    echo $(PROD_SECRET)
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
  env:
    PROD_SECRET: $(PROD_SECRET)
```

### Scan for Secrets

```yaml
- script: |
    git ls-files | xargs grep -i "password\|secret\|token\|api.key" || true
  displayName: 'Scan for hardcoded secrets'
  continueOnError: true
```

## Performance Optimization

### Parallel Jobs

```yaml
jobs:
  - job: Test
    strategy:
      parallel: 4
    steps:
      - script: npm test -- --shard=$(System.JobPositionInPhase)/$(System.TotalJobsInPhase)
```

### Matrix Strategy

```yaml
jobs:
  - job: Test
    strategy:
      matrix:
        Node16:
          nodeVersion: '16.x'
        Node18:
          nodeVersion: '18.x'
        Node20:
          nodeVersion: '20.x'
    steps:
      - task: NodeTool@0
        inputs:
          versionSpec: $(nodeVersion)
      - script: npm test
```

### Skip Redundant Builds

```yaml
trigger:
  paths:
    exclude:
      - docs/*
      - '*.md'

pr:
  paths:
    exclude:
      - docs/*
```

## Debugging

### Enable Debug Logging

```yaml
variables:
  System.Debug: true
```

### Diagnostic Tasks

```yaml
- script: |
    echo "Agent.OS: $(Agent.OS)"
    echo "Build.SourceBranch: $(Build.SourceBranch)"
    echo "Build.BuildId: $(Build.BuildId)"
    env | sort
  displayName: 'Debug: Print environment'
```

## Best Practices

1. **Use Templates** for reusability
2. **Cache Dependencies** to speed up builds
3. **Secure Secrets** with Key Vault
4. **Add Approvals** for production deployments
5. **Use Specific Versions** for tasks and images
6. **Fail Fast** with validation stages
7. **Monitor Pipeline Performance** and optimize
8. **Use Service Connections** for external services
9. **Implement Proper Error Handling**
10. **Document Complex Logic**

## Resources

- [Azure Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [YAML Schema Reference](https://docs.microsoft.com/azure/devops/pipelines/yaml-schema)
- [Task Reference](https://docs.microsoft.com/azure/devops/pipelines/tasks/)
- [Predefined Variables](https://docs.microsoft.com/azure/devops/pipelines/build/variables)
