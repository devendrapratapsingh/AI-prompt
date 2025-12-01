# Terraform Multi-Cloud Infrastructure Setup

**Title**: Terraform Multi-Cloud Infrastructure - AWS, Azure, GCP Setup & Best Practices

**Version**: 1.0  
**Last Updated**: 2025-12-01  
**Author**: DevOps Team  
**Status**: Approved

---

### 📋 Quick Reference

| Property | Value |
|----------|-------|
| **Prompt ID** | PROMPT-DO-001 |
| **Role** | DevOps Engineer, Infrastructure Architect |
| **Use Case** | Infrastructure Setup & Cloud Resource Provisioning |
| **Technology Stack** | Terraform, AWS, Azure, GCP, Git, State Management |
| **Difficulty Level** | Intermediate - Advanced |
| **Output Format** | Infrastructure-as-Code (HCL2) + Documentation |
| **Documentation Format** | Markdown + AsciiDoc |
| **Cloud Platforms** | AWS, Azure, GCP, Multi-Cloud |
| **Tags** | #terraform #infrastructure #aws #azure #gcp #iac #multi-cloud #advanced |
| **Dependencies** | PROMPT-AR-002, PROMPT-SE-002, PROMPT-DO-002 |
| **Estimated Duration** | 45-60 minutes |

---

### 🎯 Purpose & Use Case

**Primary Purpose**:  
Generate production-ready Terraform configurations for multi-cloud infrastructure setup with proper state management, modularity, security best practices, networking, storage, and monitoring. Supports AWS, Azure, and GCP platforms with consistent patterns across clouds.

**When to Use**:
- Setting up cloud infrastructure from scratch
- Migrating to multi-cloud strategy
- Creating infrastructure for microservices deployment
- Establishing infrastructure-as-code standards
- Automating environment provisioning (dev, staging, prod)
- Disaster recovery and backup infrastructure setup

**When NOT to Use**:
- Simple single-service deployments (use cloud console or managed services)
- Temporary/experimental infrastructure (use CloudFormation one-liners)
- Legacy systems with manual configuration (complex migration first)
- Simple storage solutions (use cloud-native solutions directly)

**Business Value**:
- Reduces manual infrastructure setup time by 70-80%
- Ensures consistency and repeatability across environments
- Enables infrastructure version control and audit trails
- Reduces configuration drift and errors
- Enables rapid disaster recovery
- Supports multi-cloud strategy and avoids vendor lock-in

---

### 📚 Prerequisites & Requirements

**Required Knowledge**:
- Terraform fundamentals and HCL syntax (Intermediate level)
- Cloud platform concepts (AWS/Azure/GCP) (Intermediate level)
- Networking and security concepts (Intermediate level)
- Git version control (Intermediate level)
- CI/CD pipelines and automation (Basic level)

**Required Tools/Software**:
- Terraform 1.5+ (latest stable)
- AWS CLI 2.10+ (for AWS)
- Azure CLI 2.50+ (for Azure)
- Google Cloud SDK 400+ (for GCP)
- Git 2.30+
- Text editor/IDE (VS Code, vim, etc.)
- AWS/Azure/GCP account with appropriate permissions

**Input Artifacts Needed**:
- Cloud platform requirements and specifications
- Networking topology and CIDR blocks
- Security requirements and compliance needs
- Resource sizing and scaling requirements
- Backup and disaster recovery requirements
- Monitoring and logging requirements

**System Requirements**:
- Minimum 2GB RAM for Terraform operations
- 500MB+ disk space for Terraform state
- Network access to cloud APIs
- VPN or secure access to cloud resources

---

### ❓ Initial Questions (Answer Before Proceeding)

**Question 1**: Which cloud platform(s) do you need infrastructure for?
- Expected format: Exactly one of: "AWS", "Azure", "GCP", or "AWS+Azure+GCP"
- Example: "AWS" or "AWS+Azure"

**Question 2**: What is your primary application/workload type?
- Expected format: One of: "Microservices on Kubernetes", "Traditional Application Servers", "Data Processing Pipeline", "Serverless", "Database-Heavy", "Multi-tier"
- Example: "Microservices on Kubernetes"

