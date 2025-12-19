# Azure Pipelines - Complete Enterprise-Grade CI/CD Guide

## Overview

Azure Pipelines is Microsoft's cloud-native CI/CD service built into Azure DevOps, providing unlimited free CI/CD for open-source projects and enterprise-grade features for private repositories. It integrates seamlessly with Azure services, GitHub, Bitbucket, and self-managed repositories.

### Key Capabilities
- **Multi-Platform Support**: Linux, macOS, Windows, containers, Kubernetes
- **Flexible Configuration**: YAML-based or visual editor
- **Integration with Azure**: Tight integration with Azure services, deployment targets
- **Enterprise Features**: Multi-stage pipelines, approval gates, environment management
- **Container Native**: Docker, ACR, Kubernetes deployment
- **Scalable Agents**: Microsoft-hosted agents, self-hosted agents
- **Artifact Management**: Pipeline artifacts, package feeds, deployment groups
- **Security**: Service connections, variable groups, secret management
- **Advanced Workflows**: Multi-repo pipelines, templates, extends

## Prerequisites

- Azure DevOps account (free tier available)
- GitHub, Azure Repos, Bitbucket, or other Git repository
- Basic YAML knowledge
- Azure subscription (optional, for cloud deployment)
- For self-hosted agents: Windows, Linux, or macOS machine

## System Requirements

### Microsoft-Hosted Agents
- **Available pools**: Windows, Linux, macOS
- **Windows**: Hosted agents with VS 2022, 2019
- **Linux**: Ubuntu 22.04, 20.04, 18.04
- **macOS**: Hosted agents with Xcode
- **Memory**: Varies by agent type (2-7 GB)
- **Storage**: 10 GB per agent

### Self-Hosted Agents
- **Minimum**: 2 GB RAM, 2 CPU cores
- **Recommended**: 4+ GB RAM, 4+ cores for production
- **OS**: Windows, Linux (Ubuntu 20.04+, CentOS), macOS
- **Network**: Outbound HTTPS access to Azure DevOps
- **Storage**: 20+ GB for artifacts and build cache

## Installation & Setup

### Step 1: Create Azure DevOps Project

