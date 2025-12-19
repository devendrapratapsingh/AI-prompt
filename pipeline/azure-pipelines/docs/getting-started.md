# Azure Pipelines - Getting Started Guide

## Quick Start (5-10 minutes)

### Step 1: Create Azure DevOps Account (2 min)

1. Go to [dev.azure.com](https://dev.azure.com)
2. Sign in with Microsoft account
3. Create new organization
4. Create new project

### Step 2: Create Your First Pipeline (3 min)

1. In your project, go to **Pipelines** → **Create Pipeline**
2. Select your repository source (GitHub, Azure Repos, etc.)
3. Choose "Starter pipeline" template
4. Review the basic `azure-pipelines.yml`:

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - script: echo Hello, world!
    displayName: 'Run a one-line script'
```

5. Click **Save and run**
6. View your pipeline execution in real-time

### Step 3: Add Build Steps (2 min)

Update your pipeline for your language:

**For Node.js:**
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '18.x'
    displayName: 'Install Node.js'

  - script: |
      npm ci
      npm run build
      npm test
    displayName: 'npm install, build and test'
```

**For Python:**
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.11'
    displayName: 'Use Python 3.11'

  - script: |
      python -m pip install --upgrade pip
      pip install -r requirements.txt
      pytest
    displayName: 'Install dependencies and run tests'
```

**For .NET:**
```yaml
trigger:
  - main

pool:
  vmImage: 'windows-latest'

steps:
  - task: DotNetCoreCLI@2
    inputs:
      command: 'restore'
    displayName: 'Restore dependencies'

  - task: DotNetCoreCLI@2
    inputs:
      command: 'build'
      arguments: '--configuration Release'
    displayName: 'Build project'

  - task: DotNetCoreCLI@2
    inputs:
      command: 'test'
    displayName: 'Run tests'
```

**For Java (Maven):**
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: Maven@3
    inputs:
      mavenPomFile: 'pom.xml'
      goals: 'clean package'
      publishJUnitResults: true
      testResultsFiles: '**/surefire-reports/TEST-*.xml'
    displayName: 'Maven build and test'
```

### Step 4: Add Multi-Stage Pipeline (3 min)

```yaml
trigger:
  - main

stages:
  - stage: Build
    displayName: 'Build stage'
    jobs:
      - job: Build
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: echo Building...
            displayName: 'Build application'

  - stage: Test
    displayName: 'Test stage'
    dependsOn: Build
    jobs:
      - job: Test
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: echo Testing...
            displayName: 'Run tests'

  - stage: Deploy
    displayName: 'Deploy stage'
    dependsOn: Test
    jobs:
      - job: Deploy
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: echo Deploying...
            displayName: 'Deploy application'
```

## Core Concepts

### Pipeline Structure

```yaml
# Triggers - when to run
trigger:
  - main
  - develop

# PR triggers
pr:
  - main

# Agent pool
pool:
  vmImage: 'ubuntu-latest'

# Variables
variables:
  buildConfiguration: 'Release'

# Stages > Jobs > Steps
stages:
  - stage: StageName
    jobs:
      - job: JobName
        steps:
          - task: TaskName@Version
          - script: command
```

### Agent Pools

**Microsoft-hosted agents:**
- `ubuntu-latest`, `ubuntu-22.04`, `ubuntu-20.04`
- `windows-latest`, `windows-2022`, `windows-2019`
- `macOS-latest`, `macOS-12`, `macOS-11`

**Self-hosted agents:**
```yaml
pool:
  name: 'MyAgentPool'
```

### Variables

**Pipeline variables:**
```yaml
variables:
  buildConfiguration: 'Release'
  vmImageName: 'ubuntu-latest'
```

**Variable groups:**
```yaml
variables:
  - group: 'production-vars'
  - name: 'customVar'
    value: 'customValue'
```

**Predefined variables:**
- `$(Build.BuildId)` - Unique build number
- `$(Build.SourceBranch)` - Source branch
- `$(Build.Repository.Name)` - Repository name
- `$(System.DefaultWorkingDirectory)` - Working directory

### Tasks

**Common tasks:**

```yaml
# Node.js
- task: NodeTool@0
  inputs:
    versionSpec: '18.x'

# Python
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.11'

# Docker
- task: Docker@2
  inputs:
    command: 'build'
    repository: 'myapp'
    dockerfile: 'Dockerfile'

# Kubernetes
- task: Kubernetes@1
  inputs:
    command: 'apply'
    arguments: '-f k8s/deployment.yml'
```

## Service Connections

### Create Service Connection

1. Go to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Select type:
   - Azure Resource Manager
   - Docker Registry
   - Kubernetes
   - GitHub
   - npm
4. Follow setup wizard

### Use in Pipeline

```yaml
- task: Docker@2
  inputs:
    containerRegistry: 'myDockerRegistry'
    repository: 'myapp'
    command: 'push'
```

## Artifacts

### Publish Artifacts

```yaml
- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: 'dist'
    ArtifactName: 'drop'
    publishLocation: 'Container'
```

### Download Artifacts

```yaml
- task: DownloadBuildArtifacts@1
  inputs:
    buildType: 'current'
    downloadType: 'single'
    artifactName: 'drop'
    downloadPath: '$(System.ArtifactsDirectory)'
```

## Testing

### Publish Test Results

```yaml
- script: npm test
  displayName: 'Run tests'

- task: PublishTestResults@2
  condition: succeededOrFailed()
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test-results.xml'
    failTaskOnFailedTests: true
```

### Code Coverage

```yaml
- task: PublishCodeCoverageResults@1
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/coverage.xml'
    reportDirectory: '$(System.DefaultWorkingDirectory)/**/htmlcov'
```

## Environments

### Create Environment

1. Go to **Pipelines** → **Environments**
2. Click **New environment**
3. Name it (e.g., "production")
4. Add approvals and checks

### Use in Pipeline

```yaml
- stage: Deploy
  jobs:
    - deployment: DeployProd
      environment: 'production'
      strategy:
        runOnce:
          deploy:
            steps:
              - script: echo Deploying...
```

## Conditions

### Job Conditions

```yaml
- job: DeployProd
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

### Step Conditions

```yaml
- script: npm run deploy
  condition: and(succeeded(), eq(variables['Build.Reason'], 'Manual'))
```

### Common Conditions

```yaml
condition: succeeded()           # Previous step succeeded
condition: failed()              # Previous step failed
condition: always()              # Always run
condition: succeededOrFailed()   # Run regardless
```

## Security & Secrets

### Variable Groups

1. Go to **Pipelines** → **Library**
2. Click **+ Variable group**
3. Add secrets
4. Mark as secret (lock icon)

### Azure Key Vault

```yaml
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'MySubscription'
    KeyVaultName: 'my-keyvault'
    SecretsFilter: '*'
```

### Use Secrets

```yaml
- script: |
    echo "Using secret..."
  env:
    API_KEY: $(MY_SECRET)
```

## Caching

### Cache Dependencies

```yaml
- task: Cache@2
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    path: '$(Pipeline.Workspace)/.npm'
    restoreKeys: |
      npm | "$(Agent.OS)"
  displayName: 'Cache npm packages'
```

## Templates

### Create Template

**templates/build.yml:**
```yaml
parameters:
  - name: nodeVersion
    default: '18.x'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}
  
  - script: npm ci
  - script: npm run build