**Question 3**: What are your core infrastructure components needed? (List)
- Expected format: Comma-separated list from: "VPC/Network", "Compute (VM/Instances)", "Kubernetes", "Database", "Storage", "Load Balancer", "Messaging/Queuing", "Monitoring"
- Example: "VPC/Network, Kubernetes, Database, Storage, Load Balancer, Monitoring"

**Question 4**: What state management and backend strategy do you want?
- Expected format: Exactly one of: "Terraform Cloud", "S3 (AWS)", "Azure Blob Storage", "GCS (GCP)", "Local"
- Example: "Terraform Cloud" or "S3 (AWS)"

**Question 5**: What are your environment requirements?
- Expected format: List of environment names and details
- Example: "dev (small), staging (medium), production (large with HA)"

> ⚠️ **CRITICAL**: Do not proceed with the main task until ALL questions above are answered clearly and completely.

---

### 🔧 Main Task Instructions

**Objective**: Generate production-ready Terraform configurations for multi-cloud infrastructure with proper modularity, state management, and security.

**Step-by-Step Instructions**:

1. **Project Structure Setup**
   - Create root `main.tf` for provider configuration
   - Create `variables.tf` for all input variables
   - Create `outputs.tf` for exported values
   - Create `terraform.tfvars` template (with placeholders)
   - Create modular structure: `modules/` with subdirectories for each component
   - Create environment-specific directories: `environments/{dev,staging,prod}`

2. **Provider Configuration**
   - Configure AWS provider with region, profile, tags
   - Configure Azure provider with subscription, tenant, authentication
   - Configure GCP provider with project, region, credentials
   - Add Terraform backend configuration for state management
   - Implement provider versioning with `required_providers`

3. **Networking Module**
   - Create VPC/Virtual Networks with CIDR blocks
   - Create subnets (public, private, database subnets)
   - Configure Internet Gateway / NAT Gateway
   - Create route tables and associations
   - Implement security groups / Network Security Groups
   - Add VPN/Peering if multi-cloud

4. **Compute Module**
   - Create compute instances (EC2, VM instances, GCE instances)
   - Configure auto-scaling groups / VMSSs
   - Create load balancers (ALB/NLB, Azure LB, GCP LB)
   - Implement security group rules
   - Add user data / initialization scripts

5. **Database Module**
   - Create database instances (RDS, Azure Database, Cloud SQL)
   - Configure backup policies and retention
   - Implement database security (encryption, IAM)
   - Create read replicas if needed
   - Configure database subnets and security groups

6. **Storage Module**
   - Create object storage (S3, Azure Blob, GCS)
   - Configure versioning and lifecycle policies
   - Implement encryption at rest
   - Set up access policies and IAM roles
   - Configure logging and monitoring

7. **Kubernetes/Container Module** (if applicable)
   - Create Kubernetes clusters (EKS, AKS, GKE)
   - Configure node groups and scaling policies
   - Implement network policies
   - Set up RBAC and security
   - Add ingress controllers and CNI plugins

8. **Security & IAM Module**
   - Create IAM roles and policies
   - Implement principle of least privilege
   - Configure KMS keys for encryption
   - Set up secrets management (Secrets Manager, Key Vault, Secret Manager)
   - Implement VPC Flow Logs / Network Monitoring

9. **Monitoring & Logging Module**
   - Create CloudWatch/Azure Monitor/Cloud Logging configurations
   - Set up log aggregation
   - Create dashboards
   - Configure alerts and notifications
   - Implement audit logging

10. **State Management & Backend**
    - Configure remote state storage (S3, Azure, GCS, or Terraform Cloud)
    - Implement state locking
    - Enable versioning on state
    - Configure state encryption
    - Create backend initialization scripts

11. **Variables & Outputs**
    - Define all variables with descriptions and constraints
    - Set appropriate defaults
    - Create outputs for important resource IDs
    - Export connection strings and endpoints
    - Create terraform.tfvars template with examples

12. **Documentation & Scripts**
    - Create comprehensive README.md
    - Document all modules and variables
    - Create deployment scripts (init, plan, apply, destroy)
    - Add troubleshooting guide
    - Include environment setup instructions

---

### 📤 Expected Output Format

**Primary Deliverables**:
- File 1: `main.tf` - Root provider and backend configuration
- File 2: `variables.tf` - All input variables with descriptions
- File 3: `outputs.tf` - Exported values and important resource attributes
- File 4: `terraform.tfvars.template` - Variable values template
- File 5: `modules/` - Modular Terraform configurations
- File 6: `environments/` - Environment-specific configurations
- File 7: `scripts/` - Deployment and management scripts
- File 8: `README.md` - Complete setup and deployment documentation

