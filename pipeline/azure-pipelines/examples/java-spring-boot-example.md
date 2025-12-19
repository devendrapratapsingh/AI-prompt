# Java Spring Boot CI/CD Pipeline - Azure Pipelines Example

## Overview
Complete CI/CD pipeline for Spring Boot application using Azure Pipelines with PostgreSQL, Maven, Docker, and Azure Kubernetes Service.

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
  - name: mavenVersion
    value: '3.9.x'
  - name: jdkVersion
    value: '17'
  - name: vmImageName
    value: 'ubuntu-latest'
  - name: dockerRegistryServiceConnection
    value: 'myACRConnection'
  - name: imageRepository
    value: 'springboot-app'
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
        displayName: 'Maven Build'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: Maven@3
            displayName: 'Maven Install'
            inputs:
              mavenVersionOption: 'Default'
              mavenPomFile: 'pom.xml'
              javaHomeOption: 'JDKVersion'
              jdkVersionOption: '1.$(jdkVersion)'
              mavenOptions: '-Xmx3072m'
              publishJUnitResults: false
              goals: 'clean install -DskipTests'
          
          - task: PublishBuildArtifacts@1
            displayName: 'Publish artifacts'
            inputs:
              PathtoPublish: 'target'
              ArtifactName: 'target'

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
          - task: Maven@3
            displayName: 'Run unit tests'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'test'
              publishJUnitResults: true
              testResultsFiles: '**/surefire-reports/TEST-*.xml'
              javaHomeOption: 'JDKVersion'
              jdkVersionOption: '1.$(jdkVersion)'
            env:
              SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/testdb
              SPRING_DATASOURCE_USERNAME: postgres
              SPRING_DATASOURCE_PASSWORD: postgres
          
          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'JaCoCo'
              summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/target/site/jacoco/jacoco.xml'
              reportDirectory: '$(System.DefaultWorkingDirectory)/**/target/site/jacoco'

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
          - task: Maven@3
            displayName: 'Run integration tests'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'verify -Pintegration-tests'
              publishJUnitResults: true
              javaHomeOption: 'JDKVersion'
              jdkVersionOption: '1.$(jdkVersion)'
            env:
              SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/testdb

  - stage: Quality
    displayName: 'Code Quality'
    dependsOn: Build
    jobs:
      - job: SonarQube
        displayName: 'SonarQube Analysis'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: SonarQubePrepare@5
            inputs:
              SonarQube: 'SonarQube'
              scannerMode: 'Other'
          
          - task: Maven@3
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'clean verify sonar:sonar'
              javaHomeOption: 'JDKVersion'
              jdkVersionOption: '1.$(jdkVersion)'
          
          - task: SonarQubePublish@5
            inputs:
              pollingTimeoutSec: '300'

  - stage: Security
    displayName: 'Security Scanning'
    dependsOn: Build
    jobs:
      - job: SecurityScan
        displayName: 'Dependency Check'
        pool:
          vmImage: $(vmImageName)
        
        steps:
          - task: Maven@3
            displayName: 'OWASP Dependency Check'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'org.owasp:dependency-check-maven:check'
              javaHomeOption: 'JDKVersion'
              jdkVersionOption: '1.$(jdkVersion)'
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

  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Package
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployStaging
        displayName: 'Deploy to Staging'
        environment: 'springboot-staging'
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
                    namespace: 'springboot-staging'
                    command: 'apply'
                    arguments: '-f k8s/staging/'

  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProduction
        displayName: 'Deploy to Production'
        environment: 'springboot-production'
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
                    namespace: 'springboot-prod'
                    command: 'apply'
                    arguments: '-f k8s/production/'
```

## Dockerfile

```dockerfile
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

COPY --from=build --chown=appuser:appuser /app/target/*.jar app.jar

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

## pom.xml (Dependencies)

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Key Features

1. **Maven Multi-Stage Build**: Compile, Test, Package
2. **Azure Integration**: ACR, AKS deployment
3. **Testing**: Unit and Integration tests with JaCoCo coverage
4. **Code Quality**: SonarQube analysis
5. **Security**: OWASP Dependency Check
6. **Multi-Environment**: Staging and Production

## Running Locally

```bash
mvn clean install
mvn test
mvn spring-boot:run
```
