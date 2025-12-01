# Application Security Audit & Remediation

**Title**: Application Security Audit - OWASP Top 10, Code Review & Vulnerability Assessment

**Version**: 1.0  
**Last Updated**: 2025-12-01  
**Author**: Security Team  
**Status**: Approved

---

### 📋 Quick Reference

| Property | Value |
|----------|-------|
| **Prompt ID** | PROMPT-SE-001 |
| **Role** | Security Engineer, Application Security Architect, Code Reviewer |
| **Use Case** | Application Security Audit, Vulnerability Assessment |
| **Technology Stack** | OWASP Top 10, SCA Tools, SAST, Code Review, Java, Python, Node.js |
| **Difficulty Level** | Advanced |
| **Output Format** | Security Report + Remediation Code |
| **Documentation Format** | Markdown + Remediation Examples |
| **Cloud Platforms** | AWS, Azure, GCP, On-Premise, Multi-Cloud |
| **Tags** | #security #application-security #owasp #code-review #vulnerability #advanced #audit |
| **Dependencies** | PROMPT-SE-006, PROMPT-SE-004, PROMPT-SE-002 |
| **Estimated Duration** | 60-90 minutes |

---

### 🎯 Purpose & Use Case

**Primary Purpose**:  
Perform comprehensive security audit of application code against OWASP Top 10, identify vulnerabilities, assess risk levels, and provide prioritized remediation guidance with code examples. Includes security code review, vulnerability assessment, and remediation recommendations.

**When to Use**:
- Pre-production security assessment
- Regular security audits and compliance checks
- Before major releases or deployments
- Post-incident security improvements
- Security training and awareness
- Third-party security assessment

**When NOT to Use**:
- Penetration testing (use PROMPT-SE-007 instead)
- Real-time attack response (use incident response procedures)
- Infrastructure security review (use PROMPT-SE-002)
- Network security assessment (use network security audit)

**Business Value**:
- Identifies and reduces critical security vulnerabilities
- Reduces breach risk by 60-70%
- Ensures compliance with security standards
- Protects customer data and brand reputation
- Reduces remediation costs vs. post-breach fixes
- Demonstrates security awareness to stakeholders

---

### 📚 Prerequisites & Requirements

**Required Knowledge**:
- OWASP Top 10 vulnerabilities (Intermediate level)
- Application security concepts (Intermediate level)
- Code review and static analysis (Intermediate level)
- Programming language(s) used in application (Intermediate level)
- Security best practices (Intermediate level)
- Compliance requirements (Basic level)

**Required Tools/Software**:
- SAST Tools: SonarQube, Checkmarx, Fortify, or open-source (FindBugs, Bandit)
- OWASP ZAP or Burp Suite (for dynamic testing)
- Dependency scanning: OWASP Dependency-Check, Snyk, WhiteSource
- Code review tools: GitHub, GitLab, Bitbucket
- IDE with security plugins
- Terminal/command-line access
- Access to application source code and build system

**Input Artifacts Needed**:
- Complete application source code
- Build configuration (pom.xml, build.gradle, package.json, requirements.txt)
- Deployment configuration and secrets management setup
- API documentation and endpoint specifications
- Database schema and access patterns
- External dependencies and third-party library list
- Existing security policies and compliance requirements

**System Requirements**:
- 4GB+ RAM for SAST tools
- 2GB+ disk space for dependencies and scan results
- Network access to vulnerability databases
- Time allocation for thorough analysis (not a quick scan)

---

### ❓ Initial Questions (Answer Before Proceeding)

**Question 1**: What is the primary programming language(s) of the application?
- Expected format: One or more of: "Java", "Python", "JavaScript/Node.js", "C#/.NET", "Go", "Rust", "Other"
- Example: "Java and Python"

**Question 2**: What is the application type and scope?
- Expected format: One of: "Web Application", "REST API", "Mobile Backend", "Microservices", "CLI Tool", "Library/SDK", "Other"
- Example: "REST API Microservices"

**Question 3**: What are the compliance requirements?
- Expected format: List from: "OWASP Top 10", "GDPR", "HIPAA", "PCI-DSS", "SOC 2", "ISO 27001", "None (basic security)"
- Example: "OWASP Top 10, GDPR, PCI-DSS"

**Question 4**: What is the scope of this security audit?
- Expected format: One of: "Full Codebase", "Critical Components Only", "Specific Module", "API Security Only", "Data Handling Only"
- Example: "API Security Only"

**Question 5**: What is the desired output format?
- Expected format: One of: "Executive Report", "Detailed Technical Report", "Remediation Code Examples", "All of the Above"
- Example: "All of the Above"

