# Go Application CI/CD Pipeline - Azure Pipelines Example

## Overview
Complete CI/CD pipeline for a Go microservice using Azure Pipelines with PostgreSQL, Docker, and Azure Kubernetes Service.

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
  - name: goVersion
    value: '1.21'
  - name: vmImageName
    value: 'ubuntu-latest'
  - name: dockerRegistryServiceConnection
    value: 'myACRConnection'
  - name: imageRepository
    value: 'go-app'
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
        displayName: 'Build Go Application'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: GoTool@0
            displayName: 'Install Go'
            inputs:
              version: '$(goVersion)'
          
          - script: |
              go version
              go mod download
              go mod verify
              go build -v ./...
            displayName: 'Go build'
            workingDirectory: '$(System.DefaultWorkingDirectory)'
          
          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)'
              ArtifactName: 'go-binary'

  - stage: Test
    displayName: 'Test Stage'
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
            ports:
              - 5432:5432
        
        steps:
          - task: GoTool@0
            inputs:
              version: '$(goVersion)'
          
          - script: |
              go mod download
              go test -v -race -coverprofile=coverage.out -covermode=atomic ./...
              go tool cover -func=coverage.out
              go tool cover -html=coverage.out -o coverage.html
            displayName: 'Run tests with coverage'
            env:
              DATABASE_URL: postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable
          
          - task: PublishTestResults@2
            condition: succeededOrFailed()
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: '**/test-results.xml'
          
          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/coverage.xml'
              reportDirectory: '$(System.DefaultWorkingDirectory)/**/coverage'

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
        
        steps:
          - task: GoTool@0
            inputs:
              version: '$(goVersion)'
          
          - script: |
              go mod download
              go test -v -tags=integration ./tests/integration/...
            displayName: 'Run integration tests'
            env:
              DATABASE_URL: postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable

  - stage: Quality
    displayName: 'Code Quality'
    dependsOn: Build
    jobs:
      - job: Lint
        displayName: 'Linting'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: GoTool@0
            inputs:
              version: '$(goVersion)'
          
          - script: |
              go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
              golangci-lint run --out-format=json > golangci-lint-report.json || true
              golangci-lint run
            displayName: 'golangci-lint'
            continueOnError: true
          
          - script: |
              gofmt -l . | tee gofmt-report.txt
              test -z "$(gofmt -l .)"
            displayName: 'gofmt check'
            continueOnError: true
          
          - script: go vet ./...
            displayName: 'go vet'
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
          - task: GoTool@0
            inputs:
              version: '$(goVersion)'
          
          - script: |
              go install github.com/securego/gosec/v2/cmd/gosec@latest
              gosec -fmt=json -out=gosec-report.json ./... || true
              gosec ./...
            displayName: 'gosec security scan'
            continueOnError: true
          
          - script: |
              go install golang.org/x/vuln/cmd/govulncheck@latest
              govulncheck ./...
            displayName: 'govulncheck'
            continueOnError: true

  - stage: Package
    displayName: 'Build Docker Image'
    dependsOn:
      - Test
      - Quality
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

  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Package
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployStaging
        displayName: 'Deploy to Staging'
        environment: 'go-app-staging'
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
                    namespace: 'go-app-staging'
                    command: 'apply'
                    arguments: '-f k8s/staging/'

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProduction
        displayName: 'Deploy to Production'
        environment: 'go-app-production'
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
                    namespace: 'go-app-prod'
                    command: 'apply'
                    arguments: '-f k8s/production/'
```

## Dockerfile

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api

FROM alpine:latest

WORKDIR /root/

RUN apk --no-cache add ca-certificates

RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

COPY --from=builder --chown=appuser:appuser /app/main .

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["./main"]
```

## Key Features

1. **Go Build Pipeline**: Build, test, lint, security scan
2. **Azure Integration**: ACR, AKS deployment
3. **Testing**: Unit and integration tests with race detector
4. **Code Quality**: golangci-lint, gofmt, go vet
5. **Security**: gosec, govulncheck, Trivy
6. **Multi-Environment**: Staging and Production

## Running Locally

```bash
go mod download
go test -v ./...
go build ./...
./main
```
