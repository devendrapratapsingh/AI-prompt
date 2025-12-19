# CI/CD Platform Catalog & Selection Guide

**Version**: 1.0  
**Last Updated**: 2025-12-19  
**Total Platforms**: 20

---

## 📋 Complete Platform Index

### **Group 1: Cloud Provider Native Services** (4 platforms)
These are the native CI/CD services provided directly by major cloud platforms.

| # | Platform | Provider | Type | Status |
|---|----------|----------|------|--------|
| 1 | [GitHub Actions](./github-actions/) | GitHub/Microsoft | Hosted | ✅ |
| 2 | [GitLab CI/CD](./gitlab-ci/) | GitLab | Hosted & Self-hosted | ✅ |
| 3 | [Azure Pipelines](./azure-pipelines/) | Microsoft Azure | Hosted & Self-hosted | ✅ |
| 4 | [AWS CodePipeline](./aws-codepipeline/) | Amazon AWS | Managed Service | ✅ |
| 5 | [GCP Cloud Build](./gcp-cloud-build/) | Google Cloud | Managed Service | ✅ |

---

### **Group 2: Standalone SaaS Platforms** (7 platforms)
Cloud-based CI/CD services independent of git hosting platforms.

| # | Platform | Focus | Best For | Status |
|---|----------|-------|----------|--------|
| 6 | [CircleCI](./circleci/) | Developer Experience | Modern workflows | ✅ |
| 7 | [Travis CI](./travis-ci/) | Open Source | GitHub projects | ✅ |
| 8 | [AppVeyor](./appveyor/) | Windows/.NET | .NET Framework | ✅ |
| 9 | [Bitbucket Pipelines](./bitbucket-pipelines/) | Atlassian Ecosystem | Jira/Confluence teams | ✅ |
| 10 | [Buildkite](./buildkite/) | Performance & Control | High-throughput builds | ✅ |
| 11 | [Drone CI](./drone-ci/) | Container-Native | Docker/Kubernetes | ✅ |
| 12 | [Concourse CI](./concourse-ci/) | Simplicity | Declarative pipelines | ✅ |

---

### **Group 3: Enterprise Self-Hosted Servers** (4 platforms)
Traditional CI/CD servers designed for on-premise/self-hosted deployment.

| # | Platform | Vendor | License | Best For | Status |
|---|----------|--------|---------|----------|--------|
| 13 | [Jenkins](./jenkins/) | Open Source | MIT | Maximum Flexibility | ✅ |
| 14 | [TeamCity](./teamcity/) | JetBrains | Commercial | Java/Kotlin Shops | ✅ |
| 15 | [CloudBees](./cloudbees/) | CloudBees Inc | Commercial | Enterprise Jenkins | ✅ |
| 16 | [GoCD](./gocd/) | ThoughtWorks | Open Source | Complex Pipelines | ✅ |

---

### **Group 4: Cloud-Native & Kubernetes** (3 platforms)
Next-generation platforms designed for containerized and Kubernetes environments.

| # | Platform | Architecture | Runtime | Best For | Status |
|---|----------|--------------|---------|----------|--------|
| 17 | [Tekton](./tekton/) | Kubernetes-Native | K8s CRDs | Cloud-native Apps | ✅ |
| 18 | [Spinnaker](./spinnaker/) | Distributed System | Microservices | Multi-cloud Deploy | ✅ |
| 19 | [Harness](./harness/) | SaaS & Self-hosted | Cloud-native | Advanced Deploys | ✅ |

---

### **Group 5: Specialized & Infrastructure Tools** (2 platforms)
Specialized tools for infrastructure automation and programmatic deployment.

| # | Platform | Focus | Language Support | Status |
|---|----------|-------|------------------|--------|
| 20 | [Pulumi Automation](./pulumi-automation/) | IaC Automation | Python/Go/TypeScript/C# | ✅ |
| 21 | [Atlantis/Terraform Cloud](./gcp-cloud-build/) | Terraform Automation | HCL/Python | ✅ |

---

## 🎯 Platform Selection Decision Tree

