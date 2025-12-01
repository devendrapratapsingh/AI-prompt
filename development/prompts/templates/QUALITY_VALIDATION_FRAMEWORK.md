# Prompt Quality Validation Framework

This document outlines the quality assurance process and criteria for all prompts in the AI-prompt library.

---

## Quality Assurance Levels

### Level 1: Structural Completeness ✓
Verify that the prompt follows the standard template.

**Checklist**:
- [ ] All mandatory sections present (Purpose, Prerequisites, Questions, Task, Output)
- [ ] Prompt follows the PROMPT_TEMPLATE.md structure
- [ ] Metadata section is complete and accurate
- [ ] No placeholder text remaining
- [ ] Version number and dates are specified
- [ ] Author is identified

**Pass Criteria**: 100% of items checked

---

### Level 2: Clarity & Usability ✓
Verify that the prompt is clear and actionable.

**Checklist**:
- [ ] Purpose is clear in one read
- [ ] Initial questions are specific and unambiguous
- [ ] Task instructions are step-by-step and sequential
- [ ] Expected output format is clearly defined
- [ ] Examples provided are realistic and helpful
- [ ] Jargon is explained or assumed at appropriate level
- [ ] No contradictions or circular references
- [ ] Language is professional and consistent

**Pass Criteria**: ≥95% of items checked

---

### Level 3: Technical Accuracy ✓
Verify that the prompt is technically sound.

**Checklist**:
- [ ] Framework versions mentioned are current or appropriately versioned
- [ ] Code examples are syntactically correct
- [ ] Command-line examples actually work
- [ ] Configuration patterns follow best practices
- [ ] Architecture patterns are correctly represented
- [ ] Security recommendations are sound
- [ ] No deprecated tools or patterns recommended
- [ ] Technical terminology is accurate

**Pass Criteria**: 100% of items checked

**Validation Method**: 
- Execute prompt with sample inputs
- Verify outputs are correct and useful
- Test on clean environment

---

### Level 4: Completeness for Execution ✓
Verify that the prompt contains everything needed to complete the task.

**Checklist**:
- [ ] All prerequisites are listed
- [ ] All required tools/software are specified with versions
- [ ] All expected questions are asked upfront
- [ ] Output specification is complete and detailed
- [ ] Edge cases are addressed
- [ ] Troubleshooting covers common issues
- [ ] No missing context or assumptions
- [ ] Related prompts are referenced
- [ ] Sufficient examples for different scenarios

**Pass Criteria**: ≥90% of items checked

---

### Level 5: Security & Compliance ✓
Verify that the prompt doesn't introduce security or compliance issues.

**Checklist**:
- [ ] No hardcoded secrets/credentials
- [ ] Security best practices are followed
- [ ] Sensitive data handling is appropriate
- [ ] Access control is properly scoped
- [ ] Compliance requirements are met
- [ ] Encryption is used where needed
- [ ] No insecure patterns recommended
- [ ] Data privacy is respected
- [ ] Audit trail guidance is included
- [ ] Compliance certifications are correct

**Pass Criteria**: 100% of items checked

---

### Level 6: Multi-Role Relevance ✓
Verify that the prompt is appropriately tailored for its target role(s).

**Checklist**:
- [ ] Content is relevant to the stated role
- [ ] Prerequisite knowledge matches role level
- [ ] Output format suits the role's needs
- [ ] Alternative role variants referenced
- [ ] Cross-functional usage is clear
- [ ] Role-specific terminology is used correctly

**Pass Criteria**: ≥95% of items checked

---

### Level 7: Integration & Dependencies ✓
Verify that the prompt integrates well with the library.

**Checklist**:
- [ ] Prompt ID follows naming convention
- [ ] Tags are appropriate and complete
- [ ] Related prompts are correctly referenced
- [ ] Dependencies are listed accurately
- [ ] No circular dependencies
- [ ] Workflow sequence is logical
- [ ] Integration points are clear
- [ ] Can stand alone and within workflows

**Pass Criteria**: 100% of items checked

---

## Quality Scoring System

### Calculation
```
Overall Quality Score = 
  (L1*100 + L2*95 + L3*100 + L4*90 + L5*100 + L6*95 + L7*100) / 775 × 100
```

### Quality Levels

| Score Range | Level | Status | Action |
|-------------|-------|--------|--------|
| 95-100 | ⭐⭐⭐⭐⭐ | Approved | Ready for production use |
| 85-94 | ⭐⭐⭐⭐ | Review | Minor issues to address |
| 75-84 | ⭐⭐⭐ | Revision | Notable gaps to fill |
| 65-74 | ⭐⭐ | Rework | Significant changes needed |
| <65 | ⭐ | Rejected | Major overhaul required |

---

## Pre-Submission Checklist

Before submitting a prompt for review, ensure:

```markdown
- [ ] Prompt template followed exactly
- [ ] All sections completed (no TBD)
- [ ] Executed successfully at least once
- [ ] Output validated and correct
- [ ] All mandatory QA L1-L7 items checked
- [ ] No security/compliance violations
- [ ] Team lead reviewed for domain accuracy
- [ ] Examples are clear and realistic
- [ ] Troubleshooting covers ≥3 common issues
- [ ] Related prompts are correctly linked
- [ ] Documentation is production-ready
```

---

## Review Process Workflow

