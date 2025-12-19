#!/bin/bash

# Azure Pipelines Setup Script
# This script helps configure Azure Pipelines for your project

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

echo -e "${BLUE}"
cat << "EOF"
     _                         ____  _            _ _                 
    / \    _____   _ _ __ ___ |  _ \(_)_ __   ___| (_)_ __   ___  ___ 
   / _ \  |_  / | | | '__/ _ \| |_) | | '_ \ / _ \ | | '_ \ / _ \/ __|
  / ___ \  / /| |_| | | |  __/|  __/| | |_) |  __/ | | | | |  __/\__ \
 /_/   \_\/___|\__,_|_|  \___||_|   |_| .__/ \___|_|_|_| |_|\___||___/
                                       |_|                              
  Setup Script v1.0
EOF
echo -e "${NC}"

check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v git &> /dev/null; then
        log_error "git is not installed"
        exit 1
    fi
    log_success "git is installed"
    
    if ! command -v az &> /dev/null; then
        log_warn "Azure CLI not installed (recommended for advanced features)"
        log_info "Install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    else
        log_success "Azure CLI is installed"
        az --version | head -1
    fi
}

detect_project_type() {
    if [ -f "package.json" ]; then
        echo "nodejs"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ]; then
        echo "java-maven"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java-gradle"
    elif [[ -f *.csproj ]] || [[ -f *.sln ]]; then
        echo "dotnet"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "composer.json" ]; then
        echo "php"
    else
        echo "unknown"
    fi
}

create_nodejs_pipeline() {
    cat > azure-pipelines.yml << 'EOF'
trigger:
  - main
  - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  nodeVersion: '18.x'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
            displayName: 'Install Node.js'
          
          - script: |
              npm ci
              npm run build
            displayName: 'Install and build'
          
          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: 'dist'
              ArtifactName: 'dist'

  - stage: Test
    dependsOn: Build
    jobs:
      - job: Test
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
          
          - script: npm ci
            displayName: 'Install dependencies'
          
          - script: npm test
            displayName: 'Run tests'
          
          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/junit.xml'

  - stage: Deploy
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - job: Deploy
        steps:
          - script: echo "Add deployment commands here"
            displayName: 'Deploy'
EOF
    log_success "Created Node.js pipeline"
}

create_python_pipeline() {
    cat > azure-pipelines.yml << 'EOF'
trigger:
  - main
  - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  pythonVersion: '3.11'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: $(pythonVersion)
            displayName: 'Use Python $(pythonVersion)'
          
          - script: |
              python -m pip install --upgrade pip
              pip install -r requirements.txt
            displayName: 'Install dependencies'

  - stage: Test
    dependsOn: Build
    jobs:
      - job: Test
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: $(pythonVersion)
          
          - script: |
              pip install -r requirements.txt
              pip install pytest pytest-cov
              pytest tests/ --cov=app --cov-report=xml
            displayName: 'Run tests'
          
          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/test-results.xml'
          
          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/coverage.xml'

  - stage: Deploy
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - job: Deploy
        steps:
          - script: echo "Add deployment commands here"
            displayName: 'Deploy'
EOF
    log_success "Created Python pipeline"
}

create_dotnet_pipeline() {
    cat > azure-pipelines.yml << 'EOF'
trigger:
  - main
  - develop

pool:
  vmImage: 'windows-latest'

variables:
  buildConfiguration: 'Release'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - task: DotNetCoreCLI@2
            inputs:
              command: 'restore'
            displayName: 'Restore dependencies'
          
          - task: DotNetCoreCLI@2
            inputs:
              command: 'build'
              arguments: '--configuration $(buildConfiguration)'
            displayName: 'Build'

  - stage: Test
    dependsOn: Build
    jobs:
      - job: Test
        steps:
          - task: DotNetCoreCLI@2
            inputs:
              command: 'test'
              arguments: '--configuration $(buildConfiguration) --collect:"XPlat Code Coverage"'
            displayName: 'Run tests'
          
          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFormat: 'VSTest'
              testResultsFiles: '**/*.trx'

  - stage: Deploy
    dependsOn: Test
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - job: Deploy
        steps:
          - script: echo "Add deployment commands here"
            displayName: 'Deploy'
EOF
    log_success "Created .NET pipeline"
}

create_generic_pipeline() {
    cat > azure-pipelines.yml << 'EOF'
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - script: echo "Add build commands here"
            displayName: 'Build'

  - stage: Test
    dependsOn: Build
    jobs:
      - job: Test
        steps:
          - script: echo "Add test commands here"
            displayName: 'Test'

  - stage: Deploy
    dependsOn: Test
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    jobs:
      - job: Deploy
        steps:
          - script: echo "Add deployment commands here"
            displayName: 'Deploy'
EOF
    log_success "Created generic pipeline"
}

main() {
    echo
    log_info "Starting Azure Pipelines setup..."
    echo
    
    check_requirements
    echo
    
    PROJECT_TYPE=$(detect_project_type)
    log_info "Detected project type: $PROJECT_TYPE"
    echo
    
    if [ -f "azure-pipelines.yml" ]; then
        log_warn "azure-pipelines.yml already exists"
        read -p "Overwrite? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping pipeline creation"
            exit 0
        fi
    fi
    
    case $PROJECT_TYPE in
        nodejs) create_nodejs_pipeline ;;
        python) create_python_pipeline ;;
        dotnet) create_dotnet_pipeline ;;
        *) create_generic_pipeline ;;
    esac
    
    echo
    log_success "Azure Pipelines setup complete!"
    echo
    log_info "Next steps:"
    echo "  1. Review and customize azure-pipelines.yml"
    echo "  2. Create Azure DevOps project at https://dev.azure.com"
    echo "  3. Connect your repository"
    echo "  4. Create new pipeline using existing YAML file"
    echo "  5. Configure service connections and variables"
    echo
    log_info "Documentation: https://docs.microsoft.com/azure/devops/pipelines/"
}

main