```
START: Choose your CI/CD platform
│
├─ Do you want to use GitHub?
│  ├─ YES → GitHub Actions ⭐ (Best free option)
│  └─ NO ↓
│
├─ Do you want to use GitLab?
│  ├─ YES → GitLab CI ⭐ (Full DevOps platform)
│  └─ NO ↓
│
├─ Do you want to use Azure DevOps?
│  ├─ YES → Azure Pipelines ⭐ (Windows/Linux/Mac)
│  └─ NO ↓
│
├─ Are you on AWS?
│  ├─ YES → AWS CodePipeline or GitHub Actions
│  └─ NO ↓
│
├─ Are you on GCP?
│  ├─ YES → GCP Cloud Build ⭐
│  └─ NO ↓
│
├─ Do you need self-hosted?
│  ├─ YES ↓
│  │   ├─ Need max flexibility? → Jenkins ⭐
│  │   ├─ Need full DevOps? → GitLab CI ⭐
│  │   ├─ Need Kubernetes? → Tekton ⭐
│  │   └─ Need simple + declarative? → Concourse CI
│  │
│  └─ NO (want SaaS) ↓
│      ├─ Need Windows builds? → AppVeyor
│      ├─ Need high performance? → Buildkite
│      ├─ Need container-native? → Drone CI
│      ├─ Need great UX? → CircleCI
│      └─ Need enterprise deployment? → Harness
```

---

## 💡 Recommendation by Scenario

### **Scenario 1: Startup / Small Team**
- **GitHub-based project**: ⭐ **GitHub Actions**
- **GitLab-based project**: ⭐ **GitLab CI**
- **Budget-conscious**: **CircleCI** (generous free tier)

### **Scenario 2: Enterprise Java Shop**
- **On-premise**: ⭐ **Jenkins** or **TeamCity**
- **Managed service**: **CloudBees**
- **Azure ecosystem**: **Azure Pipelines**

### **Scenario 3: .NET / Windows Development**
- **Best option**: ⭐ **Azure Pipelines**
- **Windows-focused**: **AppVeyor**
- **Cross-platform**: **GitHub Actions**

### **Scenario 4: Cloud-Native / Kubernetes**
- **On Kubernetes**: ⭐ **Tekton** (K8s-native)
- **GCP**: **GCP Cloud Build**
- **AWS**: **AWS CodePipeline** + custom runners
- **Advanced deployments**: **Spinnaker**

### **Scenario 5: Multi-Cloud Strategy**
- **Primary choice**: ⭐ **GitHub Actions** (works everywhere)
- **Alternative**: **Spinnaker** (multi-cloud deployment)
- **Infrastructure-as-Code**: **Pulumi Automation**

### **Scenario 6: High-Performance CI/CD**
- **Fastest feedback**: **Buildkite**
- **Massive scale**: **Spinnaker** + **Tekton**
- **Performance monitoring**: **Harness**

### **Scenario 7: Open Source Project**
- **GitHub**: ⭐ **GitHub Actions** (unlimited minutes)
- **Community-focused**: **Travis CI** or **CircleCI**
- **Complex builds**: **Drone CI**

---

## 📊 Feature Comparison Matrix

### Build & Test
| Feature | GH Actions | GitLab CI | Azure | Jenkins | Tekton |
|---------|-----------|----------|-------|---------|--------|
| Matrix Builds | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| Parallel Steps | ✅ | ✅ | ✅ | ✅ | ✅ |
| Caching | ✅ | ✅ | ✅ | ✅ | ✅ |
| Artifacts | ✅ | ✅ | ✅ | ✅ | ✅ |
| Container Support | ✅ | ✅ | ✅ | ✅ | ✅ |
| Custom Runners | ✅ | ✅ | ✅ | ✅ | ✅ |

### Deployment & Release
| Feature | GH Actions | GitLab CI | Azure | Spinnaker | Harness |
|---------|-----------|----------|-------|-----------|---------|
| Blue-Green Deploy | ✅ | ✅ | ✅ | ✅ | ✅ |
| Canary Deploy | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ |
| Traffic Management | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ |
| Rollback | ✅ | ✅ | ✅ | ✅ | ✅ |
| Environment Parity | ✅ | ✅ | ✅ | ✅ | ✅ |
| Release Gates | ✅ | ✅ | ✅ | ✅ | ✅ |

