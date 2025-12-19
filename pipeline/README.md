# CI/CD Pipeline Templates & Configurations

This directory contains comprehensive CI/CD pipeline configurations for all major platforms and tools. Choose the appropriate subdirectory based on your target deployment platform.

## Directory Structure Overview

### **Cloud Provider & Managed Services**

#### [github-actions](./github-actions/)
- **Platform**: GitHub
- **Type**: Hosted CI/CD (free for public repos, paid for private)
- **Use Case**: Native GitHub integration, workflow automation
- **File Format**: YAML (.github/workflows/*.yml)
- **Key Features**: Matrix builds, artifacts, secrets management, deployment gates

#### [gitlab-ci](./gitlab-ci/)
- **Platform**: GitLab
- **Type**: Hosted & Self-hosted CI/CD
- **Use Case**: Integrated DevOps, container registry included
- **File Format**: YAML (.gitlab-ci.yml)
- **Key Features**: Runner support, artifacts, cache, protected environments

#### [azure-pipelines](./azure-pipelines/)
- **Platform**: Microsoft Azure (part of Azure DevOps)
- **Type**: Hosted & Self-hosted CI/CD
- **Use Case**: Enterprise, Windows/Linux/Mac builds, integration with Azure services
- **File Format**: YAML (azure-pipelines.yml)
- **Key Features**: Multi-stage pipelines, variable groups, service connections

#### [aws-codepipeline](./aws-codepipeline/)
- **Platform**: Amazon Web Services
- **Type**: Managed service (pay-per-pipeline)
- **Use Case**: AWS-native workflows, integration with CodeBuild/CodeDeploy
- **File Format**: JSON/CloudFormation/Serverless
- **Key Features**: Artifact stores, integration with SNS/Lambda, CloudFormation support

#### [gcp-cloud-build](./gcp-cloud-build/)
- **Platform**: Google Cloud Platform
- **Type**: Managed build service
- **Use Case**: GCP-native builds, container image builds
- **File Format**: YAML (cloudbuild.yaml)
- **Key Features**: Docker builds, artifact registry, integration with GKE/Cloud Run

---

### **Traditional & Enterprise CI/CD Servers**

#### [jenkins](./jenkins/)
- **Type**: Self-hosted, open-source CI/CD server
- **Use Case**: Highly customizable, large enterprise environments
- **File Format**: Groovy (Jenkinsfile), XML (configuration)
- **Key Features**: Declarative & scripted pipelines, 1000+ plugins, distributed builds

#### [teamcity](./teamcity/)
- **Platform**: JetBrains TeamCity
- **Type**: Commercial, self-hosted CI/CD
- **Use Case**: Enterprise Java/Kotlin development
- **File Format**: Kotlin DSL, XML
- **Key Features**: Build chains, artifact dependencies, investigation tools

#### [cloudbees](./cloudbees/)
- **Platform**: CloudBees (Jenkins-based)
- **Type**: Commercial, hosted & self-hosted
- **Use Case**: Enterprise Jenkins with additional features
- **File Format**: Groovy/Declarative Pipeline
- **Key Features**: CloudBees Flow, CasC, advanced analytics

#### [gocd](./gocd/)
- **Platform**: GoCD (ThoughtWorks)
- **Type**: Open-source, self-hosted CI/CD
- **Use Case**: Complex pipelines, dependency management, advanced visualization
- **File Format**: YAML (config-repo), XML
- **Key Features**: Value stream maps, artifact management, fan-in/fan-out

---

### **SaaS CI/CD Platforms**

#### [circleci](./circleci/)
- **Type**: Cloud-based CI/CD
- **Use Case**: Developer-friendly, fast feedback loops
- **File Format**: YAML (.circleci/config.yml)
- **Key Features**: Orbs marketplace, matrix builds, resource classes, Insights

#### [travis-ci](./travis-ci/)
- **Type**: Cloud-based CI/CD
- **Use Case**: GitHub integration, open-source projects
- **File Format**: YAML (.travis.yml)
- **Key Features**: Build matrix, deployment integrations, language support

#### [appveyor](./appveyor/)
- **Type**: Cloud-based CI/CD
- **Use Case**: Windows builds, .NET/PowerShell focus
- **File Format**: YAML (appveyor.yml)
- **Key Features**: Windows/Linux/macOS, matrix builds, artifact upload

#### [bitbucket-pipelines](./bitbucket-pipelines/)
- **Platform**: Atlassian Bitbucket
- **Type**: Hosted CI/CD (integrated with Bitbucket)
- **Use Case**: Bitbucket repositories, Java/Python ecosystems
- **File Format**: YAML (bitbucket-pipelines.yml)
- **Key Features**: Docker support, caching, deployments, environment variables

#### [buildkite](./buildkite/)
- **Type**: Managed platform with custom agents
- **Use Case**: High-performance builds, Mac builds, custom infrastructure
- **File Format**: YAML (.buildkite/pipeline.yml), Agent scripts
- **Key Features**: Custom agents, parallelization, cost control, fast feedback

#### [drone-ci](./drone-ci/)
- **Type**: Open-source & commercial, self-hosted
- **Use Case**: Container-native pipelines, Kubernetes-ready
- **File Format**: YAML (.drone.yml)
- **Key Features**: Docker pipelines, multi-machine, secrets management

---

### **Advanced Deployment & Orchestration**

#### [spinnaker](./spinnaker/)
- **Type**: Open-source continuous deployment platform
- **Use Case**: Multi-cloud deployments, canary/blue-green strategies
- **File Format**: Groovy, YAML (Spinnaker configs)
- **Key Features**: Traffic management, rollback capabilities, policy enforcement

#### [tekton](./tekton/)
- **Type**: Kubernetes-native CI/CD
- **Use Case**: Cloud-native, container-based pipelines
- **File Format**: YAML (Kubernetes custom resources)
- **Key Features**: Steps & tasks, reusable components, GitOps integration

#### [harness](./harness/)
- **Platform**: Harness Continuous Delivery Platform
- **Type**: Commercial SaaS platform
- **Use Case**: Enterprise deployments, advanced traffic management
- **File Format**: YAML, Pipeline definitions
- **Key Features**: Intelligent rollback, verification, RBAC, cost optimization

#### [concourse-ci](./concourse-ci/)
- **Type**: Open-source CI/CD
- **Use Case**: Simple declarative pipelines, production-ready
- **File Format**: YAML (pipeline.yml)
- **Key Features**: Container-based, minimal abstractions, resource types

---

### **Infrastructure-as-Code & Automation**

#### [pulumi-automation](./pulumi-automation/)
- **Platform**: Pulumi
- **Type**: Infrastructure-as-Code automation
- **Use Case**: Programmatic infrastructure deployment (Python/Go/TypeScript)
- **File Format**: Python/Go/TypeScript/C#
- **Key Features**: Infrastructure versioning, stack management, policy as code

---

## Quick Selection Guide

### **I'm using GitHub**
→ Use [github-actions](./github-actions/) for native integration

### **I'm using GitLab**
→ Use [gitlab-ci](./gitlab-ci/) for native integration

### **I'm using Azure DevOps**
→ Use [azure-pipelines](./azure-pipelines/)

### **I'm on AWS**
→ Use [aws-codepipeline](./aws-codepipeline/) or [github-actions](./github-actions/) + AWS deploy

### **I'm on GCP**
→ Use [gcp-cloud-build](./gcp-cloud-build/)

### **I need maximum flexibility (self-hosted)**
→ Use [jenkins](./jenkins/) or [gitlb-ci](./gitlab-ci/)

### **I need Windows builds**
→ Use [appveyor](./appveyor/) or [azure-pipelines](./azure-pipelines/)

### **I'm using Kubernetes**
→ Use [tekton](./tekton/) for native integration

### **I need complex deployments**
→ Use [spinnaker](./spinnaker/) or [harness](./harness/)

---

## Platform Comparison Matrix

| Platform | Self-Hosted | Cloud | Free Tier | Enterprise | Best For |
|----------|-------------|-------|-----------|-----------|----------|
| GitHub Actions | ❌ | ✅ | ✅ | ✅ | GitHub-native projects |
| GitLab CI | ✅ | ✅ | ✅ | ✅ | Full DevOps suite |
| Azure Pipelines | ✅ | ✅ | ✅ | ✅ | Windows & .NET |
| AWS CodePipeline | ❌ | ✅ | ❌ | ✅ | AWS ecosystem |
| GCP Cloud Build | ❌ | ✅ | ✅ | ✅ | GCP ecosystem |
| Jenkins | ✅ | ❌ | ✅ | ✅ | Maximum flexibility |
| CircleCI | ❌ | ✅ | ✅ | ✅ | Developer experience |
| TravisCI | ❌ | ✅ | ✅ | ✅ | Open-source projects |
| Tekton | ✅ | ❌ | ✅ | ✅ | Kubernetes-native |
| Spinnaker | ✅ | ❌ | ✅ | ✅ | Advanced deployments |
| Harness | ✅ | ✅ | ❌ | ✅ | Enterprise deployments |

---

## Usage Instructions

1. **Navigate to your CI/CD platform subdirectory**
   ```bash
   cd pipeline/github-actions  # or your platform
   ```

2. **Copy template files to your project**
   ```bash
   cp -r template/* /path/to/your/project/
   ```

3. **Customize configuration files** with your project specifics

4. **Commit and push** to trigger pipeline

5. **Monitor execution** in your CI/CD platform dashboard

---

## Each Subdirectory Contains

- **README.md** - Platform-specific documentation
- **templates/** - Configuration templates
- **examples/** - Real-world workflow examples
- **docs/** - Detailed guides and best practices
- **scripts/** - Helper scripts for setup and validation

---

## Contributing

When adding new pipeline configurations:
1. Follow platform conventions
2. Include comprehensive documentation
3. Add examples for common use cases
4. Ensure templates are production-ready
5. Document any prerequisites

---

## Additional Resources

- [CI/CD Best Practices](../development/documentation/prompts/)
- [Architecture Documentation](../development/documentation/)
- [Project Setup Guide](../SETUP_GUIDE.md)

---

*Last Updated: 2025-12-19*