1. Go to [dev.azure.com](https://dev.azure.com)
2. Create new organization or use existing
3. Create new project
4. Select Git repository source

### Step 2: Create Pipeline

1. Go to Pipelines section
2. Click "New Pipeline"
3. Select repository source
4. Choose pipeline template or start with YAML

### Step 3: Create azure-pipelines.yml

```yaml
trigger:
  - main
  - develop

pr:
  - main
  - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  buildPlatform: 'x64'

stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - script: echo Hello, world!
      displayName: 'Run a one-line script'
```

### Step 4: Configure Service Connections

1. Project Settings → Service connections
2. Create connection (Docker Registry, Kubernetes, Azure)
3. Use in pipeline with `endpoint` parameter

## Configuration Walkthrough

### Trigger Rules

```yaml
trigger:
  branches:
    include:
      - main
      - develop
    exclude:
      - docs/*
  paths:
    include:
      - src/*
      - tests/*
    exclude:
      - docs/*
      - README.md

pr:
  - main
  - develop

schedules:
  - cron: "0 2 * * *"
    displayName: Nightly build
    branches:
      include:
        - main
    always: false
```

### Variables and Secrets

```yaml
variables:
  - name: buildConfiguration
    value: 'Release'
  - name: buildPlatform
    value: 'x64'
  
  - group: 'Production Secrets'  # Variable group from library
  
  # Template variables
  - template: variables/common.yml

jobs:
  - job: Build
    variables:
      - name: LOCAL_VAR
        value: 'Local to this job'
```

**Securing Variables:**
1. Pipelines → Library → Variable groups
2. Add variables and mark as "Secret"
3. Reference in pipeline

### Stages and Jobs

```yaml
stages:
  - stage: Build
    displayName: 'Build Stage'
    jobs:
      - job: BuildJob
        displayName: 'Build Application'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: npm ci
          - script: npm run build

  - stage: Test
    dependsOn: Build
    condition: succeeded()
    jobs:
      - job: TestJob
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: npm test

  - stage: Deploy
    dependsOn: Test
    condition: succeeded()
    jobs:
      - deployment: DeployToStaging
        displayName: 'Deploy to Staging'
        environment: 'Staging'
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo Deploying...
```

## CI/CD Pipeline Stages

### Stage 1: Build

```yaml
stages:
  - stage: Build
    displayName: 'Build Stage'
    jobs:
      - job: BuildJob
        displayName: 'Build Application'
        pool:
          vmImage: 'ubuntu-latest'
        
        steps:
          - checkout: self
            fetchDepth: 0
          
          - task: NodeTool@0
            inputs:
              versionSpec: '18.x'
              checkLatest: true
            displayName: 'Set up Node.js'
          
          - task: Cache@2
            inputs:
              key: 'npm | "$(Agent.OS)" | package-lock.json'
              restoreKeys: npm | "$(Agent.OS)"
              path: $(npm_config_cache)
            displayName: 'Cache npm packages'
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: npm run build
            displayName: 'Build application'
          
          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)'
              ArtifactName: 'drop'
              publishLocation: 'Container'
```

### Stage 2: Test

```yaml
  - stage: Test
    displayName: 'Test Stage'
    dependsOn: Build
    condition: succeeded()
    
    jobs:
      - job: UnitTest
        displayName: 'Unit Tests'
        pool:
          vmImage: 'ubuntu-latest'
        
        steps:
          - checkout: self
          
          - task: NodeTool@0
            inputs:
              versionSpec: '18.x'
          
          - script: npm ci
          
          - script: npm run test:unit -- --coverage
            displayName: 'Run unit tests'
          
          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: Cobertura
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/coverage/cobertura-coverage.xml'
          
          - task: PublishTestResults@2
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/test-results.xml'

      - job: IntegrationTest
        displayName: 'Integration Tests'
        pool:
          vmImage: 'ubuntu-latest'
        
        steps:
          - checkout: self
          
          - task: NodeTool@0
            inputs:
              versionSpec: '18.x'
          
          - task: DockerCompose@0
            inputs:
              action: 'Run services'
              dockerComposeFile: 'docker-compose.test.yml'
          
          - script: npm run test:integration
            displayName: 'Run integration tests'
```

### Stage 3: Code Quality

```yaml
  - stage: Quality
    displayName: 'Code Quality'
    dependsOn: Build
    condition: succeeded()
    
    jobs:
      - job: CodeQuality
        displayName: 'Code Quality Checks'
        pool:
          vmImage: 'ubuntu-latest'
        
        steps:
          - checkout: self
            fetchDepth: 0
          
          - task: NodeTool@0
            inputs:
              versionSpec: '18.x'
          
          - script: npm ci
          
          - script: npm run lint
            displayName: 'Run linter'
          
          - script: npm run format:check
            displayName: 'Check code formatting'
          
          - task: SonarCloudPrepare@1
            inputs:
              SonarCloud: 'SonarCloud'
              organization: '$(SonarOrganization)'
              scannerMode: 'CLI'
              configMode: 'manual'
              cliProjectKey: '$(SonarProjectKey)'
              cliProjectName: '$(Project.DisplayName)'
              cliProjectVersion: '$(Build.BuildNumber)'
              cliSources: 'src'
          
          - script: npm run test:coverage
            displayName: 'Generate coverage'
          
          - task: SonarCloudAnalyze@1
```

### Stage 4: Security

```yaml
  - stage: Security
    displayName: 'Security Scanning'
    dependsOn: Build
    condition: succeeded()
    
    jobs:
      - job: SecurityScan
        displayName: 'Security Analysis'
        pool:
          vmImage: 'ubuntu-latest'
        
        steps:
          - checkout: self
          
          - task: NodeTool@0
            inputs:
              versionSpec: '18.x'
          
          - script: npm audit --audit-level=moderate
            displayName: 'Audit dependencies'
            continueOnError: true
          
          - task: CredScan@3
            inputs:
              scanFolder: '$(Build.SourcesDirectory)'
              outputFormat: 'sarif'
          
          - script: |
              npm install -g snyk
              snyk auth $(SNYK_TOKEN)
              snyk test || true
            displayName: 'Run Snyk vulnerability scan'
            continueOnError: true
          
          - task: PublishSecurityAnalysisLogs@3
            inputs:
              ArtifactType: 'CodeAnalysisLogs'
```

### Stage 5: Deploy

```yaml
  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
    
    jobs:
      - deployment: DeployToStaging
        displayName: 'Deploy to Staging Environment'
        environment:
          name: 'Staging'
          resourceType: 'VirtualMachine'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: 'drop'
                
                - task: AzureCLI@2
                  inputs:
                    azureSubscription: 'Azure Connection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      az webapp up \
                        --name staging-app \
                        --resource-group myResourceGroup \
                        --runtime "NODE|18" \
                        --plan myAppServicePlan

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    
    jobs:
      - deployment: DeployToProduction
        displayName: 'Deploy to Production'
        environment:
          name: 'Production'
          resourceType: 'VirtualMachine'
        strategy:
          runOnce:
            preDeployment:
              steps:
                - script: echo "Pre-deployment validation"
            
            deploy:
              steps:
                - download: current
                  artifact: 'drop'
                
                - task: AzureCLI@2
                  inputs:
                    azureSubscription: 'Azure Production'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      # Backup current deployment
                      az webapp snapshot create \
                        --name prod-app \
                        --resource-group myResourceGroup
                      
                      # Deploy new version
                      az webapp up \
                        --name prod-app \
                        --resource-group myResourceGroup \
                        --runtime "NODE|18"
            
            postDeployment:
              steps:
                - script: echo "Post-deployment health checks"
```

## Tool Integrations

### Docker Integration

```yaml
steps:
  - task: Docker@2
    displayName: 'Build Docker image'
    inputs:
      command: 'build'
      Dockerfile: 'Dockerfile'
      tags: |
        $(Build.Repository.Name):$(Build.BuildId)
        $(Build.Repository.Name):latest

  - task: Docker@2
    displayName: 'Push Docker image'
    inputs:
      command: 'push'
      containerRegistry: 'DockerRegistry'
```

### Kubernetes Deployment

```yaml
  - task: KubernetesManifest@0
    displayName: 'Deploy to Kubernetes'
    inputs:
      action: 'deploy'
      kubernetesServiceConnection: 'K8sConnection'
      namespace: 'production'
      manifests: |
        $(Pipeline.Workspace)/deployment.yaml
        $(Pipeline.Workspace)/service.yaml
      containers: |
        $(containerRegistry)/$(imageRepository):$(Build.BuildId)
```

## Advanced Features

### Templates

```yaml
# template.yml
parameters:
  - name: 'environment'
    type: string
  - name: 'vmImage'
    type: string
    default: 'ubuntu-latest'

jobs:
  - job: Deploy
    displayName: 'Deploy to ${{ parameters.environment }}'
    pool:
      vmImage: ${{ parameters.vmImage }}
    steps:
      - script: echo Deploying to ${{ parameters.environment }}
```

Usage:
```yaml
stages:
  - stage: Deploy
    jobs:
      - template: template.yml
        parameters:
          environment: 'Staging'
```

### Multi-Stage Deployments

```yaml
stages:
  - stage: Build
  - stage: Test
  - stage: Staging
    dependsOn: Test
  - stage: Production
    dependsOn: Staging
    condition: succeeded()
```

## Enterprise Features

### Approval Gates

1. Environments section
2. Select environment
3. Add approval checks
4. Require approvers

### Reporting and Analytics

- Pipeline success rate
- Build duration trends
- Test pass rates
- Deployment frequency
- Lead time metrics

## Performance Tuning

### Caching

```yaml
  - task: Cache@2
    inputs:
      key: 'npm | "$(Agent.OS)" | package-lock.json'
      restoreKeys: npm | "$(Agent.OS)"
      path: $(npm_config_cache)
```

### Parallel Jobs

```yaml
jobs:
  - job: Job1
  - job: Job2
  - job: Job3
```

## Troubleshooting

### Agent Connection Issues

```bash
# Check agent status
az pipelines agent list --organization https://dev.azure.com/myorg

# Restart agent
sudo systemctl restart vsts.agent.myorg.agent
```

### Build Failures

1. Check logs in Pipeline UI
2. Review job summary
3. Check for timeout issues
4. Verify service connections

## FAQ

**Q: How do I use different agents for different jobs?**
A: Use pool specification with demands or vmImage

**Q: Can I run parallel stages?**
A: Stages run sequentially by default, use jobs for parallelism

**Q: How do I store secrets securely?**
A: Use Variable Groups and mark as secrets

**Q: What's the artifact retention policy?**
A: Default 30 days, configurable in pipeline settings

## Resources

- [Azure Pipelines Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [YAML Schema Reference](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Task Reference](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/)
- [Azure DevOps REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops/)