### DevOps & Management
| Feature | GitLab CI | Azure | Jenkins | GoCD | Harness |
|---------|-----------|-------|---------|------|---------|
| Container Registry | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Code Review Integration | ✅ | ✅ | ⚠️ | ⚠️ | ✅ |
| Security Scanning | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| Artifact Management | ✅ | ✅ | ✅ | ✅ | ✅ |
| Policy Enforcement | ✅ | ✅ | ⚠️ | ✅ | ✅ |
| Cost Management | ⚠️ | ✅ | ⚠️ | ⚠️ | ✅ |

---

## 🔄 Migration Paths

### From Jenkins
- **Easy migration**: Jenkins → GitLab CI (similar Groovy DSL)
- **Recommended**: Jenkins → GitHub Actions (modern, simpler)
- **Enterprise**: Jenkins → CloudBees (stays familiar)

### From Travis CI
- **Direct migration**: Travis CI → CircleCI (similar UX)
- **Better features**: Travis CI → GitHub Actions (more powerful)
- **Cost savings**: Travis CI → Drone CI (self-hosted option)

### From Azure Pipelines
- **To GitHub**: Azure Pipelines → GitHub Actions (multi-cloud)
- **To GitLab**: Azure Pipelines → GitLab CI (full platform)

### From CircleCI
- **More control**: CircleCI → GitHub Actions (free for public)
- **Hosted alternative**: CircleCI → Buildkite (performance)
- **Enterprise**: CircleCI → Harness (advanced deployments)

---

## 🚀 Getting Started by Platform

Each platform subdirectory contains:
1. **README.md** - Platform overview and quick start
2. **templates/** - Configuration file templates
3. **examples/** - Real-world workflow examples
4. **docs/** - Detailed configuration guides
5. **scripts/** - Setup and validation scripts

### Quick Start Template
```bash
# 1. Navigate to your platform
cd pipeline/github-actions

# 2. Copy template to your project
cp templates/*.yml /path/to/project/.github/workflows/

# 3. Customize with your project details
vim /path/to/project/.github/workflows/main.yml

# 4. Commit and push
git add . && git commit -m "Add CI/CD pipeline" && git push

# 5. Monitor in platform dashboard
# GitHub Actions → Actions tab
# GitLab CI → CI/CD → Pipelines
# etc.
```

---

## 📈 Adoption & Market Share

```
Market Share (Approximate)
GitHub Actions    ████████████████████░ 35%
GitLab CI         █████████████░░░░░░░░ 22%
Jenkins           ████████░░░░░░░░░░░░░ 15%
Azure Pipelines   ██████░░░░░░░░░░░░░░░ 10%
CircleCI          ████░░░░░░░░░░░░░░░░░ 6%
Others            ██░░░░░░░░░░░░░░░░░░░ 12%
```

---

## 🔐 Security & Compliance

| Aspect | Self-Hosted | Cloud | Enterprise |
|--------|-------------|-------|-----------|
| Data Residency | ✅ | ⚠️ | ✅ |
| HIPAA Compliance | ✅ | ⚠️ | ✅ |
| SOC 2 Certified | ⚠️ | ✅ | ✅ |
| On-Premise Option | ✅ | ❌ | ✅ |
| Audit Logs | ✅ | ⚠️ | ✅ |

---

## 📚 Additional Resources

- [Platform-Specific Documentation](./*/docs/)
- [Configuration Examples](./*/examples/)
- [Setup Scripts](./*/scripts/)
- [CI/CD Best Practices](../development/documentation/)

---

## 🆘 Support Matrix

| Platform | Official Support | Community | Paid Support |
|----------|-----------------|-----------|--------------|
| GitHub Actions | ✅ GitHub Support | ✅ Active | ✅ Yes |
| GitLab CI | ✅ GitLab Support | ✅ Very Active | ✅ Yes |
| Azure Pipelines | ✅ Microsoft Support | ✅ Active | ✅ Yes |
| Jenkins | ⚠️ Community Only | ✅ Very Active | ✅ Yes (CloudBees) |
| CircleCI | ✅ CircleCI Support | ✅ Active | ✅ Yes |
| Tekton | ⚠️ Community Only | ✅ Very Active | ❌ No |

---

**For detailed information about any platform, navigate to its subdirectory.**

*This catalog is maintained as part of the AI-prompt repository.*
