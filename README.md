# AI-prompt

> A comprehensive repository of production-grade AI prompts for software engineering tasks, with specialized focus on code analysis, reverse engineering, and documentation generation.

[![GitHub](https://img.shields.io/badge/GitHub-devendrapratapsingh%2FAI--prompt-blue?logo=github)](https://github.com/devendrapratapsingh/AI-prompt)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Features](#features)
- [Use Cases](#use-cases)
- [Getting Started](#getting-started)
- [Prompt Categories](#prompt-categories)
- [Usage Guidelines](#usage-guidelines)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)

## 📖 Overview

**AI-prompt** is a specialized repository containing carefully crafted AI prompts designed for software engineers, architects, and developers. This project serves as a reference library for leveraging AI-powered tools in various software development scenarios, with particular emphasis on:

- **Code Analysis & Reverse Engineering**: Production-quality prompts for analyzing existing codebases
- **Architecture Visualization**: PlantUML diagram generation for class and sequence diagrams
- **Documentation Generation**: Enterprise-standard README, architecture summaries, and technical specifications
- **Quality Assurance**: Validation prompts and testing frameworks

## 📁 Project Structure

```
AI-prompt/
├── README.md                                      # This file - project overview and documentation
├── development/
│   └── documentation/
│       └── prompts/
│           ├── analyze_generate_class_sequence.md # Advanced code analysis and diagram generation
│           └── [other prompt files]               # Additional specialized prompts
└── .git/                                          # Git repository metadata
```

### Directory Descriptions

| Directory | Purpose |
|-----------|---------|
| `development/` | Development and internal tooling |
| `development/documentation/` | Documentation resources and templates |
| `development/documentation/prompts/` | AI prompt templates for various engineering tasks |

## ✨ Features

### Core Prompts

1. **Advanced Code Analysis & Diagram Generation** (`analyze_generate_class_sequence.md`)
   - Comprehensive codebase reverse engineering
   - Automated PlantUML class diagram generation
   - Sequence diagram creation for all major execution flows
   - Architecture documentation with validation reports
   - Support for both Java and Python projects

### Supported Technologies

- **Languages**: Java, Python
- **Java Frameworks**: Spring Boot, Quarkus, Jakarta EE, Micronaut
- **Python Frameworks**: FastAPI, Django, Flask, SQLAlchemy
- **Documentation Formats**: Markdown, AsciiDoc
- **Diagram Tools**: PlantUML

## 🎯 Use Cases

### 1. Code Reverse Engineering
Extract comprehensive architectural understanding from existing codebases:
- Identify domain models and bounded contexts
- Map layered/hexagonal/clean architecture patterns
- Document all entry points and services
- Generate complete class hierarchies

### 2. Architecture Visualization
Produce professional diagrams for documentation and presentations:
- UML class diagrams with proper enterprise patterns
- PlantUML sequence diagrams for execution flows
- Component diagrams for large projects
- Stereotypes for entity, service, controller, DTO patterns

### 3. Documentation Automation
Create enterprise-standard documentation:
- Detailed README files with technical specifications
- Architecture summaries with findings and analysis
- Validation reports confirming accuracy
- Integration with existing AsciiDoc documentation

### 4. Project Onboarding
Accelerate team member understanding:
- Visual architecture representations
- Complete flow documentation
- Domain model descriptions
- Technical decision rationale

## 🚀 Getting Started

### Prerequisites

- An AI assistant or tool capable of processing detailed prompts (e.g., ChatGPT, Claude, GitHub Copilot)
- Access to project source code you wish to analyze
- Basic understanding of software architecture concepts

### Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/devendrapratapsingh/AI-prompt.git
   cd AI-prompt
   ```

2. **Select a Prompt**
   - Browse `development/documentation/prompts/` directory
   - Choose the appropriate prompt for your task

3. **Prepare Your Input**
   - Gather the project source code
   - Identify key project details (language, framework)
   - Prepare any existing documentation

4. **Execute the Prompt**
   - Copy the prompt content
   - Provide it to your AI assistant
   - Include your project source code as instructed
   - Review and validate the generated output

5. **Process Output**
   - Generate diagrams from PlantUML files
   - Integrate documentation into your project
   - Use for team communication and onboarding

## 📚 Prompt Library Organization

### 🗂️ Directory Structure

The prompt library is organized by **Role** and **Use Case** for easy navigation:

```
development/prompts/
├── PROMPT_DISCOVERY_GUIDE.md          # 🎯 START HERE - Complete navigation guide
├── by-role/                           # Prompts organized by professional role
│   ├── backend-developer/
│   │   ├── PROMPT-BD-001-spring-boot-microservice.md
│   │   ├── PROMPT-BD-002-spring-ai-integration.md
│   │   ├── PROMPT-BD-003-python-api-design.md
│   │   └── INDEX.md
│   ├── devops-engineer/
│   │   ├── PROMPT-DO-001-terraform-multi-cloud.md
│   │   ├── PROMPT-DO-002-ansible-configuration.md
│   │   ├── PROMPT-DO-003-openshift-deployment.md
│   │   └── INDEX.md
│   ├── security-engineer/
│   │   ├── PROMPT-SE-001-security-audit.md
│   │   ├── PROMPT-SE-002-infrastructure-hardening.md
│   │   ├── PROMPT-SE-003-vault-integration.md
│   │   └── INDEX.md
│   ├── architect/
│   │   ├── PROMPT-AR-001-microservices-architecture.md
│   │   ├── PROMPT-AR-002-cloud-architecture.md
│   │   └── INDEX.md
│   └── data-engineer/
│       ├── PROMPT-DE-001-data-pipeline.md
│       └── INDEX.md
├── by-technology/                     # Prompts organized by technology
│   ├── java/
│   ├── python/
│   ├── terraform/
│   ├── ansible/
│   ├── openshift/
│   ├── cloud/
│   └── security/
├── by-use-case/                       # Prompts organized by business goal
│   ├── code-generation/
│   ├── architecture/
│   ├── infrastructure/
│   ├── security/
│   └── monitoring/
├── cross-functional/                  # Prompts for multiple roles
├── templates/
│   ├── PROMPT_TEMPLATE.md             # 📋 Standard template for all prompts
│   └── QUALITY_VALIDATION_FRAMEWORK.md # ✅ Quality assurance guidelines
└── documentation/
    ├── SETUP_GUIDE.md
    └── CONTRIBUTING.md
```

### 📊 Available Prompts by Category

#### Backend Developer Prompts

| ID | Title | Technology | Level | Use Case |
|----|-------|-----------|-------|----------|
| **PROMPT-BD-001** | Java Spring Boot Microservice | Java, Spring Boot | Intermediate | Code Generation |
| **PROMPT-BD-002** | Spring AI Integration | Spring Boot, AI/ML | Advanced | Code Generation |
| **PROMPT-BD-003** | Python REST API Design | Python, FastAPI | Beginner | Code Generation |
| **PROMPT-BD-004** | Database Schema Design | Multi-DB | Intermediate | Architecture |
| **PROMPT-BD-005** | Async Event-Driven Architecture | Java, Spring Boot, Kafka | Advanced | Architecture |
| **PROMPT-BD-006** | API Security & Authentication | Spring Boot, FastAPI | Intermediate | Security |
| **PROMPT-BD-007** | Testing Strategy & Implementation | Java, Python | Intermediate | Quality Assurance |

[View all Backend Developer prompts →](./development/prompts/by-role/backend-developer/INDEX.md)

#### DevOps Engineer Prompts

| ID | Title | Technology | Level | Use Case |
|----|-------|-----------|-------|----------|
| **PROMPT-DO-001** | Terraform Multi-Cloud Infrastructure | Terraform, AWS/Azure/GCP | Intermediate | Infrastructure Setup |
| **PROMPT-DO-002** | Ansible Playbook Generation | Ansible | Intermediate | Configuration Management |
| **PROMPT-DO-003** | OpenShift Deployment | OpenShift, Kubernetes, Helm | Intermediate | Infrastructure Setup |
| **PROMPT-DO-004** | CI/CD Pipeline Design | Jenkins, GitHub Actions, GitLab CI | Intermediate | Deployment |
| **PROMPT-DO-005** | Disaster Recovery Plan | HA, Backup, Multi-region | Advanced | Infrastructure |
| **PROMPT-DO-006** | Container Orchestration | Kubernetes, Docker, Helm | Advanced | Infrastructure Setup |
| **PROMPT-DO-007** | Multi-Cloud Deployment | Terraform, AWS, Azure, GCP | Advanced | Infrastructure |

[View all DevOps Engineer prompts →](./development/prompts/by-role/devops-engineer/INDEX.md)

#### Security Engineer Prompts

| ID | Title | Technology | Level | Use Case |
|----|-------|-----------|-------|----------|
| **PROMPT-SE-001** | Application Security Audit | OWASP, SCA Tools | Advanced | Security Audit |
| **PROMPT-SE-002** | Infrastructure Hardening | Linux, Windows, Cloud IAM | Advanced | Security |
| **PROMPT-SE-003** | HashiCorp Vault Integration | Vault, Spring Boot, Ansible | Advanced | Security |
| **PROMPT-SE-004** | Security Compliance Framework | GDPR, HIPAA, SOC2 | Advanced | Compliance |
| **PROMPT-SE-005** | Network Security Design | Cloud Security Groups, VPN | Intermediate | Security |
| **PROMPT-SE-006** | API Security Implementation | OAuth2, JWT, Rate Limiting | Intermediate | Security |
| **PROMPT-SE-007** | Penetration Testing Guide | Pen Testing Tools | Expert | Security |

[View all Security Engineer prompts →](./development/prompts/by-role/security-engineer/INDEX.md)

#### Architect Prompts

| ID | Title | Technology | Level | Use Case |
|----|-------|-----------|-------|----------|
| **PROMPT-AR-001** | Microservices Architecture | Java, Spring Boot, Event-Driven | Advanced | Architecture |
| **PROMPT-AR-002** | Cloud Architecture Design | Multi-cloud, AWS, Azure, GCP | Advanced | Architecture |
| **PROMPT-AR-003** | Domain-Driven Design | Java, Python | Advanced | Architecture |
| **PROMPT-AR-004** | System Performance Analysis | Performance Testing, Load | Advanced | Analysis |
| **PROMPT-AR-005** | Technology Stack Selection | Multi-tech evaluation | Advanced | Architecture |
| **PROMPT-AR-006** | Legacy System Modernization | Refactoring, Migration | Advanced | Architecture |
| **PROMPT-AR-007** | Enterprise Integration Patterns | Message Broker, APIs, Events | Advanced | Architecture |

[View all Architect prompts →](./development/prompts/by-role/architect/INDEX.md)

#### Data Engineer Prompts

| ID | Title | Technology | Level | Use Case |
|----|-------|-----------|-------|----------|
| **PROMPT-DE-001** | Data Pipeline Design | Python, Spark, Airflow | Advanced | Infrastructure |
| **PROMPT-DE-002** | Data Warehouse Architecture | Snowflake, BigQuery, Redshift | Advanced | Architecture |
| **PROMPT-DE-003** | Real-Time Data Processing | Kafka, Spark Streaming, Flink | Advanced | Infrastructure |
| **PROMPT-DE-004** | Data Governance Framework | Data Catalog, Metadata | Advanced | Compliance |
| **PROMPT-DE-005** | ML Data Preparation | Python, Pandas, Scikit-learn | Intermediate | Code Generation |

[View all Data Engineer prompts →](./development/prompts/by-role/data-engineer/INDEX.md)

## 🔍 How to Find the Right Prompt

### Quick Start - 4 Ways to Find Prompts

#### 1. **🎯 Interactive Decision Wizard** (Recommended for first-time users)
Start with the [Prompt Discovery Guide](./development/prompts/PROMPT_DISCOVERY_GUIDE.md#-interactive-decision-wizard) and answer 4 simple questions:
- What is your role?
- What do you want to accomplish?
- What technology stack?
- What's your experience level?

#### 2. **📊 Technology × Role × Use Case Matrix**
Use the [visual matrix](./development/prompts/PROMPT_DISCOVERY_GUIDE.md#-technology--role--use-case-matrix) to find prompts at intersection of your needs.

#### 3. **🏷️ Tag-Based Search**
Search by [tags](./development/prompts/PROMPT_DISCOVERY_GUIDE.md#-tag-based-filtering-system) like:
- `#java` `#spring-boot` `#code-generation`
- `#terraform` `#infrastructure` `#aws`
- `#security` `#owasp` `#vault`

#### 4. **📂 Browse by Role or Technology**
Direct navigation:
- **By Role**: [Backend](./development/prompts/by-role/backend-developer/INDEX.md) | [DevOps](./development/prompts/by-role/devops-engineer/INDEX.md) | [Security](./development/prompts/by-role/security-engineer/INDEX.md) | [Architect](./development/prompts/by-role/architect/INDEX.md) | [Data](./development/prompts/by-role/data-engineer/INDEX.md)
- **By Technology**: [Java](./development/prompts/by-technology/java/INDEX.md) | [Python](./development/prompts/by-technology/python/INDEX.md) | [Terraform](./development/prompts/by-technology/terraform/INDEX.md) | [Cloud](./development/prompts/by-technology/cloud/INDEX.md)

### Recommended Workflows

**Complete Microservices Build & Deploy**
```
1. PROMPT-AR-001 → Architecture Design
   ↓
2. PROMPT-BD-001 → Code Generation
   ↓
3. PROMPT-SE-006 → Security Implementation
   ↓
4. PROMPT-BD-007 → Testing Strategy
   ↓
5. PROMPT-DO-003 → OpenShift Deployment
   ↓
6. PROMPT-DO-006 → Monitoring Setup
```

**Multi-Cloud Infrastructure Setup**
```
1. PROMPT-AR-002 → Cloud Architecture
   ↓
2. PROMPT-DO-001 → Terraform (Multi-Cloud)
   ↓
3. PROMPT-SE-002 → Infrastructure Hardening
   ↓
4. PROMPT-DO-006 → Container Orchestration
```

**Security Compliance Implementation**
```
1. PROMPT-SE-004 → Compliance Framework
   ↓
2. PROMPT-SE-001 → Security Audit
   ↓
3. PROMPT-SE-002 → Infrastructure Hardening
   ↓
4. PROMPT-SE-003 → Vault Integration
   ↓
5. PROMPT-SE-006 → API Security
```

[View all recommended workflows →](./development/prompts/PROMPT_DISCOVERY_GUIDE.md#-prompt-results-finder)

## 📝 Using Prompts Effectively

### Before Using a Prompt

1. **Read the Quick Reference** - Understand purpose, difficulty, and prerequisites
2. **Check Prerequisites** - Ensure you have required knowledge and tools
3. **Review Input Questions** - Prepare answers before starting
4. **Estimate Time** - Block enough time for execution
5. **Gather Artifacts** - Collect source code, documentation, etc.

### During Prompt Execution

1. **Answer All Initial Questions** - Prompts won't proceed until all questions are answered completely
2. **Provide Complete Information** - Don't hold back details; more context = better output
3. **Read Instructions Carefully** - Follow step-by-step instructions in order
4. **Review Examples** - Study provided examples to understand expected output format

### After Prompt Execution

1. **Validate Quality** - Use the Quality Checklist provided in each prompt
2. **Review Output** - Ensure output matches expected format and content
3. **Test Results** - Execute or test generated code/configurations
4. **Document Decisions** - Record why you made certain choices
5. **Provide Feedback** - Help us improve prompts with your experience

## 📋 Prompt Template & Quality Assurance

### Understanding the Prompt Structure

All prompts follow a [standard template](./development/prompts/templates/PROMPT_TEMPLATE.md) with these sections:
- **Quick Reference** - Metadata and purpose at a glance
- **Purpose & Use Case** - When and why to use this prompt
- **Prerequisites & Requirements** - What you need before starting
- **Initial Questions** - Critical information to answer first
- **Main Task Instructions** - Step-by-step execution guide
- **Expected Output Format** - What you'll receive
- **Quality Checklist** - How to validate output
- **Examples & Sample Outputs** - Real-world use cases
- **Related Prompts** - Complementary prompts and workflows
- **Troubleshooting Guide** - Common issues and solutions
- **Best Practices** - How to use output effectively
- **Security & Compliance** - Important considerations
- **References** - Links to documentation and standards

### Quality Assurance Framework

We maintain [strict quality standards](./development/prompts/templates/QUALITY_VALIDATION_FRAMEWORK.md) for all prompts:

**7 Quality Levels**:
1. ✅ **Structural Completeness** - Template compliance
2. ✅ **Clarity & Usability** - Easy to understand
3. ✅ **Technical Accuracy** - Current and correct
4. ✅ **Execution Completeness** - All prerequisites included
5. ✅ **Security & Compliance** - Safe and compliant
6. ✅ **Multi-Role Relevance** - Appropriate for target roles
7. ✅ **Integration & Dependencies** - Works with other prompts

**Quality Scoring**: Prompts are rated on a scale of ⭐-⭐⭐⭐⭐⭐ based on comprehensive QA review.

### Role-Specific Guidance

**For Backend Developers**:
- Start with [PROMPT-BD-001](./development/prompts/by-role/backend-developer/PROMPT-BD-001-spring-boot-microservice.md) for microservice development
- Use PROMPT-BD-006 for API security patterns
- Combine with PROMPT-BD-007 for comprehensive testing

**For DevOps Engineers**:
- Start with [PROMPT-DO-001](./development/prompts/by-role/devops-engineer/PROMPT-DO-001-terraform-multi-cloud.md) for infrastructure setup
- Use PROMPT-DO-003 for container orchestration
- Reference PROMPT-SE-002 for security hardening

**For Security Engineers**:
- Start with [PROMPT-SE-001](./development/prompts/by-role/security-engineer/PROMPT-SE-001-security-audit.md) for security audits
- Use PROMPT-SE-003 for secrets management
- Reference PROMPT-SE-004 for compliance requirements

**For Architects**:
- Start with [PROMPT-AR-001](./development/prompts/by-role/architect/INDEX.md) or PROMPT-AR-002 for design
- Use related role prompts to understand implementation details
- Combine with other prompts for complete solution design

## ⭐ Best Practices for Effective Prompt Usage

### When Starting Your Journey

1. **Read This README First** - Understand the library structure
2. **Take the Decision Wizard** - Guided journey to your first prompt
3. **Study the Template** - Understand prompt anatomy
4. **Review Examples** - Learn by seeing real use cases
5. **Start Simple** - Pick a beginner-level prompt first

### Preparing to Execute a Prompt

1. **Complete Context Preparation**
   - Gather all project source code
   - Collect existing documentation and architecture diagrams
   - List external integrations and dependencies
   - Document compliance requirements
   - Prepare environment details (cloud platform, versions, etc.)

2. **Answer All Questions Clearly**
   - Re-read each question carefully
   - Provide exact, specific answers (not ambiguous)
   - Include examples where helpful
   - Don't skip questions - they're critical
   - Correct answers lead to accurate output

3. **Know the Output Format**
   - Review "Expected Output Format" section before starting
   - Prepare how you'll store/organize outputs
   - Ensure you have tools to open output files (PlantUML viewer, etc.)
   - Plan for version control of generated artifacts

### During Execution

1. **Follow Instructions Sequentially**
   - Steps are in optimal order
   - Later steps depend on earlier ones
   - Don't skip or reorder steps

2. **Provide Accurate Inputs**
   - Be precise about technical details
   - Share complete source code, not snippets
   - Include all dependencies and integrations
   - Don't hide complexity

3. **Validate at Each Stage**
   - Check that each step's output is correct
   - Identify any issues before proceeding
   - Adjust inputs if needed and re-run

### After Completion

1. **Quality Validation**
   - Use the Quality Checklist in the prompt
   - Verify all expected items are present
   - Check for any placeholder text remaining
   - Confirm output format matches specification

2. **Testing & Validation**
   - If code: Compile/run and fix any issues
   - If infrastructure: Plan before applying
   - If documentation: Review for accuracy
   - Test in dev environment first

3. **Integration & Deployment**
   - Integrate generated output into your project
   - Version control all artifacts
   - Use in CI/CD pipelines
   - Update based on feedback

### Optimization Tips

1. **Combine Related Prompts**
   - Use workflow recommendations
   - Chain multiple prompts together
   - Follow suggested sequences

2. **Reuse Across Projects**
   - Save generated outputs
   - Adapt for similar situations
   - Create templates from outputs

3. **Continuous Improvement**
   - Update prompts as technologies evolve
   - Document what worked well
   - Share improvements with team
   - Contribute back to library

## 📊 Recommended Prompts by Scenario

### Scenario: "Building a New Microservice from Scratch"

**Your Path**:
1. Start with **PROMPT-AR-001** - Design microservices architecture
2. Move to **PROMPT-BD-001** - Generate Spring Boot microservice code
3. Add security with **PROMPT-SE-006** - Implement API security
4. Ensure quality with **PROMPT-BD-007** - Testing strategy
5. Deploy with **PROMPT-DO-003** - OpenShift deployment
6. Monitor with **PROMPT-DO-006** - Container orchestration

**Estimated Time**: 4-6 hours  
**Difficulty**: Intermediate  
**Team Roles**: Architect, Backend Developer, DevOps

### Scenario: "Securing an Existing Application"

**Your Path**:
1. Start with **PROMPT-SE-001** - Security audit
2. Review findings with **PROMPT-SE-004** - Compliance framework
3. Fix issues with **PROMPT-SE-006** - API security implementation
4. Secure infrastructure with **PROMPT-SE-002** - Infrastructure hardening
5. Setup secrets with **PROMPT-SE-003** - Vault integration

**Estimated Time**: 8-10 hours  
**Difficulty**: Advanced  
**Team Roles**: Security Engineer, Backend Developer, DevOps

### Scenario: "Multi-Cloud Infrastructure Setup"

**Your Path**:
1. Design with **PROMPT-AR-002** - Cloud architecture
2. Provision with **PROMPT-DO-001** - Terraform multi-cloud
3. Secure with **PROMPT-SE-002** - Infrastructure hardening
4. Orchestrate with **PROMPT-DO-006** - Kubernetes/Container orchestration
5. Configure with **PROMPT-DO-002** - Ansible configuration management

**Estimated Time**: 6-8 hours  
**Difficulty**: Advanced  
**Team Roles**: Architect, DevOps Engineer, Security Engineer

### Scenario: "Modernizing Legacy Java Application"

**Your Path**:
1. Plan with **PROMPT-AR-006** - Legacy modernization strategy
2. Redesign architecture with **PROMPT-AR-001** - Microservices architecture
3. Generate new code with **PROMPT-BD-001** - Spring Boot microservices
4. Migrate data with **PROMPT-DE-001** - Data pipeline (if data-heavy)
5. Deploy new stack with **PROMPT-DO-003** - OpenShift deployment

**Estimated Time**: 12-16 hours  
**Difficulty**: Advanced  
**Team Roles**: Architect, Backend Developer, DevOps, Data Engineer

## 🤝 Contributing to the Prompt Library

### How to Contribute

We welcome contributions from the community! Here are ways you can help:

#### 1. Create a New Prompt

**Requirements**:
- Follow [PROMPT_TEMPLATE.md](./development/prompts/templates/PROMPT_TEMPLATE.md) structure
- Must pass [Quality Validation Framework](./development/prompts/templates/QUALITY_VALIDATION_FRAMEWORK.md)
- Include real-world examples and code samples
- Test with actual use cases before submitting

**Submission Process**:
1. Create feature branch: `git checkout -b feature/prompt-XXXX-description`
2. Create your prompt file in appropriate directory
3. Include examples and test cases
4. Ensure quality score ≥95%
5. Submit pull request with PR template completed

**PR Template**:
```markdown
## New Prompt Submission

**Prompt ID**: PROMPT-ROLE-USECASE-001
**Title**: [Clear descriptive title]
**Role**: [Backend Developer / DevOps / Security / Architect / Data Engineer]
**Use Case**: [Primary use case]
**Technology**: [Technologies involved]

### Checklist
- [ ] Follows PROMPT_TEMPLATE.md structure
- [ ] All 7 QA levels passed
- [ ] Examples are real and tested
- [ ] No placeholder text remaining
- [ ] Documentation is complete
- [ ] Troubleshooting guide covers ≥3 issues
- [ ] Related prompts are referenced
- [ ] Quality score ≥95%

### Testing Notes
- Tested with: [Real project/scenario]
- Output validation: [How was it validated?]
- Issues found and fixed: [Any issues during testing?]
```

#### 2. Improve Existing Prompts

**Contribution Types**:
- Fix typos or unclear wording
- Add missing examples or troubleshooting
- Update for new framework versions
- Improve code quality
- Enhance documentation

**Process**:
1. Create feature branch: `git checkout -b fix/prompt-XXXX-improvement`
2. Make improvements following template standards
3. Increment version number (patch, minor, or major)
4. Update CHANGELOG
5. Submit PR with clear description of changes

#### 3. Suggest New Prompts

**Process**:
1. Open a GitHub Issue with title: `[REQUEST] New Prompt - Your Idea`
2. Provide details:
   - Role/Use Case
   - Technology stack
   - Why it's needed
   - Real-world example
3. Community and maintainers discuss feasibility
4. If approved, you can implement or request someone to create it

#### 4. Report Issues & Bugs

If you find:
- **Inaccurate information**: Create issue with details
- **Outdated content**: File issue with version info
- **Security concerns**: Email security-team@example.com
- **Unclear instructions**: Submit issue with specific questions

**Issue Template**:
```markdown
## Issue Report

**Type**: [Bug / Typo / Unclear / Outdated / Security]
**Prompt ID**: PROMPT-XXXX
**Description**: [Clear description of issue]
**Impact**: [How does this affect users?]
**Suggested Fix**: [Optional solution]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
```

#### 5. Share Feedback & Improvements

- **Anonymous**: [Feedback Form](https://example.com/feedback)
- **GitHub Discussion**: [Start a discussion](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- **Email**: feedback@example.com

### Contribution Guidelines

**Code of Conduct**:
- Be respectful and constructive
- Assume good intent
- Provide helpful feedback
- Welcome diverse perspectives
- Maintain confidentiality of sensitive information

**Quality Standards**:
- All prompts must meet quality level ≥95
- Code examples must be production-ready
- Security best practices must be followed
- Documentation must be clear and complete
- Examples should be realistic and tested

**Style Guide**:
- Use clear, professional language
- Use examples for complex concepts
- Include code samples for technical content
- Use markdown formatting consistently
- Follow existing prompt style

### Review Process

**Submission to Publication**:
```
1. SUBMISSION
   ↓ (Automatic checks)
2. AUTOMATED VALIDATION
   - Template compliance ✓
   - Link validation ✓
   - Format check ✓
   ↓
3. QUALITY REVIEW (1-3 days)
   - Domain expert review
   - QA level verification
   - Example validation
   ↓
4. FEEDBACK LOOP (if needed)
   - Comments for improvements
   - Requested changes
   ↓
5. APPROVAL & PUBLICATION (24 hours)
   - Merge to main
   - Publish to library
   - Announce in community
```

**Expected Timeline**: 3-7 days from submission to publication

### Recognizing Contributors

**Contributors are recognized**:
- In [CONTRIBUTORS.md](./CONTRIBUTORS.md)
- In git commit history
- In prompt header as co-author (if significant contribution)
- In monthly contributor highlight email

### Development Setup

**Setup for Contributors**:

```bash
# Clone repository
git clone https://github.com/devendrapratapsingh/AI-prompt.git
cd AI-prompt

# Create feature branch
git checkout -b feature/your-contribution

# Make changes
# ... edit files ...

# Validate structure
./scripts/validate-prompts.sh

# Check quality
./scripts/check-quality.sh

# Test locally
# ... review your prompt ...

# Commit and push
git add .
git commit -m "feat: Add new prompt PROMPT-XXXX-description"
git push origin feature/your-contribution

# Create Pull Request on GitHub
```

**Validation Scripts** (coming soon):
- `validate-prompts.sh` - Check template compliance
- `check-quality.sh` - Run quality checks
- `test-examples.sh` - Validate code examples
- `link-check.sh` - Verify all references

### Community Support

**Getting Help as Contributor**:
- **Questions**: [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- **Technical Issues**: [GitHub Issues](https://github.com/devendrapratapsingh/AI-prompt/issues)
- **Direct Contact**: [maintainers@example.com](mailto:maintainers@example.com)

**Resources for Contributors**:
- [Prompt Template Guide](./development/prompts/templates/PROMPT_TEMPLATE.md)
- [Quality Framework](./development/prompts/templates/QUALITY_VALIDATION_FRAMEWORK.md)
- [Example Prompts](./development/prompts/by-role/)
- [Best Practices](./CONTRIBUTING.md)

## 💬 Support

### Getting Help

- **Documentation**: Review prompt descriptions and usage guidelines in this README
- **Examples**: Check the repository for reference implementations
- **Issues**: Report bugs or request features via GitHub Issues
- **Discussions**: Engage with the community for advice and best practices

### Troubleshooting

**Issue**: Prompt asks questions but doesn't proceed
- **Solution**: Ensure you answer all preliminary questions clearly and completely

**Issue**: Generated diagrams are incomplete
- **Solution**: Verify all source files were provided to the AI tool

**Issue**: Sequence diagrams don't match code flow
- **Solution**: Check that the correct framework was specified in initial questions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The MIT License allows:
- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use

With the requirement to include copyright and license notice.

## 👤 Author

**Devendra Pratap Singh**
- GitHub: [@devendrapratapsingh](https://github.com/devendrapratapsingh)
- Email: to.devendra@gmail.com

## 🔗 Repository

- **Repository**: [AI-prompt](https://github.com/devendrapratapsingh/AI-prompt)
- **Branch**: main
- **Remote**: https://github.com/devendrapratapsingh/AI-prompt

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| Repository Type | Prompt Template Library |
| Primary Purpose | Code Analysis & Documentation |
| Supported Languages | Java, Python |
| Documentation Formats | Markdown, AsciiDoc |
| Diagram Format | PlantUML |
| License | MIT |

## 🗓️ Version History

- **v1.0** (Current)
  - Initial release
  - Comprehensive code analysis prompts
  - Support for Java and Python projects
  - PlantUML diagram generation
  - Enterprise documentation templates

## ⚡ Quick Reference

### Prompt Selection Guide

| Need | Prompt | Output |
|------|--------|--------|
| Complete code analysis | `analyze_generate_class_sequence.md` | Class diagram, sequence diagrams, architecture summary |
| UML visualization | `analyze_generate_class_sequence.md` | PlantUML diagrams |
| Technical documentation | `analyze_generate_class_sequence.md` | Markdown/AsciiDoc architecture report |
| Architecture validation | `analyze_generate_class_sequence.md` | Validation report with findings |

### Command Reference

```bash
# Clone the repository
git clone https://github.com/devendrapratapsingh/AI-prompt.git

# Navigate to project
cd AI-prompt

# View available prompts
ls -la development/documentation/prompts/

# View specific prompt
cat development/documentation/prompts/analyze_generate_class_sequence.md
```

## 🎓 Learning Resources

- PlantUML Documentation: [plantuml.com](http://plantuml.com)
- UML Class Diagram Guide: [UML Class Diagrams Overview](https://www.uml-diagrams.org/class-diagrams-overview.html)
- Software Architecture Patterns: [Hexagonal, Layered, Clean Architecture](https://www.cosmicpython.com/)
- AsciiDoc Documentation: [AsciiDoc User Guide](https://asciidoc.org/)

---

**Last Updated**: December 2025

For the latest information, visit the [GitHub repository](https://github.com/devendrapratapsingh/AI-prompt).