**Output Structure Example**:
```
terraform-infrastructure/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.template
├── backend.tf
├── providers.tf
├── .terraform/
├── terraform.tfstate (in remote backend)
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── sg.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── asg.tf
│   │   └── lb.tf
│   ├── database/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars
│   │   └── outputs.txt
│   ├── staging/
│   │   ├── terraform.tfvars
│   │   └── outputs.txt
│   └── prod/
│       ├── terraform.tfvars
│       └── outputs.txt
└── scripts/
    ├── init-backend.sh
    ├── plan.sh
    ├── apply.sh
    ├── destroy.sh
    └── validate.sh
```

**Output Specifications**:
- Format: HCL2 (Terraform configuration language)
- Should include: Modules, state backend, provider config, security, monitoring, documentation
- Variables: Parameterized for reusability across environments
- Comments: Inline documentation for non-obvious configurations

---

### 📋 Quality Checklist for Output

- [ ] All resources use modules for reusability
- [ ] State management configured with remote backend
- [ ] Security best practices applied (security groups, IAM policies, encryption)
- [ ] All sensitive values use variables (no hardcoded passwords/keys)
- [ ] Terraform validates without errors (`terraform validate`)
- [ ] All modules have proper inputs and outputs
- [ ] Documentation covers all setup steps
- [ ] Environment-specific configurations properly separated
- [ ] Monitoring and logging configured
- [ ] Disaster recovery / backup strategy implemented
- [ ] Scaling policies and auto-scaling configured
- [ ] Tags applied to all resources
- [ ] Cost optimization applied (right-sizing, scheduling)
- [ ] VPC/Network security properly configured
- [ ] IAM follows principle of least privilege

---

### 💡 Examples & Sample Outputs

**Example 1: AWS EKS Microservices Infrastructure**

**Input**:
```
Cloud Platform: AWS
Application: Microservices on Kubernetes
Components: VPC/Network, Kubernetes (EKS), Database (RDS), Storage (S3), Monitoring
Environments: dev, staging, prod
Backend: S3 (AWS)
```

**Expected Output**:
- VPC with public/private subnets across multiple AZs
- EKS cluster with auto-scaling node groups
- RDS PostgreSQL with Multi-AZ
- S3 buckets with versioning and lifecycle policies
- CloudWatch dashboards and alarms
- IAM roles following least privilege
- Environment-specific tfvars for dev/staging/prod

---

**Example 2: Multi-Cloud Infrastructure (AWS + Azure)**

**Input**:
```
Cloud Platform: AWS + Azure
Application: Multi-region deployment
Components: VPC/Virtual Network, Compute, Database, Storage, Load Balancer
Environments: dev, prod
Backend: Terraform Cloud
```

**Expected Output**:
- AWS VPC and Azure vNET with VPN peering
- EC2 and Azure VMs with load balancing
- Separate RDS and Azure Database instances
- Cross-cloud failover strategy
- Terraform Cloud for state management
- Deployment scripts for multi-cloud

---

### 🔗 Related Prompts & Dependencies

**Related Prompts**:
- **PROMPT-AR-002**: Cloud Architecture Design - Use this first to plan architecture
- **PROMPT-SE-002**: Infrastructure Hardening - Use for security hardening
- **PROMPT-DO-002**: Ansible Configuration Management - Use for post-provisioning setup
- **PROMPT-DO-006**: Kubernetes Cluster Setup - Use for container orchestration

**Recommended Sequence**:
1. **PROMPT-AR-002** - Design cloud architecture
2. **PROMPT-DO-001** - Generate Terraform IaC (this prompt)
3. **PROMPT-SE-002** - Harden infrastructure security
4. **PROMPT-DO-002** - Configure with Ansible
5. **PROMPT-DO-006** - Deploy applications on Kubernetes

---

### 🐛 Troubleshooting Guide

**Issue 1: State file conflicts and locking issues**
- **Symptom**: "Error acquiring the state lock" or conflicting state files
- **Root Cause**: Multiple Terraform operations running simultaneously or state lock not releasing
- **Solution**:
  1. Ensure only one `terraform apply` is running at a time
  2. Check AWS DynamoDB table (for S3 backend) for stuck locks
  3. Use `terraform force-unlock` only as last resort
  4. Enable state locking in backend configuration