```
1. SUBMISSION
   ↓
2. AUTOMATED CHECKS
   - Structure validation
   - Template compliance
   - Link validation
   ↓
3. QUALITY SCORING (L1-L7)
   ↓
4. DOMAIN EXPERT REVIEW
   - Role alignment
   - Technical accuracy
   - Security/compliance
   ↓
5. DECISION
   ├─ APPROVED (≥95)
   ├─ REVIEW REQUIRED (85-94)
   ├─ REVISION NEEDED (75-84)
   └─ REJECTED (<75)
   ↓
6. PUBLISHED OR REWORK
```

---

## Quality Metrics Dashboard

### Tracked Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Average Quality Score | ≥95 | — |
| Approved Prompts | 100% | — |
| Review Turnaround Time | <48h | — |
| User Satisfaction | ≥4.5/5 | — |
| Prompt Usage Rate | ≥70% | — |
| Critical Issues Found | 0 | — |
| Security Issues | 0 | — |

---

## Common Quality Issues & How to Fix Them

### Issue 1: Ambiguous Initial Questions
**Problem**: Questions can be interpreted multiple ways  
**Fix**: Make questions specific, add examples, specify exact answer format  
**Example**:
```
❌ Bad: "What's your project type?"
✅ Good: "Is your project primarily [Java / Python]? (Answer exactly as shown)"
```

### Issue 2: Missing Prerequisites
**Problem**: Users attempt prompt without required knowledge/tools  
**Fix**: Explicitly list required tools, versions, and knowledge levels  
**Example**:
```
✅ Required Tools:
- Terraform ≥1.0
- AWS CLI ≥2.10
- Helm ≥3.10
```

### Issue 3: Unclear Output Format
**Problem**: Generated output doesn't match user expectations  
**Fix**: Provide detailed format spec and concrete examples  
**Example**:
```
✅ Expected Output Format:
- File: main.tf
- Format: HCL2 syntax
- Should include: provider block, variables, resources, outputs
- Should NOT include: hardcoded values
```

### Issue 4: Incomplete Error Handling
**Problem**: Users encounter error but no troubleshooting guide  
**Fix**: Add troubleshooting section with common issues and solutions  

### Issue 5: Security Gaps
**Problem**: Output contains or exposes sensitive data  
**Fix**: Add security section, use parameterization for secrets  

### Issue 6: Outdated Technology References
**Problem**: Prompt references deprecated versions/patterns  
**Fix**: Add version review to QA cycle, mark deprecated content  

---

## Role-Specific Quality Criteria

### Backend Developer Prompts
- [ ] Code is production-ready quality
- [ ] Best practices for framework are followed
- [ ] Error handling is comprehensive
- [ ] Testability is built in
- [ ] Performance implications noted

### DevOps Engineer Prompts
- [ ] Infrastructure templates are idempotent
- [ ] State management is clear
- [ ] Scaling considerations addressed
- [ ] Monitoring/alerting included
- [ ] Disaster recovery plan mentioned

### Security Engineer Prompts
- [ ] All security controls documented
- [ ] Threat models considered
- [ ] Compliance requirements met
- [ ] Audit trails implemented
- [ ] Penetration test considerations noted

### Architect Prompts
- [ ] Design patterns clearly explained
- [ ] Trade-offs documented
- [ ] Scalability/performance analyzed
- [ ] Technology choices justified
- [ ] Future evolution path considered

---

## Version Management & Changelog

### When to Increment Version

**Patch (x.x.1)**: Minor fixes, typos, clarifications
**Minor (x.1.0)**: New section, additional examples, improved clarity
**Major (1.0.0)**: Major overhaul, significant process change, framework upgrade

### Changelog Entry Format

```
Version [X.Y.Z] - YYYY-MM-DD
- [Summary of changes]
- [What was added/changed/removed]
- [Why this change was made]
- [Migration notes if applicable]
```

---

## Quarterly Review Cycle

Every prompt should be reviewed quarterly:

1. **Accuracy Check**: Are references still current?
2. **Usage Analysis**: How often is this prompt used?
3. **Feedback Review**: Any reported issues?
4. **Update Assessment**: Does it need updating?
5. **Quality Re-score**: Has quality changed?

---

## Feedback & Continuous Improvement

### User Feedback Integration
- Collect usage metrics
- Track satisfaction ratings
- Document issues reported
- Identify improvement patterns

### Improvement Pipeline
```
Feedback → Analysis → Update → Re-validation → Republish
```

---

## Quality Assurance Sign-Off Template

```
PROMPT QA SIGN-OFF
==================
Prompt ID: [ID]
Version: [X.Y.Z]
Reviewer: [Name]
Review Date: YYYY-MM-DD

Level 1 - Structural Completeness: [ ✓ / ✗ ]
Level 2 - Clarity & Usability: [ ✓ / ✗ ]
Level 3 - Technical Accuracy: [ ✓ / ✗ ]
Level 4 - Execution Completeness: [ ✓ / ✗ ]
Level 5 - Security & Compliance: [ ✓ / ✗ ]
Level 6 - Multi-Role Relevance: [ ✓ / ✗ ]
Level 7 - Integration & Dependencies: [ ✓ / ✗ ]

Overall Quality Score: [ ]%
Status: [APPROVED / REVIEW / REVISION / REJECTED]

Comments:
[Specific feedback and recommendations]

Next Review Date: YYYY-MM-DD
```

---

## Contact & Support

**QA Lead**: [Name] - [Email]  
**Report Issues**: [Link]  
**Suggest Improvements**: [Link]  
