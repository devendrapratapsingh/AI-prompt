# Prompt Template Standard

This is the standardized template that all prompts in this library must follow for consistency, maintainability, and quality assurance.

---

## [PROMPT_ID]

**Title**: [Clear, descriptive title - max 60 characters]

**Version**: 1.0  
**Last Updated**: YYYY-MM-DD  
**Author**: [Name]  
**Status**: [Draft / Review / Approved / Deprecated]

---

### 📋 Quick Reference

| Property | Value |
|----------|-------|
| **Role** | [Backend Developer / DevOps Engineer / Security Engineer / Architect / Data Engineer] |
| **Use Case** | [Code Generation / Architecture Analysis / Infrastructure Setup / Security Audit / Monitoring Setup / etc.] |
| **Technology Stack** | [Java, Spring Boot, Python, Terraform, Ansible, OpenShift, AWS, Azure, GCP, HashiCorp Vault, etc.] |
| **Difficulty Level** | [Beginner / Intermediate / Advanced / Expert] |
| **Output Format** | [Code / Documentation / IaC / Configuration / Diagram / Multiple] |
| **Documentation Format** | [Markdown / AsciiDoc / Both] |
| **Cloud Platforms** | [AWS / Azure / GCP / OpenShift / Multi-Cloud / On-Premise] |
| **Tags** | [comma-separated tags for filtering] |
| **Dependencies** | [References to other prompts if applicable] |
| **Estimated Duration** | [Time to execute prompt] |

---

### 🎯 Purpose & Use Case

**Primary Purpose**:  
[1-2 sentences explaining what this prompt does]

**When to Use**:
- [Use case 1]
- [Use case 2]
- [Use case 3]

**When NOT to Use**:
- [Anti-pattern 1]
- [Anti-pattern 2]

**Business Value**:
[Explain how this prompt delivers value to the organization]

---

### 📚 Prerequisites & Requirements

**Required Knowledge**:
- [Technical skill 1 with proficiency level]
- [Technical skill 2 with proficiency level]
- [Tool/Framework familiarity]

**Required Tools/Software**:
- [Tool 1 - version]
- [Tool 2 - version]
- [Environment requirements]

**Input Artifacts Needed**:
- [Project source code / Configuration files / Documentation / etc.]
- [Specific file formats or structures]

**System Requirements**:
- [Memory / Disk space / Network requirements]

---

### ❓ Initial Questions (Answer Before Proceeding)

**Question 1**: [First mandatory question - Answer must be exact/specific]
- Expected format: [Format specification]
- Example: [Concrete example]

**Question 2**: [Second mandatory question]
- Expected format: [Format specification]
- Example: [Concrete example]

**Question 3**: [Third mandatory question if applicable]
- Expected format: [Format specification]
- Example: [Concrete example]

> ⚠️ **CRITICAL**: Do not proceed with the main task until ALL questions above are answered clearly and completely.

---

### 🔧 Main Task Instructions

**Objective**: [Clear statement of what will be accomplished]

**Step-by-Step Instructions**:

1. **[Step 1 Title]**
   - [Detailed instruction]
   - [Sub-task if applicable]

2. **[Step 2 Title]**
   - [Detailed instruction]
   - [Sub-task if applicable]

3. **[Step 3 Title]**
   - [Detailed instruction]

[Continue for all steps...]

---

### 📤 Expected Output Format

**Primary Deliverables**:
- File 1: `[filename]` - [Description and format]
- File 2: `[filename]` - [Description and format]
- File 3: `[filename]` - [Description and format]

**Output Structure Example**:
```
project-root/
├── [output-artifact-1]
├── [output-artifact-2]
└── [output-artifact-3]
```

**Output Specifications**:
- Format: [Markdown / JSON / YAML / Code / etc.]
- Should include: [Required sections/elements]
- Documentation style: [Enterprise standard / Technical / Beginner-friendly]

---

### 📋 Quality Checklist for Output

Use this checklist to validate the generated output before considering the prompt execution complete:

- [ ] All required sections are present and complete
- [ ] Code examples are syntactically correct
- [ ] File paths and naming follow conventions
- [ ] Dependencies and prerequisites are clearly documented
- [ ] Configuration values are parameterized (not hardcoded)
- [ ] Security best practices are followed
- [ ] Error handling and validation are included
- [ ] Documentation is clear and follows standard format
- [ ] All placeholders have been replaced with actual values
- [ ] Output has been tested/validated where applicable

