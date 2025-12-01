# Prompt Discovery & Navigation Guide

Complete guide to finding and using the right prompt for your task from the AI-prompt library.

---

## 🎯 Quick Navigation Options

Choose your preferred method to find the right prompt:

1. **[Decision Tree / Wizard](#-interactive-decision-wizard)** - Step-by-step questionnaire
2. **[Technology × Role × Use Case Matrix](#-technology--role--use-case-matrix)** - Visual index
3. **[Tag-Based Filtering](#-tag-based-filtering-system)** - Search by keywords
4. **[Role-Based Navigation](#-role-based-organization)** - Browse by your role
5. **[Use Case Finder](#-use-case-finder)** - Browse by what you want to do

---

## 🔮 Interactive Decision Wizard

**Start here if you're not sure which prompt to use.**

### Question 1: What is your primary role?

```
A) Backend Developer / Full-Stack Developer
B) DevOps Engineer / SRE / Infrastructure
C) Security Engineer / Security Architect
D) Solutions Architect / Enterprise Architect
E) Data Engineer / ML Engineer
F) Cross-functional / Multi-role
```

**[Go to specific role section below](#-role-based-organization)**

### Question 2: What do you want to accomplish?

```
1. Code Generation / Development
2. Architecture Analysis / Design
3. Infrastructure Setup / Configuration
4. Security Assessment / Hardening
5. Monitoring / Observability
6. Deployment / CI-CD
7. Migration / Modernization
8. Documentation / Knowledge Transfer
9. Performance Optimization
10. Testing / Quality Assurance
```

### Question 3: What technology stack?

```
- Java / Spring Boot / Spring AI / Quarkus
- Python / FastAPI / Django / Flask
- Infrastructure: Terraform / Ansible / Helm / CloudFormation
- Cloud: AWS / Azure / GCP / OpenShift
- Container: Docker / Kubernetes / OpenShift
- Messaging: Kafka / RabbitMQ / SQS
- Databases: SQL / NoSQL / Data Warehousing
- Security: HashiCorp Vault / IAM / Network Security
- Monitoring: Prometheus / Grafana / ELK / CloudWatch
- Other / Multiple
```

### Question 4: What's your experience level?

```
- Beginner (Just learning)
- Intermediate (Familiar but not expert)
- Advanced (Experienced, need best practices)
- Expert (Building standards and patterns)
```

**→ [Jump to Prompt Results Table](#-prompt-results-finder)**

---

## 🏢 Role-Based Organization

### Backend Developer Prompts

| Prompt ID | Title | Use Case | Tech | Level | Output | Ref |
|-----------|-------|----------|------|-------|--------|-----|
| **PROMPT-BD-001** | Java Service Development | Code generation for microservices | Java, Spring Boot | Intermediate | Code + Docs | [📖](#) |
| **PROMPT-BD-002** | Spring AI Integration | AI/ML feature integration | Spring Boot, Spring AI | Advanced | Code + Config | [📖](#) |
| **PROMPT-BD-003** | Python REST API Design | FastAPI/Flask service creation | Python, FastAPI | Beginner | Code + Docs | [📖](#) |
| **PROMPT-BD-004** | Database Schema Design | Multi-DB model generation | Java, Python, SQL, NoSQL | Intermediate | Schema + Docs | [📖](#) |
| **PROMPT-BD-005** | Async/Event-Driven Architecture | Event handling patterns | Java, Spring Boot, Kafka | Advanced | Code + Diagram | [📖](#) |
| **PROMPT-BD-006** | API Security & Authentication | OAuth2, JWT, Security patterns | Spring Boot, FastAPI | Intermediate | Code + Config | [📖](#) |
| **PROMPT-BD-007** | Testing Strategy & Implementation | Unit/Integration/E2E testing | Java, Python, JUnit, Pytest | Intermediate | Code + Docs | [📖](#) |

**[View Full Backend Developer Prompt Catalog](./by-role/backend-developer/INDEX.md)**

---

### DevOps Engineer Prompts

| Prompt ID | Title | Use Case | Tech | Level | Output | Ref |
|-----------|-------|----------|------|-------|--------|-----|
| **PROMPT-DO-001** | Terraform Infrastructure Setup | Cloud resource provisioning | Terraform, AWS/Azure/GCP | Intermediate | IaC + Docs | [📖](#) |
| **PROMPT-DO-002** | Ansible Playbook Generation | Configuration management | Ansible, Multi-OS | Intermediate | Playbook + Docs | [📖](#) |
| **PROMPT-DO-003** | OpenShift Deployment | Kubernetes manifests generation | OpenShift, Helm, YAML | Intermediate | Config + Docs | [📖](#) |
| **PROMPT-DO-004** | CI/CD Pipeline Design | GitHub/GitLab/Jenkins setup | Jenkins, GitHub Actions, GitLab CI | Intermediate | Pipeline + Docs | [📖](#) |
| **PROMPT-DO-005** | Disaster Recovery Plan | High availability & DR setup | Multi-region, Backup strategy | Advanced | Docs + IaC | [📖](#) |
| **PROMPT-DO-006** | Container Orchestration | Kubernetes cluster setup | Kubernetes, Docker, Helm | Advanced | Manifests + Docs | [📖](#) |
| **PROMPT-DO-007** | Multi-Cloud Deployment | AWS + Azure + GCP setup | AWS, Azure, GCP, Terraform | Advanced | IaC + Docs | [📖](#) |

**[View Full DevOps Engineer Prompt Catalog](./by-role/devops-engineer/INDEX.md)**

---

### Security Engineer Prompts

| Prompt ID | Title | Use Case | Tech | Level | Output | Ref |
|-----------|-------|----------|------|-------|--------|-----|
| **PROMPT-SE-001** | Application Security Audit | Code vulnerability assessment | OWASP, SCA Tools | Intermediate | Report + Remediation | [📖](#) |
| **PROMPT-SE-002** | Infrastructure Hardening | System security hardening | Linux, Windows, Cloud IAM | Advanced | Config + Docs | [📖](#) |
| **PROMPT-SE-003** | HashiCorp Vault Integration | Secrets management setup | Vault, Spring Boot, Ansible | Advanced | Config + Code | [📖](#) |
| **PROMPT-SE-004** | Security Compliance Framework | GDPR/HIPAA/SOC2 implementation | Compliance, Auditing | Advanced | Policy + Checklist | [📖](#) |
| **PROMPT-SE-005** | Network Security Design | Firewalls, VPCs, NSGs | AWS/Azure Security Groups | Intermediate | Diagrams + Config | [📖](#) |
| **PROMPT-SE-006** | API Security Implementation | OAuth2, JWT, Rate Limiting | Spring Boot, FastAPI | Intermediate | Code + Config | [📖](#) |
| **PROMPT-SE-007** | Penetration Testing Guide | Vulnerability identification | Penetration Testing Tools | Expert | Report + Fixes | [📖](#) |

**[View Full Security Engineer Prompt Catalog](./by-role/security-engineer/INDEX.md)**

---

### Architect Prompts

| Prompt ID | Title | Use Case | Tech | Level | Output | Ref |
|-----------|-------|----------|------|-------|--------|-----|
| **PROMPT-AR-001** | Microservices Architecture | Service-oriented design | Java, Spring Boot, Event-Driven | Advanced | Architecture + Diagrams | [📖](#) |
| **PROMPT-AR-002** | Cloud Architecture Design | Multi-cloud strategy | AWS, Azure, GCP | Advanced | Architecture + Docs | [📖](#) |
| **PROMPT-AR-003** | Domain-Driven Design | DDD implementation | Java, Python, Aggregates | Advanced | Model + Code | [📖](#) |
| **PROMPT-AR-004** | System Performance Analysis | Scalability planning | Performance Testing, Load | Advanced | Report + Recommendations | [📖](#) |
| **PROMPT-AR-005** | Technology Stack Selection | Framework/DB/Infra choice | Multi-tech evaluation | Advanced | Recommendation + Justification | [📖](#) |
| **PROMPT-AR-006** | Legacy System Modernization | System upgrade strategy | Refactoring, Migration | Advanced | Plan + Phasing | [📖](#) |
| **PROMPT-AR-007** | Enterprise Integration Patterns | System integration design | Message Broker, APIs, Events | Advanced | Patterns + Diagrams | [📖](#) |

**[View Full Architect Prompt Catalog](./by-role/architect/INDEX.md)**

---

### Data Engineer Prompts

| Prompt ID | Title | Use Case | Tech | Level | Output | Ref |
|-----------|-------|----------|------|-------|--------|-----|
| **PROMPT-DE-001** | Data Pipeline Design | ETL/ELT workflow | Python, Spark, Airflow | Advanced | Config + Code | [📖](#) |
| **PROMPT-DE-002** | Data Warehouse Architecture | DW setup & optimization | Snowflake, BigQuery, Redshift | Advanced | Schema + Docs | [📖](#) |
| **PROMPT-DE-003** | Real-Time Data Processing | Stream processing setup | Kafka, Spark Streaming, Flink | Advanced | Code + Config | [📖](#) |
| **PROMPT-DE-004** | Data Governance Framework | Data quality & lineage | Data Catalog, Metadata Mgmt | Advanced | Policies + Docs | [📖](#) |
| **PROMPT-DE-005** | ML Data Preparation | Feature engineering | Python, Pandas, Scikit-learn | Intermediate | Notebooks + Code | [📖](#) |

**[View Full Data Engineer Prompt Catalog](./by-role/data-engineer/INDEX.md)**

---

## 📊 Technology × Role × Use Case Matrix

### How to Use This Matrix:

1. **Find Your Technology Column**
2. **Find Your Role Row**
3. **Look Up Your Use Case**
4. **Get Prompt ID & Link**

### Matrix

```
┌─────────────────────────────────────────────────────────────────────────┐
│ TECHNOLOGY × ROLE × USE CASE MATRIX                                    │
├─────────────────────┬──────────────────────────────────────────────────┤
│ TECH / ROLE         │ CODE GEN │ ARCH │ INFRA │ SECURITY │ MONITOR   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ JAVA / Backend Dev  │ BD-001   │ AR-01│   -   │  SE-006  │     -     │
│ JAVA / DevOps       │   -      │ DO-07│ DO-01 │  SE-002  │  DO-006   │
│ JAVA / Architect    │   -      │ AR-01│   -   │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ SPRING BOOT / Dev   │ BD-002   │ AR-01│   -   │  SE-006  │     -     │
│ SPRING BOOT / DevOps│   -      │ AR-01│ DO-03 │  SE-003  │  DO-006   │
│ SPRING AI / Dev     │ BD-002   │   -  │   -   │  SE-006  │     -     │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ PYTHON / Backend    │ BD-003   │ AR-01│   -   │  SE-006  │     -     │
│ PYTHON / DevOps     │   -      │ AR-01│ DO-02 │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ TERRAFORM / DevOps  │   -      │ AR-02│ DO-01 │  SE-002  │     -     │
│ TERRAFORM / Arch    │   -      │ AR-02│ DO-07 │  SE-002  │     -     │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ ANSIBLE / DevOps    │   -      │ DO-02│ DO-02 │  SE-002  │     -     │
│ ANSIBLE / Infra     │   -      │   -  │ DO-02 │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ OPENSHIFT / DevOps  │   -      │ AR-02│ DO-03 │  SE-002  │  DO-006   │
│ OPENSHIFT / Arch    │   -      │ AR-02│ DO-07 │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ AWS / DevOps        │   -      │ AR-02│ DO-01 │  SE-002  │  DO-006   │
│ AWS / Architect     │   -      │ AR-02│ DO-07 │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ AZURE / DevOps      │   -      │ AR-02│ DO-01 │  SE-002  │  DO-006   │
│ AZURE / Architect   │   -      │ AR-02│ DO-07 │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ GCP / DevOps        │   -      │ AR-02│ DO-01 │  SE-002  │  DO-006   │
│ GCP / Architect     │   -      │ AR-02│ DO-07 │  SE-002  │  DO-006   │
├─────────────────────┼──────────┼──────┼───────┼──────────┼───────────┤
│ VAULT / Security    │   -      │   -  │ SE-03 │  SE-003  │     -     │
│ VAULT / DevOps      │   -      │   -  │ SE-03 │  SE-003  │     -     │
└─────────────────────┴──────────┴──────┴───────┴──────────┴───────────┘
```

**Legend**:
- BD-XXX = Backend Developer
- DO-XXX = DevOps Engineer
- SE-XXX = Security Engineer
- AR-XXX = Architect
- DE-XXX = Data Engineer

---

## 🏷️ Tag-Based Filtering System

### Available Tags

```
LANGUAGE:       #java #python #javascript #go #rust #csharp
FRAMEWORK:      #spring-boot #spring-ai #fastapi #django #quarkus
INFRASTRUCTURE: #terraform #ansible #helm #cloudformation #kubernetes
CLOUD:          #aws #azure #gcp #openshift #on-premise #multi-cloud
CONTAINER:      #docker #kubernetes #openshift #container-registry
SECURITY:       #oauth2 #jwt #vault #iam #encryption #compliance
DEPLOYMENT:     #ci-cd #github-actions #jenkins #gitlab-ci #argo
DATABASE:       #sql #nosql #mongodb #postgresql #dynamodb
MESSAGING:      #kafka #rabbitmq #aws-sqs #event-driven
MONITORING:     #prometheus #grafana #elk #datadog #newrelic
USE-CASE:       #code-generation #architecture #infra-setup #security-audit
DIFFICULTY:     #beginner #intermediate #advanced #expert
OUTPUT:         #code #documentation #iac #diagrams #multiple
```

### How to Find Prompts by Tags

**Search for prompts with multiple tags** (AND operation):

```
Find: #java #spring-boot #code-generation
Result: Backend Developer prompts for Java/Spring Boot code generation
```

**Example Searches**:

1. **All DevOps Infrastructure prompts**: `#terraform #ansible #kubernetes`
2. **Security hardening on AWS**: `#aws #security #hardening`
3. **Multi-cloud deployment**: `#multi-cloud #infrastructure`
4. **Beginner Python development**: `#python #beginner #code-generation`

---

## 🔍 Use Case Finder

### By Business Need

#### "I need to build something new"
- **Code Generation**: PROMPT-BD-001, PROMPT-BD-003, PROMPT-BD-007
- **Architecture Design**: PROMPT-AR-001, PROMPT-AR-003
- **Infrastructure**: PROMPT-DO-001, PROMPT-DO-003

#### "I need to improve something existing"
- **Architecture Analysis**: PROMPT-AR-004, PROMPT-AR-006
- **Performance**: PROMPT-AR-004, PROMPT-AR-007
- **Security Audit**: PROMPT-SE-001, PROMPT-SE-005

#### "I need to deploy/manage something"
- **Infrastructure Setup**: PROMPT-DO-001, PROMPT-DO-002, PROMPT-DO-003
- **CI/CD**: PROMPT-DO-004
- **Container Orchestration**: PROMPT-DO-006

#### "I need to make something secure"
- **Application Security**: PROMPT-SE-001, PROMPT-SE-006
- **Infrastructure Hardening**: PROMPT-SE-002
- **Secrets Management**: PROMPT-SE-003
- **Compliance**: PROMPT-SE-004

#### "I need to monitor/observe something"
- **Monitoring Setup**: PROMPT-DO-005, PROMPT-DO-007
- **Performance Analysis**: PROMPT-AR-004
- **Logging & Observability**: [In Development]

#### "I need to move/upgrade something"
- **Modernization**: PROMPT-AR-006
- **Migration Strategy**: [In Development]
- **Technology Selection**: PROMPT-AR-005

---

## 📈 Prompt Results Finder

Based on your answers to the Decision Wizard, here are your recommended prompts (filtered):

### Your Profile:
- **Role**: [From Q1]
- **Goal**: [From Q2]
- **Technology**: [From Q3]
- **Level**: [From Q4]

### Recommended Prompts (Ranked by Relevance):

| Rank | Prompt ID | Title | Match | Difficulty | Time |
|------|-----------|-------|-------|------------|------|
| 1 | [ID] | [Title] | 100% | [Level] | 15-30 min |
| 2 | [ID] | [Title] | 90% | [Level] | 20-40 min |
| 3 | [ID] | [Title] | 85% | [Level] | 30-60 min |

---

## 🔗 Prompt Dependencies & Workflows

### Recommended Execution Sequences

#### "Complete Microservices Build & Deploy" Workflow
```
1. PROMPT-AR-001    → Architecture Design
   ↓ (output: design decisions)
2. PROMPT-BD-001    → Code Generation
   ↓ (output: service code)
3. PROMPT-SE-006    → Security Implementation
   ↓ (output: secured code)
4. PROMPT-BD-007    → Testing Strategy
   ↓ (output: test suite)
5. PROMPT-DO-003    → OpenShift Deployment
   ↓ (output: manifests)
6. PROMPT-DO-006    → Monitoring Setup
   ↓ (output: dashboard configs)
```

#### "Multi-Cloud Infrastructure Setup" Workflow
```
1. PROMPT-AR-002    → Cloud Architecture
   ↓ (output: design)
2. PROMPT-DO-001    → Terraform Setup (AWS)
   ↓ (output: AWS IaC)
3. PROMPT-DO-001    → Terraform Setup (Azure)
   ↓ (output: Azure IaC)
4. PROMPT-SE-002    → Hardening
   ↓ (output: security configs)
5. PROMPT-DO-006    → Container Orchestration
   ↓ (output: orchestration configs)
```

#### "Security Compliance Implementation" Workflow
```
1. PROMPT-SE-004    → Compliance Framework
   ↓ (output: policies)
2. PROMPT-SE-001    → Security Audit
   ↓ (output: findings)
3. PROMPT-SE-002    → Infrastructure Hardening
   ↓ (output: secure config)
4. PROMPT-SE-003    → Vault Integration
   ↓ (output: secrets mgmt setup)
5. PROMPT-SE-006    → API Security
   ↓ (output: secure APIs)
```

---

## 📚 Prompt Catalog Files

### By Role

- **Backend Developers**: `/by-role/backend-developer/INDEX.md`
- **DevOps Engineers**: `/by-role/devops-engineer/INDEX.md`
- **Security Engineers**: `/by-role/security-engineer/INDEX.md`
- **Architects**: `/by-role/architect/INDEX.md`
- **Data Engineers**: `/by-role/data-engineer/INDEX.md`

### By Technology

- **Java/Spring Boot**: `/by-technology/java/INDEX.md`
- **Python**: `/by-technology/python/INDEX.md`
- **Terraform**: `/by-technology/terraform/INDEX.md`
- **Ansible**: `/by-technology/ansible/INDEX.md`
- **OpenShift/Kubernetes**: `/by-technology/openshift/INDEX.md`
- **Cloud**: `/by-technology/cloud/INDEX.md`
- **Security**: `/by-technology/security/INDEX.md`

### By Use Case

- **Code Generation**: `/by-use-case/code-generation/INDEX.md`
- **Architecture**: `/by-use-case/architecture/INDEX.md`
- **Infrastructure**: `/by-use-case/infrastructure/INDEX.md`
- **Security**: `/by-use-case/security/INDEX.md`
- **Monitoring**: `/by-use-case/monitoring/INDEX.md`

---

## 🆘 Still Can't Find It?

1. **Browse the Full Catalog**: Check all role-based indexes
2. **Search by Tag**: Use the tag system above
3. **Ask for Help**: [Create an issue](../../../issues)
4. **Request New Prompt**: [Submit a feature request](../../../issues)

---

## 📞 Feedback & Improvement

- **Confusing Navigation?** [Report](../../../issues)
- **Prompt Not Useful?** [Give Feedback](../../../issues)
- **Suggest New Prompt?** [Request Feature](../../../issues)

---

**Last Updated**: December 2025  
**Maintained By**: [Team Name]