> ⚠️ **CRITICAL**: Do not proceed with the main task until ALL questions above are answered clearly and completely.

---

### 🔧 Main Task Instructions

**Objective**: Perform comprehensive application security audit, identify vulnerabilities mapped to OWASP Top 10, assess risk levels, and provide prioritized remediation with code examples.

**Step-by-Step Instructions**:

1. **Environment Setup & Preparation**
   - Set up SAST tools (SonarQube, Checkmarx, or open-source equivalent)
   - Configure dependency scanning tools
   - Prepare application for scanning (clean build, resolved dependencies)
   - Document application architecture and data flows
   - Identify critical components and sensitive data

2. **Static Application Security Testing (SAST)**
   - Run SAST tool against entire codebase
   - Configure rules for language-specific vulnerabilities
   - Suppress false positives with justification
   - Categorize findings by OWASP Top 10 mapping
   - Document code locations and issue severity

3. **Dependency Scanning & Supply Chain Security**
   - Scan all dependencies for known vulnerabilities (CVE)
   - Identify outdated or unsupported libraries
   - Check for license compliance issues
   - Document direct and transitive dependencies
   - Identify high-risk dependencies

4. **OWASP Top 10 Vulnerability Assessment**
   
   **A1: Broken Access Control**
   - Review authentication and authorization logic
   - Check for role-based access control (RBAC) implementation
   - Verify function-level access control
   - Assess privilege escalation risks
   
   **A2: Cryptographic Failures**
   - Review data encryption (in transit and at rest)
   - Check certificate management and validation
   - Assess password hashing and salting
   - Identify exposed sensitive data
   
   **A3: Injection**
   - Check for SQL injection vulnerabilities
   - Assess command injection risks
   - Review template injection patterns
   - Check LDAP/NoSQL injection risks
   
   **A4: Insecure Design**
   - Review threat modeling and security requirements
   - Assess authorization at each layer
   - Check rate limiting and resource limits
   - Review error handling and logging
   
   **A5: Security Misconfiguration**
   - Check default credentials and settings
   - Review security headers (CSP, HSTS, X-Frame-Options)
   - Assess verbose error messages
   - Check unnecessary features/services enabled
   
   **A6: Vulnerable & Outdated Components**
   - Identify outdated libraries and frameworks
   - Check for known vulnerabilities in dependencies
   - Assess update feasibility and compatibility
   
   **A7: Authentication Failures**
   - Review credential validation mechanisms
   - Check password policies and storage
   - Assess multi-factor authentication implementation
   - Review session management
   
   **A8: Software & Data Integrity Failures**
   - Check for secure software updates
   - Assess CI/CD pipeline security
   - Review dependency verification
   - Check artifact integrity
   
   **A9: Logging & Monitoring Failures**
   - Review logging completeness
   - Check for sensitive data in logs
   - Assess security event alerting
   - Review audit trail implementation
   
   **A10: SSRF/Security Request Forgery**
   - Check server-side request forgery prevention
   - Assess CORS configuration
   - Review external API calls validation
   - Check webhook implementation security

5. **Code Review for Security Patterns**
   - Manual review of critical security-sensitive code
   - Check for hardcoded secrets/credentials
   - Review exception handling and error responses
   - Assess input validation and sanitization
   - Check for insecure deserialization

6. **Data Flow & Sensitive Data Analysis**
   - Map all sensitive data flows (PII, payment data, etc.)
   - Identify data at rest and in transit
   - Assess encryption coverage
   - Review data retention and purging
   - Check compliance with data protection regulations

7. **API Security Assessment**
   - Review authentication mechanisms (JWT, OAuth2, API Keys)
   - Check authorization policies
   - Assess rate limiting and throttling
   - Review request validation and size limits
   - Check response data leakage

8. **Vulnerability Risk Assessment**
   - Calculate CVSS scores for identified vulnerabilities
   - Assign risk levels (Critical, High, Medium, Low)
   - Prioritize by exploitability and impact
   - Estimate remediation effort
   - Create remediation timeline

9. **Remediation Code Generation**
   - Provide secure code examples for each vulnerability
   - Document fixes with before/after comparison
   - Include configuration changes needed
   - Create implementation checklists
   - Provide testing guidance for each fix

10. **Security Testing Recommendations**
    - Unit tests for security-sensitive components
    - Integration tests for authentication/authorization
    - DAST (Dynamic Application Security Testing) plan
    - Penetration testing scope and approach
    - Security acceptance criteria