---

### 💡 Examples & Sample Outputs

**Example 1: [Scenario Description]**

**Input**:
```
[Example input values]
```

**Expected Output**:
```
[Example output/file content]
```

**Explanation**:
[Brief explanation of the example]

---

**Example 2: [Alternative Scenario]**

**Input**:
```
[Example input values]
```

**Expected Output**:
```
[Example output/file content]
```

---

### 🔗 Related Prompts & Dependencies

**Related Prompts**:
- [Prompt ID]: [Link to prompt] - [Relationship description]
- [Prompt ID]: [Link to prompt] - [Relationship description]

**Recommended Sequence** (if part of a workflow):
1. [Prompt 1] - [Why]
2. [Prompt 2] - [Why]
3. [This Prompt] - [Why]
4. [Prompt 3] - [Next step]

**Cross-Functional Integration**:
- Can be used by: [Roles that can benefit]
- Integrates with: [Other systems/workflows]
- Output consumed by: [Downstream processes]

---

### 🐛 Troubleshooting Guide

**Issue 1: [Common Problem Description]**
- **Symptom**: [What user observes]
- **Root Cause**: [Why it happens]
- **Solution**:
  1. [Step 1]
  2. [Step 2]
- **Prevention**: [How to avoid]

**Issue 2: [Another Common Problem]**
- **Symptom**: [What user observes]
- **Root Cause**: [Why it happens]
- **Solution**:
  1. [Step 1]
  2. [Step 2]

**Getting More Help**:
- Check: [Related documentation link]
- Reference: [External resource]
- Contact: [Support channel]

---

### 📝 Best Practices

1. **[Best Practice 1]**
   - [Explanation]
   - [Example]

2. **[Best Practice 2]**
   - [Explanation]
   - [Example]

3. **[Best Practice 3]**
   - [Explanation]

---

### ⚠️ Security & Compliance Considerations

**Security Aspects**:
- [Security consideration 1]
- [Security consideration 2]
- [Sensitive data handling]

**Compliance Requirements**:
- [GDPR / HIPAA / SOC 2 / PCI-DSS / etc.]
- [Industry-specific requirements]

**Sensitive Information**:
- [What NOT to commit to version control]
- [Where to store secrets]
- [Access control considerations]

---

### 📚 References & Documentation

**Official Documentation**:
- [Framework/Tool 1]: [Link]
- [Framework/Tool 2]: [Link]

**Industry Standards**:
- [Standard 1]: [Link]
- [Standard 2]: [Link]

**Related Articles**:
- [Article 1]: [Link]
- [Article 2]: [Link]

---

### 📊 Prompt Metadata

**Prompt ID**: PROMPT-ROLE-USECASE-001  
**Category**: [Primary Category]  
**Subcategory**: [Secondary Category]  
**Complexity Score**: [1-10]  
**Reusability Score**: [1-10]  
**Last Reviewed**: YYYY-MM-DD  
**Review Cycle**: [Every 3 months / As needed / etc.]  

---

### 📝 Version History & Changelog

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | YYYY-MM-DD | Initial release | [Name] |
| 1.1 | YYYY-MM-DD | [Change description] | [Name] |

---

### ✅ Quality Assurance Sign-Off

- **Prompt Accuracy**: [✓ / ✗] Verified against current best practices
- **Completeness**: [✓ / ✗] All required sections present
- **Clarity**: [✓ / ✗] Clear and understandable to target audience
- **Tested**: [✓ / ✗] Executed successfully with expected output
- **Security**: [✓ / ✗] No sensitive information exposed
- **Compliance**: [✓ / ✗] Follows organizational standards

**Approved By**: [Name], Date: YYYY-MM-DD  
**Last Validated**: YYYY-MM-DD  

---

### 📞 Support & Feedback

**Report Issues**: [Link to issue tracker]  
**Suggest Improvements**: [Link to feedback form]  
**Questions**: [Contact email or Slack channel]  

---

**Footer Note**: This prompt is part of the AI-prompt library. For navigation and discovery, please refer to the [Prompt Discovery Guide](../PROMPT_DISCOVERY_GUIDE.md).
