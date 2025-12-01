# Security Engineer Prompts - Complete Index

This directory contains all prompts designed for Security Engineers, AppSec specialists, and InfoSec architects.

---

## 📊 Quick Reference Table

| ID | Prompt Title | Technology | Level | Use Case | Status |
|----|--------------|-----------|-------|----------|--------|
| [SE-001](#prompt-se-001) | Application Security Audit | OWASP, SCA Tools | Advanced | Security Audit | ✅ Approved |
| [SE-002](#prompt-se-002) | Infrastructure Hardening | Linux, Windows, Cloud IAM | Advanced | Security | 🚧 In Development |
| [SE-003](#prompt-se-003) | HashiCorp Vault Integration | Vault, Spring Boot, Ansible | Advanced | Security | 🚧 In Development |
| [SE-004](#prompt-se-004) | Security Compliance Framework | GDPR, HIPAA, SOC2, PCI-DSS | Advanced | Compliance | 🚧 Planned |
| [SE-005](#prompt-se-005) | Network Security Design | Cloud Security Groups, VPN | Intermediate | Security | 🚧 Planned |
| [SE-006](#prompt-se-006) | API Security Implementation | OAuth2, JWT, Rate Limiting | Intermediate | Security | 🚧 Planned |
| [SE-007](#prompt-se-007) | Penetration Testing Guide | Pen Testing Tools | Expert | Security | 🚧 Planned |

---

## 📝 Detailed Descriptions

### PROMPT-SE-001

**Application Security Audit & Vulnerability Assessment**

- **Description**: Perform comprehensive security audit against OWASP Top 10
- **Technology**: OWASP Top 10, SCA Tools, SAST, Java, Python, Node.js
- **Difficulty**: Advanced
- **Time to Execute**: 60-90 minutes
- **Output**: Security report, vulnerability findings, remediation code examples
- **Use When**:
  - Pre-production security assessment
  - Regular security audits
  - Pre-release security checks
  - Compliance verification
  - Post-incident improvements
- **Key Features**:
  - SAST (Static Analysis Security Testing)
  - OWASP Top 10 mapping
  - Dependency vulnerability scanning
  - Risk assessment and prioritization
  - Code review for security patterns
  - Data flow analysis
  - Compliance mapping (GDPR, HIPAA, PCI-DSS)
  - Secure code examples
  - Testing recommendations
- **Related Prompts**: PROMPT-SE-006, PROMPT-SE-004, PROMPT-SE-002

[View Full Prompt →](./PROMPT-SE-001-security-audit.md)

---

### PROMPT-SE-002

**Infrastructure Hardening**

- **Description**: Harden infrastructure security across cloud and on-premise
- **Technology**: Linux, Windows, Cloud IAM, Firewalls, VPC, Encryption
- **Difficulty**: Advanced
- **Time to Execute**: 75-90 minutes
- **Output**: Hardening checklist, configuration scripts, security policies
- **Use When**:
  - Securing infrastructure
  - Compliance requirements
  - Post-breach hardening
  - Baseline security setup
  - Security standards establishment
- **Key Features**:
  - OS-level hardening (Linux, Windows)
  - Cloud-native security (AWS, Azure, GCP)
  - IAM policy enforcement
  - Network segmentation and ACLs
  - Encryption at rest and in transit
  - Secret management
  - Security monitoring
  - Patch management
  - Vulnerability scanning
- **Status**: 🚧 In Development

---

### PROMPT-SE-003

**HashiCorp Vault Integration**

- **Description**: Implement Vault for secrets management and dynamic credentials
- **Technology**: HashiCorp Vault, Spring Boot, Python, Ansible, Cloud IAM
- **Difficulty**: Advanced
- **Time to Execute**: 60-75 minutes
- **Output**: Vault setup, integration code, policies, rotation scripts
- **Use When**:
  - Centralizing secrets management
  - Dynamic credentials generation
  - Encryption key management
  - Compliance with secret rotation
  - Cross-environment secret sharing
- **Key Features**:
  - Vault cluster setup and configuration
  - Secret engines (KV, database, PKI)
  - Authentication methods (AppRole, JWT, OIDC)
  - Access policies and RBAC
  - Secret rotation automation
  - Dynamic database credentials
  - Application integration code
  - High availability setup
  - Disaster recovery
- **Status**: 🚧 In Development

---

### PROMPT-SE-004

**Security Compliance Framework**

- **Description**: Implement compliance frameworks (GDPR, HIPAA, SOC2, PCI-DSS)
- **Technology**: Compliance standards, audit logging, access controls
- **Difficulty**: Advanced
- **Time to Execute**: 90-120 minutes
- **Output**: Compliance roadmap, policy templates, checklist, evidence collection
- **Use When**:
  - Achieving compliance certification
  - Building compliance programs
  - Audit preparation
  - Regulatory requirements
  - Customer compliance requirements
- **Key Features**:
  - Compliance requirement mapping
  - Control implementation guidance
  - Evidence collection templates
  - Audit logging configuration
  - Access control policies
  - Data protection measures
  - Incident response procedures
  - Documentation requirements
  - Remediation tracking
- **Status**: 🚧 Planned

---

### PROMPT-SE-005

**Network Security Design**

- **Description**: Design secure network architecture and access controls
- **Technology**: Cloud Security Groups, VPN, Firewalls, Network segmentation
- **Difficulty**: Intermediate
- **Time to Execute**: 60-75 minutes
- **Output**: Network diagrams, security group configurations, VPN setup
- **Use When**:
  - Designing secure networks
  - Establishing network segmentation
  - VPN/VPC setup
  - DDoS protection
  - Firewall policies
- **Key Features**:
  - Network architecture design
  - Security group/NACL rules
  - VPC and subnet segmentation
  - VPN and bastion host setup
  - DDoS protection configuration
  - Network monitoring (Flow Logs)
  - Threat detection rules
  - Access control lists
- **Status**: 🚧 Planned

---

### PROMPT-SE-006

**API Security Implementation**

- **Description**: Implement secure APIs with authentication, authorization, rate limiting
- **Technology**: Spring Boot, FastAPI, OAuth2, JWT, Spring Security
- **Difficulty**: Intermediate
- **Time to Execute**: 45-60 minutes
- **Output**: Secure API code, configuration, security middleware
- **Use When**:
  - Securing REST APIs
  - Implementing OAuth2/OpenID Connect
  - Token-based authentication
  - Rate limiting and throttling
  - CORS security
  - API key management
- **Key Features**:
  - OAuth2/OIDC implementation
  - JWT token creation and validation
  - Spring Security configuration
  - Rate limiting middleware
  - CORS policy configuration
  - Input validation and sanitization
  - Security headers (CSP, HSTS)
  - API versioning and deprecation
  - Audit logging
- **Status**: 🚧 Planned

---

### PROMPT-SE-007

**Penetration Testing Guide**

- **Description**: Conduct and plan penetration testing activities
- **Technology**: Penetration testing tools, exploit frameworks, vulnerability databases
- **Difficulty**: Expert
- **Time to Execute**: 120-180 minutes (ongoing testing)
- **Output**: Penetration test report, findings, remediation recommendations
- **Use When**:
  - Security validation testing
  - Pre-release penetration test
  - Third-party security assessment
  - Post-incident testing
  - Red team exercises
- **Key Features**:
  - Scope and rules of engagement definition
  - Reconnaissance and enumeration
  - Exploitation techniques
  - Post-exploitation analysis
  - Vulnerability reporting
  - Risk assessment
  - Remediation recommendations
  - Testing documentation
- **Status**: 🚧 Planned

---

## 🎯 Recommended Learning Path

### For Security Beginners

```
1. Start: PROMPT-SE-006 (API Security)
   └─ Master: Foundational security patterns
2. Next: PROMPT-SE-001 (Security Audit)
   └─ Learn: Vulnerability assessment
3. Then: PROMPT-SE-005 (Network Security)
   └─ Build: Network security knowledge
```

### For Intermediate Security Engineers

```
1. Start: PROMPT-SE-001 (Security Audit)
   └─ Solidify: Comprehensive security assessment
2. Next: PROMPT-SE-002 (Infrastructure Hardening)
   └─ Learn: Infrastructure security
3. Then: PROMPT-SE-003 (Vault Integration)
   └─ Master: Secrets management
4. Next: PROMPT-SE-004 (Compliance Framework)
   └─ Understand: Compliance requirements
```

### For Advanced Security Architects

```
1. Start: PROMPT-SE-004 (Compliance Framework)
   └─ Master: Regulatory compliance
2. Next: PROMPT-SE-002 (Infrastructure Hardening)
   └─ Architect: Enterprise security
3. Then: PROMPT-SE-007 (Penetration Testing)
   └─ Conduct: Security validation
4. Reference: PROMPT-AR-002 (Cloud Architecture)
   └─ Align: With architecture decisions
```

---

## 🏷️ Tags & Search

### By Technology

- **#owasp**: SE-001, SE-004, SE-006
- **#vault**: SE-003
- **#iam**: SE-002, SE-004
- **#encryption**: SE-002, SE-003
- **#oauth2**: SE-006
- **#jwt**: SE-006
- **#compliance**: SE-004
- **#gdpr**: SE-004
- **#hipaa**: SE-004
- **#pci-dss**: SE-004
- **#soc2**: SE-004
- **#penetration-testing**: SE-007

### By Use Case

- **#security-audit**: SE-001
- **#hardening**: SE-002
- **#secrets-management**: SE-003
- **#compliance**: SE-004
- **#network-security**: SE-005
- **#api-security**: SE-006
- **#penetration-testing**: SE-007
- **#vulnerability-assessment**: SE-001
- **#access-control**: SE-004, SE-006

### By Difficulty

- **#intermediate**: SE-005, SE-006
- **#advanced**: SE-001, SE-002, SE-003, SE-004
- **#expert**: SE-007

---

## 📊 Technology & Standards Coverage

| Standard/Technology | Prompts | Coverage |
|-----------------|---------|----------|
| OWASP Top 10 | SE-001, SE-006 | Application security |
| GDPR | SE-001, SE-004 | Data privacy |
| HIPAA | SE-004 | Healthcare compliance |
| PCI-DSS | SE-004 | Payment security |
| SOC 2 | SE-004 | Service organization controls |
| OAuth2/OIDC | SE-006 | Authentication |
| JWT | SE-006 | Token security |
| Vault | SE-003 | Secrets management |
| IAM | SE-002, SE-004 | Access control |
| Network Security | SE-005 | Network hardening |
| Infrastructure | SE-002 | System hardening |
| Penetration Testing | SE-007 | Security validation |

---

## 🔗 Cross-Role References

These prompts work well with:

| Other Role | Prompts | Integration Points |
|-----------|---------|-------------------|
| Backend Dev | PROMPT-BD-001, PROMPT-BD-006 | API security patterns |
| DevOps | PROMPT-DO-001, PROMPT-DO-006 | Infrastructure security |
| Architect | PROMPT-AR-002 | Architecture security |

---

## 🔐 Security Domains Covered

| Domain | Prompts | Coverage |
|--------|---------|----------|
| **Application Security** | SE-001, SE-006 | Code, APIs, OWASP |
| **Infrastructure Security** | SE-002, SE-005 | OS, network, cloud |
| **Secrets Management** | SE-003 | Credentials, keys, encryption |
| **Compliance & Governance** | SE-004 | Standards, policies, audit |
| **Network Security** | SE-005 | Segmentation, firewalls, VPN |
| **Testing & Validation** | SE-001, SE-007 | Audits, pen testing |

---

## 📞 Support & Feedback

- **Questions**: [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- **Report Issues**: [GitHub Issues](https://github.com/devendrapratapsingh/AI-prompt/issues)
- **Report Security Issues**: Please email security@example.com (don't use public issues)
- **Suggest Improvements**: [Feedback Form](https://example.com/feedback)

---

## ⚠️ Important Security Notes

- Always follow your organization's security policies
- Test changes in non-production environments first
- Keep secrets out of version control
- Rotate credentials regularly
- Follow principle of least privilege
- Document security decisions and changes
- Maintain audit trails
- Report vulnerabilities responsibly

---

**Last Updated**: December 2025  
**Maintained By**: Security Engineering Team  
**Next Review**: March 2026
