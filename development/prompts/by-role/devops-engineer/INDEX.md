# DevOps Engineer Prompts - Complete Index

This directory contains all prompts designed for DevOps Engineers, Site Reliability Engineers (SREs), and Infrastructure Architects.

---

## 📊 Quick Reference Table

| ID | Prompt Title | Technology | Level | Use Case | Status |
|----|--------------|-----------|-------|----------|--------|
| [DO-001](#prompt-do-001) | Terraform Multi-Cloud Infrastructure | Terraform, AWS/Azure/GCP | Intermediate | Infrastructure Setup | ✅ Approved |
| [DO-002](#prompt-do-002) | Ansible Playbook Generation | Ansible | Intermediate | Configuration Management | 🚧 In Development |
| [DO-003](#prompt-do-003) | OpenShift Deployment | OpenShift, Kubernetes, Helm | Intermediate | Deployment | 🚧 In Development |
| [DO-004](#prompt-do-004) | CI/CD Pipeline Design | Jenkins, GitHub Actions, GitLab CI | Intermediate | Deployment | 🚧 Planned |
| [DO-005](#prompt-do-005) | Disaster Recovery Plan | HA, Backup, Multi-region | Advanced | Infrastructure | 🚧 Planned |
| [DO-006](#prompt-do-006) | Container Orchestration | Kubernetes, Docker, Helm | Advanced | Infrastructure Setup | 🚧 Planned |
| [DO-007](#prompt-do-007) | Multi-Cloud Deployment | Terraform, AWS, Azure, GCP | Advanced | Infrastructure | 🚧 Planned |

---

## 📝 Detailed Descriptions

### PROMPT-DO-001

**Terraform Multi-Cloud Infrastructure Setup**

- **Description**: Generate production-ready Terraform configurations for AWS, Azure, and GCP
- **Technology**: Terraform 1.5+, AWS, Azure, GCP, Git, State Management
- **Difficulty**: Intermediate-Advanced
- **Time to Execute**: 45-60 minutes
- **Output**: Complete Terraform modules, environments, state management
- **Use When**:
  - Setting up cloud infrastructure
  - Adopting multi-cloud strategy
  - Establishing IaC standards
  - Automating environment provisioning
  - Implementing disaster recovery
- **Key Features**:
  - Modular Terraform structure
  - Multi-environment support (dev, staging, prod)
  - Remote state management (S3, Azure, GCS, Terraform Cloud)
  - Security best practices (IAM, encryption, VPC)
  - Networking configuration (VPC, subnets, routing)
  - Compute resources (EC2, VMs, GCE)
  - Database setup (RDS, Azure Database, Cloud SQL)
  - Storage configuration (S3, Azure Blob, GCS)
  - Monitoring and logging integration
- **Related Prompts**: PROMPT-AR-002, PROMPT-SE-002, PROMPT-DO-002

[View Full Prompt →](./PROMPT-DO-001-terraform-multi-cloud.md)

---

### PROMPT-DO-002

**Ansible Playbook Generation**

- **Description**: Create Ansible playbooks for configuration management and orchestration
- **Technology**: Ansible 2.9+, Multiple OS (Linux, Windows)
- **Difficulty**: Intermediate
- **Time to Execute**: 45-60 minutes
- **Output**: Reusable Ansible playbooks, roles, and inventory
- **Use When**:
  - Configuring servers
  - Managing infrastructure automation
  - Post-provisioning setup
  - Rolling updates and deployments
  - Compliance and hardening
- **Key Features**:
  - Playbook structure and best practices
  - Roles and task organization
  - Variable management
  - Error handling and retries
  - Security-focused plays
  - Idempotent operations
  - Handler notifications
  - Integration with Terraform outputs
- **Status**: 🚧 In Development

---

### PROMPT-DO-003

**OpenShift Deployment & Kubernetes Manifests**

- **Description**: Generate Kubernetes manifests and OpenShift configurations
- **Technology**: OpenShift 4.x, Kubernetes 1.25+, Helm, YAML
- **Difficulty**: Intermediate
- **Time to Execute**: 45-60 minutes
- **Output**: Kubernetes/OpenShift manifests, Helm charts, deployment strategies
- **Use When**:
  - Deploying to OpenShift clusters
  - Container orchestration
  - Creating Helm charts
  - Application deployment automation
  - Multi-namespace deployments
- **Key Features**:
  - Pod and Deployment manifests
  - Service and Ingress configuration
  - ConfigMap and Secret management
  - RBAC and security policies
  - Resource limits and requests
  - Health checks and probes
  - StatefulSets and DaemonSets
  - OpenShift-specific features (Routes, etc.)
  - Helm chart generation
- **Status**: 🚧 In Development

---

### PROMPT-DO-004

**CI/CD Pipeline Design**

- **Description**: Design and implement CI/CD pipelines for automated testing and deployment
- **Technology**: Jenkins, GitHub Actions, GitLab CI, ArgoCD, Azure Pipelines
- **Difficulty**: Intermediate
- **Time to Execute**: 60-75 minutes
- **Output**: Pipeline configurations, deployment strategies, automation scripts
- **Use When**:
  - Setting up continuous integration
  - Implementing continuous deployment
  - Automating testing and builds
  - Establishing DevOps practices
  - GitOps workflows
- **Key Features**:
  - Pipeline stages (build, test, deploy)
  - Multi-environment deployments
  - Artifact management
  - Security scanning integration
  - Approval workflows
  - Deployment strategies (blue-green, canary)
  - Rollback procedures
  - Monitoring and alerting integration
- **Status**: 🚧 Planned

---

### PROMPT-DO-005

**Disaster Recovery & High Availability Planning**

- **Description**: Plan and implement disaster recovery and high availability strategies
- **Technology**: Multi-region, Backup, Database replication, Load balancing
- **Difficulty**: Advanced
- **Time to Execute**: 90-120 minutes
- **Output**: DR plan, infrastructure setup, recovery procedures
- **Use When**:
  - Ensuring business continuity
  - Multi-region deployments
  - Planning RTO/RPO targets
  - Implementing backups
  - Testing recovery procedures
- **Key Features**:
  - RTO and RPO definition
  - Multi-region setup
  - Database replication
  - Backup strategies
  - Failover automation
  - Recovery testing procedures
  - Documentation and runbooks
- **Status**: 🚧 Planned

---

### PROMPT-DO-006

**Container Orchestration & Kubernetes Setup**

- **Description**: Set up and manage Kubernetes clusters with advanced orchestration
- **Technology**: Kubernetes 1.25+, Docker, Helm, Prometheus, Logging stack
- **Difficulty**: Advanced
- **Time to Execute**: 75-90 minutes
- **Output**: Cluster setup scripts, monitoring, security configuration
- **Use When**:
  - Setting up production Kubernetes clusters
  - Container orchestration at scale
  - Multi-cluster management
  - Advanced networking and security
- **Key Features**:
  - Cluster bootstrapping
  - Network policies and CNI setup
  - RBAC and security policies
  - Monitoring and logging (Prometheus, ELK)
  - Helm package management
  - Cluster autoscaling
  - Multi-cluster federation (if needed)
- **Status**: 🚧 Planned

---

### PROMPT-DO-007

**Multi-Cloud Infrastructure with AWS, Azure, GCP**

- **Description**: Manage infrastructure across multiple cloud providers
- **Technology**: Terraform, AWS, Azure, GCP, Cloud-specific APIs
- **Difficulty**: Advanced
- **Time to Execute**: 90-120 minutes
- **Output**: Multi-cloud infrastructure setup, federation, cost optimization
- **Use When**:
  - Multi-cloud strategy
  - Cloud vendor redundancy
  - Cost optimization across clouds
  - Workload distribution
  - Hybrid cloud setups
- **Key Features**:
  - Provider-agnostic infrastructure
  - Cross-cloud networking
  - Data synchronization
  - Billing and cost tracking
  - Vendor-neutral tools integration
  - Failover across clouds
  - Compliance across regions
- **Status**: 🚧 Planned

---

## 🎯 Recommended Learning Path

### For Beginners (New to Infrastructure)

```
1. Start: PROMPT-DO-001 (Terraform Basics)
   └─ Master: Infrastructure-as-Code concepts
2. Next: PROMPT-DO-002 (Ansible Basics)
   └─ Learn: Configuration management
3. Then: PROMPT-DO-003 (Container Deployment)
   └─ Build: Container orchestration skills
```

### For Intermediate DevOps

```
1. Start: PROMPT-DO-001 (Multi-environment Terraform)
   └─ Solidify: IaC patterns
2. Next: PROMPT-DO-004 (CI/CD Pipelines)
   └─ Learn: Automation
3. Then: PROMPT-DO-006 (Kubernetes)
   └─ Master: Container orchestration
```

### For Advanced Engineers (SRE focus)

```
1. Start: PROMPT-DO-006 (Kubernetes at Scale)
   └─ Master: Advanced orchestration
2. Next: PROMPT-DO-005 (Disaster Recovery)
   └─ Plan: Business continuity
3. Then: PROMPT-DO-007 (Multi-Cloud)
   └─ Architect: Cloud strategy
```

---

## 🏷️ Tags & Search

### By Technology

- **#terraform**: DO-001, DO-007
- **#ansible**: DO-002, DO-005
- **#kubernetes**: DO-003, DO-006
- **#openshift**: DO-003
- **#aws**: DO-001, DO-007
- **#azure**: DO-001, DO-007
- **#gcp**: DO-001, DO-007
- **#docker**: DO-003, DO-006
- **#helm**: DO-003, DO-006
- **#jenkins**: DO-004
- **#github-actions**: DO-004
- **#gitops**: DO-004

### By Use Case

- **#infrastructure-setup**: DO-001, DO-003, DO-006
- **#infrastructure-automation**: DO-002
- **#deployment**: DO-003, DO-004, DO-007
- **#disaster-recovery**: DO-005
- **#multi-cloud**: DO-007
- **#configuration-management**: DO-002
- **#monitoring**: DO-006

### By Difficulty

- **#intermediate**: DO-001, DO-002, DO-003, DO-004
- **#advanced**: DO-005, DO-006, DO-007

---

## 📊 Technology Coverage Matrix

| Technology | Prompts | Coverage |
|-----------|---------|----------|
| Terraform | DO-001, DO-007 | Infrastructure automation |
| Ansible | DO-002, DO-005 | Configuration management |
| Kubernetes | DO-003, DO-006 | Container orchestration |
| OpenShift | DO-003 | Enterprise Kubernetes |
| AWS | DO-001, DO-007 | Cloud infrastructure |
| Azure | DO-001, DO-007 | Cloud infrastructure |
| GCP | DO-001, DO-007 | Cloud infrastructure |
| CI/CD | DO-004 | Pipeline automation |
| DR/HA | DO-005 | Disaster recovery |

---

## 🔗 Cross-Role References

These prompts work well with:

| Other Role | Prompts | Integration Points |
|-----------|---------|-------------------|
| Architect | PROMPT-AR-002 | Infrastructure design |
| Backend Dev | PROMPT-BD-001 | Application deployment |
| Security | PROMPT-SE-002 | Infrastructure hardening |

---

## 📞 Support & Feedback

- **Questions**: [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- **Report Issues**: [GitHub Issues](https://github.com/devendrapratapsingh/AI-prompt/issues)
- **Suggest Improvements**: [Feedback Form](https://example.com/feedback)

---

**Last Updated**: December 2025  
**Maintained By**: DevOps & SRE Team  
**Next Review**: March 2026