11. **Report Generation**
    - Executive summary with key findings
    - Detailed vulnerability descriptions
    - Risk assessment and prioritization
    - Remediation roadmap with timelines
    - Compliance mapping (OWASP, GDPR, HIPAA, etc.)
    - Metrics and trends
    - Recommendations for continuous improvement

---

### 📤 Expected Output Format

**Primary Deliverables**:
- File 1: `SECURITY_AUDIT_REPORT.md` - Comprehensive security audit report
- File 2: `VULNERABILITY_FINDINGS.xlsx/csv` - Detailed findings spreadsheet
- File 3: `OWASP_MAPPING.md` - OWASP Top 10 mapping and findings
- File 4: `REMEDIATION_GUIDE.md` - Remediation roadmap and actions
- File 5: `CODE_EXAMPLES/` - Secure code examples for each vulnerability type
- File 6: `COMPLIANCE_MAPPING.md` - Mapping to compliance requirements (GDPR, HIPAA, etc.)
- File 7: `SAST_SCAN_RESULTS.html/xml` - Tool output and detailed findings
- File 8: `DEPENDENCIES_AUDIT.md` - Dependency scan results and risk assessment

**Output Structure Example**:
```
security-audit/
├── SECURITY_AUDIT_REPORT.md
├── EXECUTIVE_SUMMARY.md
├── VULNERABILITY_FINDINGS.csv
├── OWASP_MAPPING.md
├── REMEDIATION_GUIDE.md
├── REMEDIATION_TIMELINE.md
├── COMPLIANCE_MAPPING.md
├── CODE_EXAMPLES/
│   ├── A1_BROKEN_ACCESS_CONTROL/
│   │   ├── vulnerable_code.java
│   │   ├── secure_code.java
│   │   ├── explanation.md
│   │   └── unit_test_example.java
│   ├── A2_CRYPTOGRAPHIC_FAILURES/
│   │   ├── vulnerable_code.java
│   │   ├── secure_code.java
│   │   └── explanation.md
│   ├── A3_INJECTION/
│   │   ├── sql_injection_example.md
│   │   ├── secure_query.java
│   │   └── parameterized_example.md
│   └── [other OWASP categories...]
├── SAST_RESULTS/
│   ├── sonarqube_report.html
│   ├── dependency_check_report.html
│   └── detailed_findings.xml
├── DEPENDENCY_AUDIT/
│   ├── DEPENDENCIES.md
│   ├── VULNERABLE_DEPENDENCIES.csv
│   └── CVE_DETAILS.md
└── TOOLS_CONFIGURATION/
    ├── sonarqube-config.properties
    ├── dependency-check-config.xml
    └── setup_instructions.md
```

**Output Specifications**:
- Format: Markdown reports + CSV findings + Code examples
- Should include: Vulnerability details, risk assessment, remediation code, testing approach
- Code examples: Language-specific and production-ready
- Report: Actionable and prioritized

---

### 📋 Quality Checklist for Output

- [ ] All vulnerabilities mapped to OWASP Top 10
- [ ] CVSS scores assigned to each vulnerability
- [ ] Risk levels (Critical, High, Medium, Low) properly assessed
- [ ] Remediation code examples provided for all vulnerability types
- [ ] Before/after comparison showing secure coding practices
- [ ] Dependencies scanned for known vulnerabilities (CVE)
- [ ] Sensitive data flows identified and documented
- [ ] Authentication/authorization mechanisms reviewed
- [ ] API security assessment completed
- [ ] Compliance requirements addressed (GDPR, HIPAA, PCI-DSS, etc.)
- [ ] False positives identified and suppressed
- [ ] Testing recommendations provided
- [ ] Remediation timeline and effort estimates included
- [ ] Executive summary for non-technical stakeholders
- [ ] Actionable remediation roadmap created

---

### 💡 Examples & Sample Outputs

**Example 1: REST API Microservice Audit**

**Input**:
```
Language: Java
Type: REST API Microservice
Compliance: OWASP Top 10, GDPR
Scope: Full Codebase
Output: All (Executive Report, Technical Report, Remediation)
```

**Expected Findings** (sample):
- A1: Missing authorization checks on update endpoints
- A2: Sensitive data logged in plain text
- A3: SQL injection in search endpoint (parameterized queries missing)
- A5: Missing security headers (CSP, HSTS)
- A6: Outdated Spring Boot library with known vulnerabilities
- A7: Weak password hashing (MD5 instead of bcrypt)
- A9: Insufficient logging of security events