```

### Use Template

```yaml
jobs:
  - job: Build
    steps:
      - template: templates/build.yml
        parameters:
          nodeVersion: '20.x'
```

## Troubleshooting

### Common Issues

**Pipeline not triggering:**
- Check trigger configuration
- Verify branch names match
- Check path filters

**Task failing:**
- Review task logs in detail
- Check task version
- Verify inputs are correct

**Artifacts not found:**
- Check artifact name matches
- Verify publish task succeeded
- Check artifact retention policy

### Debug Mode

Enable debug logging:
1. Edit pipeline
2. Add variable: `System.Debug = true`
3. Save and run

Or add in pipeline:
```yaml
variables:
  System.Debug: true
```

## Best Practices

### 1. Use Semantic Versioning for Tasks
```yaml
# Good
- task: NodeTool@0

# Bad
- task: NodeTool@*
```

### 2. Fail Fast
```yaml
stages:
  - stage: Validate
    jobs:
      - job: Lint
        steps:
          - script: npm run lint
```

### 3. Use Templates for Reusability
```yaml
- template: templates/test.yml
```

### 4. Separate Secrets
```yaml
variables:
  - group: 'production-secrets'
```

### 5. Add Approvals for Production
Configure in Environment settings

### 6. Cache Dependencies
Use Cache task for faster builds

### 7. Use Conditions Wisely
```yaml
condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

## Next Steps

1. **Explore examples**: Check `examples/` directory
2. **Read advanced docs**: See `docs/advanced-configuration.md`
3. **Set up environments**: Configure approvals
4. **Add service connections**: Connect to external services
5. **Configure branch policies**: Require pipeline success

## Quick Reference

### Useful Links
- [Azure Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [YAML Schema Reference](https://docs.microsoft.com/azure/devops/pipelines/yaml-schema)
- [Task Reference](https://docs.microsoft.com/azure/devops/pipelines/tasks/)
- [Predefined Variables](https://docs.microsoft.com/azure/devops/pipelines/build/variables)

### CLI Commands

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Create pipeline
az pipelines create --name MyPipeline --repository MyRepo --branch main

# Run pipeline
az pipelines run --name MyPipeline

# Show pipeline runs
az pipelines runs list --pipeline-ids <pipeline-id>
```