- **Prevention**: Use Terraform Cloud for automatic locking; use CI/CD for serialized operations

**Issue 2: Provider version conflicts**
- **Symptom**: "Error installing provider" or version mismatch errors
- **Root Cause**: Terraform or provider version incompatibility
- **Solution**:
  1. Check `required_version` in terraform block
  2. Update `required_providers` to compatible versions
  3. Run `terraform init -upgrade`
  4. Check AWS/Azure/GCP CLI compatibility
- **Prevention**: Pin provider versions with `~>` to allow patch updates only

**Issue 3: Security group rules not applying**
- **Symptom**: Traffic still blocked despite security group modifications
- **Root Cause**: Rules not properly applied or ingress/egress confusion
- **Solution**:
  1. Check rule direction (ingress vs egress)
  2. Verify CIDR blocks and port ranges
  3. Check rule order in security groups
  4. Ensure security groups are attached to resources
- **Prevention**: Use `terraform plan` to verify before applying

---

### 📝 Best Practices

1. **Modular Structure**
   - Create separate modules for each infrastructure component
   - Each module should be independently deployable
   - Use module registries for reusable components

2. **State Management**
   - Always use remote state (S3, Azure, GCS, Terraform Cloud)
   - Enable encryption and versioning on state storage
   - Implement state locking to prevent conflicts
   - Regularly back up state files

3. **Security Best Practices**
   - Use IAM roles/managed identities instead of keys
   - Enable encryption for all data (EBS, RDS, S3, etc.)
   - Use security groups and NACLs for network isolation
   - Implement VPC Flow Logs for network monitoring
   - Store secrets in Vault/Secrets Manager, never in code

4. **Variable Management**
   - Always use variables for configuration values
   - Provide descriptions and validation for variables
   - Use `.tfvars` files for environment-specific values
   - Never commit sensitive variables to version control

5. **Documentation**
   - Document all modules and variables
   - Include setup and deployment instructions
   - Provide examples for common use cases
   - Keep README updated with changes

---

### ⚠️ Security & Compliance Considerations

**Security Aspects**:
- Use VPC security groups and NACLs for network isolation
- Enable encryption at rest (EBS, RDS, S3) and in transit
- Implement IAM policies following least privilege principle
- Use VPC Flow Logs and CloudTrail for audit logging
- Implement DDoS protection (AWS Shield, Azure DDoS, GCP Cloud Armor)

**Compliance Requirements**:
- HIPAA: Ensure encryption, audit logging, access controls
- GDPR: Implement data retention policies, right to erasure
- PCI-DSS: Use AWS Private Link, encrypt payment data
- SOC 2: Implement monitoring, access controls, incident response

**Sensitive Information**:
- Never commit passwords, API keys, or certificates to git
- Use Vault or cloud secrets managers
- Rotate credentials regularly
- Use `sensitive = true` for Terraform outputs with secrets

---

### 📚 References & Documentation

**Official Documentation**:
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/)
- [GCP Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/)

**Best Practices**:
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

### 📊 Prompt Metadata

**Prompt ID**: PROMPT-DO-001  
**Category**: DevOps / Infrastructure  
**Subcategory**: Terraform / IaC  
**Complexity Score**: 8/10  
**Reusability Score**: 9/10  
**Last Reviewed**: 2025-12-01  
**Review Cycle**: Every 3 months  

---

### ✅ Quality Assurance Sign-Off

- **Prompt Accuracy**: ✓ Verified with Terraform 1.5+ and latest provider versions
- **Completeness**: ✓ All required sections present
- **Clarity**: ✓ Clear for intermediate to advanced DevOps engineers
- **Tested**: ✓ Executed successfully with AWS multi-environment setup
- **Security**: ✓ Follows security best practices; no sensitive data exposed
- **Compliance**: ✓ Follows organizational standards

**Approved By**: DevOps Team, Date: 2025-12-01  
**Last Validated**: 2025-12-01  

---

**Footer Note**: This prompt is part of the AI-prompt library. For navigation and discovery, refer to [PROMPT_DISCOVERY_GUIDE.md](../../PROMPT_DISCOVERY_GUIDE.md).