**Remediation Examples**:
```java
// A1: Add authorization check
@PreAuthorize("hasAnyRole('ADMIN', 'OWNER') and #ownerId == authentication.principal.id")
@PutMapping("/orders/{id}")
public OrderDTO updateOrder(@PathVariable Long id, @RequestBody OrderDTO order) { ... }

// A2: Remove sensitive data from logs
logger.info("User login attempt for: {}", userId); // Secure
// NOT: logger.info("User login with password: {}", password); // INSECURE

// A3: Use parameterized queries (Spring Data does this automatically)
@Query("SELECT o FROM Order o WHERE o.customerId = ?1")
List<Order> findByCustomerId(Long customerId); // Secure
```

---

**Example 2: Python Web Application Audit**

**Input**:
```
Language: Python (FastAPI)
Type: Web Application
Compliance: OWASP Top 10, PCI-DSS
Scope: API Security Only
Output: Technical Report + Remediation
```

**Expected Findings**:
- A2: Passwords stored without hashing
- A3: SQLAlchemy queries vulnerable to SQL injection
- A5: Missing CORS configuration
- A7: Session management issues
- A9: No security logging

---

### 🔗 Related Prompts & Dependencies

**Related Prompts**:
- **PROMPT-SE-006**: API Security Implementation - Use for additional security patterns
- **PROMPT-SE-004**: Security Compliance Framework - Use for compliance mapping
- **PROMPT-SE-002**: Infrastructure Hardening - Use for environment security
- **PROMPT-SE-007**: Penetration Testing Guide - Use for dynamic security testing

**Recommended Sequence**:
1. **PROMPT-SE-001** - Perform security audit (this prompt)
2. **PROMPT-SE-006** - Implement API security enhancements
3. **PROMPT-SE-002** - Harden infrastructure
4. **PROMPT-SE-004** - Ensure compliance
5. **PROMPT-SE-007** - Conduct penetration testing

---

### 🐛 Troubleshooting Guide

**Issue 1: High false positive rate from SAST tools**
- **Symptom**: 100+ vulnerabilities but many are false positives
- **Root Cause**: Tool not properly configured for codebase patterns
- **Solution**:
  1. Review each finding manually
  2. Understand tool's false positive patterns
  3. Create suppress rules for confirmed false positives
  4. Document suppression reasoning
  5. Adjust tool rules/profiles
- **Prevention**: Start with default configuration, then tune over time

**Issue 2: Can't find vulnerability location in code**
- **Symptom**: SAST report mentions vulnerability but can't locate it
- **Root Cause**: Dynamic code generation, reflection, or complex call chains
- **Solution**:
  1. Check SAST tool's detailed findings for exact file/line
  2. Review full call stack provided by tool
  3. Perform manual code review of related files
  4. Check generated code and build artifacts
- **Prevention**: Manual code review for complex patterns

---

### 📝 Best Practices

1. **Holistic Assessment**
   - Combine SAST, DAST, and manual code review
   - Don't rely on tools alone
   - Include architecture and design review

2. **Prioritization**
   - Focus on critical and high-risk vulnerabilities first
   - Consider exploitability and impact
   - Balance quick wins with major refactoring

3. **Continuous Security**
   - Integrate security into CI/CD pipeline
   - Regular security audits (quarterly or per release)
   - Security training for development team

---

### ⚠️ Security & Compliance Considerations

**Security Aspects**:
- Review all authentication and authorization mechanisms
- Assess cryptographic implementations
- Check data protection and privacy controls
- Evaluate API security and rate limiting

**Compliance Requirements**:
- Map findings to GDPR, HIPAA, PCI-DSS requirements
- Document compliance evidence
- Track remediation of compliance violations

---

### 📊 Prompt Metadata

**Prompt ID**: PROMPT-SE-001  
**Category**: Security Engineering  
**Subcategory**: Application Security Audit  
**Complexity Score**: 9/10  
**Reusability Score**: 8/10  
**Last Reviewed**: 2025-12-01  
**Review Cycle**: Every 3 months  

---

### ✅ Quality Assurance Sign-Off

- **Prompt Accuracy**: ✓ Verified against OWASP Top 10 2021
- **Completeness**: ✓ All required sections present
- **Clarity**: ✓ Clear for advanced security engineers
- **Tested**: ✓ Executed on multiple codebases
- **Security**: ✓ Follows security best practices
- **Compliance**: ✓ Follows organizational standards

**Approved By**: Security Team, Date: 2025-12-01  
**Last Validated**: 2025-12-01  

---

**Footer Note**: This prompt is part of the AI-prompt library. For navigation and discovery, refer to [PROMPT_DISCOVERY_GUIDE.md](../../PROMPT_DISCOVERY_GUIDE.md).
