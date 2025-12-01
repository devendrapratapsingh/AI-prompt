# AI-Prompt Library - Complete Setup & Usage Guide

## 📚 Table of Contents

1. [Getting Started](#getting-started)
2. [Library Structure](#library-structure)
3. [Finding Prompts](#finding-prompts)
4. [Executing Prompts](#executing-prompts)
5. [Quality Standards](#quality-standards)
6. [Contributing](#contributing)
7. [FAQs](#faqs)

---

## Getting Started

### What is AI-Prompt?

AI-Prompt is a comprehensive library of production-grade AI prompts for software engineers. It provides:

- **Role-specific prompts** for Backend Developers, DevOps Engineers, Security Engineers, Architects, and Data Engineers
- **Task-focused prompts** for code generation, architecture design, security audits, infrastructure setup, etc.
- **Quality-assured content** with validation frameworks and best practices
- **Cross-functional workflows** combining multiple prompts for complex tasks

### Quick Start (5 minutes)

1. **Choose Your Role**: [Backend Developer](../by-role/backend-developer/INDEX.md) | [DevOps](../by-role/devops-engineer/INDEX.md) | [Security](../by-role/security-engineer/INDEX.md) | [Architect](../by-role/architect/INDEX.md) | [Data](../by-role/data-engineer/INDEX.md)

2. **Find a Prompt**: Browse the role-specific INDEX or use [PROMPT_DISCOVERY_GUIDE.md](../PROMPT_DISCOVERY_GUIDE.md)

3. **Read the Prompt**: Understand the purpose, prerequisites, and initial questions

4. **Execute**: Answer questions, follow steps, validate output using the quality checklist

5. **Integrate**: Use generated output in your project

---

## Library Structure

### Directory Organization

```
development/prompts/
├── PROMPT_DISCOVERY_GUIDE.md       ← Start here for navigation
├── by-role/                         ← Prompts by professional role
│   ├── backend-developer/
│   ├── devops-engineer/
│   ├── security-engineer/
│   ├── architect/
│   └── data-engineer/
├── by-technology/                   ← Prompts by technology (TBD)
├── by-use-case/                     ← Prompts by business need (TBD)
├── cross-functional/                ← Multi-role prompts (TBD)
└── templates/
    ├── PROMPT_TEMPLATE.md           ← Template all prompts follow
    └── QUALITY_VALIDATION_FRAMEWORK.md ← QA standards
```

### File Naming Convention

Prompts follow this naming pattern:

```
PROMPT-{ROLE}-{USECASE}-{NUMBER}-{title}.md

Example:
PROMPT-BD-001-spring-boot-microservice.md
PROMPT-DO-001-terraform-multi-cloud.md
PROMPT-SE-001-security-audit.md

Where:
- ROLE: BD (Backend Dev), DO (DevOps), SE (Security), AR (Architect), DE (Data)
- USECASE: 001, 002, etc. (sequential)
- title: URL-friendly, descriptive
```

---

## Finding Prompts

### Method 1: Interactive Decision Wizard (Recommended for New Users)

1. Open [PROMPT_DISCOVERY_GUIDE.md](../PROMPT_DISCOVERY_GUIDE.md#-interactive-decision-wizard)
2. Answer 4 questions:
   - What is your role?
   - What do you want to accomplish?
   - What technology stack?
   - What's your experience level?
3. Get personalized prompt recommendations

### Method 2: Browse by Role

**Direct Links**:
- [Backend Developers](../by-role/backend-developer/INDEX.md)
- [DevOps Engineers](../by-role/devops-engineer/INDEX.md)
- [Security Engineers](../by-role/security-engineer/INDEX.md)
- [Architects](../by-role/architect/INDEX.md)
- [Data Engineers](../by-role/data-engineer/INDEX.md)

Each role directory has an INDEX.md with all available prompts, descriptions, and recommendations.

### Method 3: Use the Technology × Role × Use Case Matrix

See [PROMPT_DISCOVERY_GUIDE.md#-technology--role--use-case-matrix](../PROMPT_DISCOVERY_GUIDE.md#-technology--role--use-case-matrix)

### Method 4: Tag-Based Search

See [PROMPT_DISCOVERY_GUIDE.md#-tag-based-filtering-system](../PROMPT_DISCOVERY_GUIDE.md#-tag-based-filtering-system)

Example tags:
- `#java` `#spring-boot` `#code-generation`
- `#terraform` `#infrastructure` `#aws`
- `#security` `#owasp` `#vault`

### Method 5: Search by Use Case

- **Building Something New**: Code Generation prompts
- **Designing Architecture**: Architecture prompts
- **Deploying Infrastructure**: Infrastructure Setup prompts
- **Securing Application**: Security Audit & Implementation prompts
- **Compliance**: Compliance Framework prompts

---

## Executing Prompts

### Before Starting

**Checklist**:

1. ✅ Have the right role-based prompt (not for another role)
2. ✅ Met all prerequisites and have required tools
3. ✅ Allocated time (see "Estimated Duration" in Quick Reference)
4. ✅ Gathered all required artifacts (source code, documentation, etc.)
5. ✅ Reviewed the examples to understand expected output
6. ✅ Prepared a clean workspace for output

### Step 1: Read the Prompt Header

**Quick Reference Section**:
- Understand the purpose
- Check difficulty level matches your skills
- Note estimated duration
- Verify technology stack
- Check dependencies/related prompts

**Purpose & Use Case Section**:
- Confirm you're using it at the right time
- Review anti-patterns ("When NOT to Use")
- Understand business value

### Step 2: Verify Prerequisites

**Prerequisites & Requirements Section**:
- ✅ Required knowledge level
- ✅ Required tools/software (versions)
- ✅ Input artifacts you need to gather
- ✅ System requirements

**If you don't meet prerequisites**:
- Review referenced documentation
- Take training/tutorials
- Install required tools
- Reach out for help

### Step 3: Answer Initial Questions

**Critical**: All initial questions must be answered completely

- Read each question carefully
- Provide specific, exact answers
- Include examples where helpful
- Don't skip questions
- Use exact formats specified

**Example**:
```
Question 1: Is the project Java or Python?
Answer: Exactly "Java" or "Python"
❌ WRONG: "mostly Java with some Kotlin"
✅ RIGHT: "Java"
```

### Step 4: Execute the Task Instructions

**Main Task Instructions Section**:
- Follow steps in order (they're sequential)
- Complete each step fully
- Validate step output before proceeding
- Reference examples for guidance
- Check that outputs match expectations

**Tips**:
- Take notes during execution
- Save intermediate outputs
- Stop if something doesn't match expectations
- Use "Troubleshooting Guide" if stuck

### Step 5: Validate Output Quality

**Quality Checklist Section**:
- Use the provided checklist
- Verify all required items present
- Check for placeholder text
- Confirm format matches specification
- No hardcoded values/secrets remaining

### Step 6: Integrate & Test

After prompt execution:

1. **Code**: Compile/run and fix any issues
2. **Infrastructure**: Plan and test in dev environment first
3. **Documentation**: Review for accuracy
4. **Security**: Check for vulnerabilities
5. **Version Control**: Commit to repository

---

## Quality Standards

### Understanding Quality Levels

All prompts are validated against 7 quality levels:

**Level 1: Structural Completeness** ✓
- Template compliance
- All sections present
- No placeholder text

**Level 2: Clarity & Usability** ✓
- Clear instructions
- Unambiguous questions
- Professional writing

**Level 3: Technical Accuracy** ✓
- Current best practices
- Correct code examples
- Valid configurations

**Level 4: Execution Completeness** ✓
- All prerequisites included
- Nothing missing
- All edge cases covered

**Level 5: Security & Compliance** ✓
- No sensitive data exposed
- Security best practices followed
- Compliance requirements met

**Level 6: Multi-Role Relevance** ✓
- Appropriate for target role
- Cross-functional use considered
- Alternative variants referenced

**Level 7: Integration & Dependencies** ✓
- Integrates with other prompts
- Workflow sequences clear
- Related prompts referenced

### Quality Scoring

```
Score Range | Level | Status | Use
95-100      | ⭐⭐⭐⭐⭐ | Approved | Production ready
85-94       | ⭐⭐⭐⭐  | Review | Minor improvements needed
75-84       | ⭐⭐⭐    | Revision | Notable gaps
65-74       | ⭐⭐     | Rework | Significant changes
<65         | ⭐       | Rejected | Major overhaul
```

All published prompts meet **≥95 quality** standard.

---

## Contributing

### How to Contribute

#### Option 1: Suggest Improvements

1. Open [GitHub Issue](https://github.com/devendrapratapsingh/AI-prompt/issues)
2. Provide specific feedback
3. Include examples where helpful

#### Option 2: Create New Prompt

1. Copy [PROMPT_TEMPLATE.md](../templates/PROMPT_TEMPLATE.md)
2. Create your prompt following the template
3. Test thoroughly
4. Validate using [QUALITY_VALIDATION_FRAMEWORK.md](../templates/QUALITY_VALIDATION_FRAMEWORK.md)
5. Submit pull request

#### Option 3: Report Bugs/Issues

1. Open [GitHub Issue](https://github.com/devendrapratapsingh/AI-prompt/issues)
2. Provide clear description
3. Include Prompt ID and steps to reproduce

---

## FAQs

### Q: How long does a prompt take to execute?

**A**: Check the "Estimated Duration" in each prompt's Quick Reference section. Typically:
- Beginner: 30-45 minutes
- Intermediate: 45-75 minutes
- Advanced: 75-120 minutes

### Q: What if I don't meet the prerequisites?

**A**: You have two options:
1. Build the required knowledge first (references provided)
2. Request a simpler variant in [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)

### Q: Can I use multiple prompts together?

**A**: **YES!** This is encouraged. See "Recommended Workflows" in each prompt's Related Prompts section and in [PROMPT_DISCOVERY_GUIDE.md](../PROMPT_DISCOVERY_GUIDE.md#-prompt-dependencies--workflows).

Example workflow:
```
1. PROMPT-AR-001 (Design)
   ↓
2. PROMPT-BD-001 (Code)
   ↓
3. PROMPT-SE-006 (Security)
   ↓
4. PROMPT-DO-003 (Deploy)
```

### Q: What if the output doesn't match my expectations?

**A**: Check the "Troubleshooting Guide" section in the prompt. Common issues:
- Incomplete/unclear answers to initial questions
- Missing prerequisites
- Wrong prompt for your use case
- Tool version incompatibilities

### Q: How often are prompts updated?

**A**: Prompts are reviewed quarterly and updated as needed when:
- Technology versions change
- Best practices evolve
- New compliance requirements emerge
- User feedback suggests improvements

### Q: Can I adapt a prompt for my specific needs?

**A**: **YES!** Prompts are meant to be starting points. You should:
1. Customize answers to initial questions
2. Adapt examples for your context
3. Modify code as needed for your patterns
4. Document your customizations

### Q: What if I find an error or security issue?

**A**: 
- **Non-security issue**: [Open GitHub Issue](https://github.com/devendrapratapsingh/AI-prompt/issues)
- **Security issue**: Email security@example.com (don't use public issues)

### Q: How do I know a prompt is right for me?

**A**: Use [PROMPT_DISCOVERY_GUIDE.md - Decision Wizard](../PROMPT_DISCOVERY_GUIDE.md#-interactive-decision-wizard) or check:
1. **Role**: Is this for your role?
2. **Use Case**: Does this match what you're trying to do?
3. **Technology**: Does this use your tech stack?
4. **Difficulty**: Is the level appropriate?
5. **Time**: Do you have enough time?

### Q: What formats are outputs provided in?

**A**: Depends on the prompt:
- **Code Generation**: Source code + markdown docs
- **Infrastructure**: IaC (Terraform, Ansible) + docs
- **Architecture**: Diagrams + markdown docs
- **Security**: Reports + code examples
- **Documentation**: Markdown or AsciiDoc

### Q: Can I use prompts commercially?

**A**: **YES!** Prompts are provided under MIT License. See [LICENSE](../../LICENSE) file.

### Q: How do I stay updated with new prompts?

**A**: 
- Star the repository on GitHub
- Watch for releases
- Subscribe to [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- Check [Changelog](../documentation/CHANGELOG.md) regularly

---

## Getting Help

### Resources

- **Documentation**: [README](../../README.md) and [PROMPT_DISCOVERY_GUIDE.md](../PROMPT_DISCOVERY_GUIDE.md)
- **Templates**: [Prompt Template](../templates/PROMPT_TEMPLATE.md) and [QA Framework](../templates/QUALITY_VALIDATION_FRAMEWORK.md)
- **Examples**: Each prompt has real-world examples
- **References**: Each prompt links to official documentation

### Contact & Support

- **Questions**: [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- **Issues**: [GitHub Issues](https://github.com/devendrapratapsingh/AI-prompt/issues)
- **Security Issues**: security@example.com
- **Feedback**: [Feedback Form](https://example.com/feedback)

### Community

- Share your experience with prompts
- Suggest improvements
- Report issues
- Contribute new prompts
- Help other users

---

## Next Steps

1. **First Time?** Start with [PROMPT_DISCOVERY_GUIDE.md](../PROMPT_DISCOVERY_GUIDE.md#-interactive-decision-wizard)

2. **Know Your Role?** Go directly to your role's INDEX:
   - [Backend Developer](../by-role/backend-developer/INDEX.md)
   - [DevOps Engineer](../by-role/devops-engineer/INDEX.md)
   - [Security Engineer](../by-role/security-engineer/INDEX.md)
   - [Architect](../by-role/architect/INDEX.md)
   - [Data Engineer](../by-role/data-engineer/INDEX.md)

3. **Ready to Execute?** Open a specific prompt and follow the steps

4. **Want to Contribute?** See [CONTRIBUTING.md](../../../CONTRIBUTING.md)

---

**Last Updated**: December 2025  
**Maintained By**: AI-Prompt Community  
**Questions?** [Ask on GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
