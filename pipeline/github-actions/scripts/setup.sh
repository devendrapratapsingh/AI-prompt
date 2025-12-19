#!/bin/bash

# GitHub Actions Setup Script
# This script helps configure GitHub Actions for your project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v git &> /dev/null; then
        log_error "git is not installed"
        exit 1
    fi
    log_success "git is installed"
    
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI (gh) not found. Visit: https://cli.github.com"
    else
        log_success "GitHub CLI is installed"
    fi
}

# Initialize GitHub Actions directory structure
init_actions_directory() {
    log_info "Initializing GitHub Actions directory..."
    
    mkdir -p .github/workflows
    mkdir -p .github/actions
    mkdir -p .github/ISSUE_TEMPLATE
    
    log_success "Created .github directory structure"
}

# Create basic workflow
create_basic_workflow() {
    log_info "Creating basic CI workflow..."
    
    cat > .github/workflows/ci.yml << 'EOF'
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run build
        run: |
          echo "Add your build commands here"
          # npm run build
          # go build ./...
          # mvn clean package
EOF
    
    log_success "Created .github/workflows/ci.yml"
}

# Create security workflow
create_security_workflow() {
    log_info "Creating security scanning workflow..."
    
    cat > .github/workflows/security.yml << 'EOF'
name: Security Scan

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

permissions:
  contents: read
  security-events: write

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
EOF
    
    log_success "Created .github/workflows/security.yml"
}

# Create workflow validation script
create_workflow_validator() {
    log_info "Creating workflow validator..."
    
    cat > .github/scripts/validate-workflows.sh << 'EOF'
#!/bin/bash

# Validate all workflow files

WORKFLOWS=(.github/workflows/*.yml)
VALID=true

for workflow in "${WORKFLOWS[@]}"; do
    if ! yamllint "$workflow" > /dev/null 2>&1; then
        echo "❌ Invalid YAML: $workflow"
        VALID=false
    else
        echo "✓ Valid: $workflow"
    fi
done

if [ "$VALID" = false ]; then
    exit 1
fi
EOF
    
    chmod +x .github/scripts/validate-workflows.sh
    log_success "Created workflow validator script"
}

# Setup secret handling
setup_secrets() {
    log_info "Setting up secrets management..."
    
    cat > .env.example << 'EOF'
# GitHub Actions Secrets - Copy to .env and fill with real values
# DO NOT commit .env file to repository

# AWS Credentials
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1

# Docker Registry
DOCKER_USERNAME=
DOCKER_PASSWORD=

# APIs & Tokens
SLACK_WEBHOOK=
SONAR_TOKEN=
CODECOV_TOKEN=
NPM_TOKEN=
EOF
    
    cat > .github/workflows/.secrets-template.txt << 'EOF'
# Required Secrets for GitHub Actions

## AWS Secrets
- AWS_ACCESS_KEY_ID: AWS access key
- AWS_SECRET_ACCESS_KEY: AWS secret access key
- AWS_ACCOUNT_ID: AWS account ID

## Docker Secrets
- DOCKER_USERNAME: Docker registry username
- DOCKER_PASSWORD: Docker registry password

## Deployment Secrets
- DEPLOY_KEY: SSH private key for deployment
- DEPLOY_HOST: Deployment server hostname

## Notification Secrets
- SLACK_WEBHOOK: Slack webhook URL
- SLACK_CHANNEL: Slack channel for notifications

## Analysis Secrets
- SONAR_TOKEN: SonarQube token
- CODECOV_TOKEN: Codecov token

## Package Registry Secrets
- NPM_TOKEN: NPM registry token
- ARTIFACTORY_TOKEN: JFrog Artifactory token

Setup Instructions:
1. Go to Repository Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add each secret from above
4. For organization secrets, go to Organization Settings > Secrets and variables > Actions
EOF
    
    log_success "Created secrets template"
}

# Create GitHub issue templates
create_issue_templates() {
    log_info "Creating GitHub issue templates..."
    
    mkdir -p .github/ISSUE_TEMPLATE
    
    # Bug report template
    cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug Report
about: Create a bug report to help improve the project
title: "[BUG] "
labels: bug
---

## Description
Brief description of the bug.

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen?

## Actual Behavior
What actually happens?

## Environment
- **OS**: (e.g., macOS, Linux, Windows)
- **Version**: (e.g., 1.0.0)
- **Runner**: (e.g., ubuntu-latest)

## Logs
Paste relevant logs or error messages.
EOF
    
    log_success "Created issue templates"
}

# Create GitHub Actions best practices guide
create_best_practices_guide() {
    log_info "Creating best practices guide..."
    
    cat > .github/GITHUB_ACTIONS_GUIDE.md << 'EOF'
# GitHub Actions Best Practices

## 1. Security
- [ ] Use pinned action versions (e.g., `actions/checkout@v4`)
- [ ] Store secrets in Settings > Secrets and variables > Actions
- [ ] Use OIDC for cloud authentication
- [ ] Limit job permissions
- [ ] Never hardcode credentials

## 2. Performance
- [ ] Use caching for dependencies
- [ ] Parallelize jobs where possible
- [ ] Use matrix strategy for multiple configurations
- [ ] Use self-hosted runners for heavy workloads
- [ ] Upload artifacts with short retention periods

## 3. Reliability
- [ ] Add timeout-minutes to prevent hanging
- [ ] Use health checks for services
- [ ] Implement retry logic
- [ ] Use workflow_dispatch for manual runs
- [ ] Test workflows locally with act

## 4. Observability
- [ ] Add descriptive names to steps
- [ ] Include logging throughout workflows
- [ ] Upload artifacts and logs on failure
- [ ] Monitor workflow run times
- [ ] Set up slack notifications

## 5. Maintenance
- [ ] Keep action versions updated
- [ ] Use reusable workflows to avoid duplication
- [ ] Document complex workflows
- [ ] Review and clean up old workflows
- [ ] Use branch protection rules

## Testing Locally
```bash
# Install act
brew install act

# Run workflow locally
act -j build

# Run with specific OS
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:full-latest
```

## Common Patterns

### Conditional Deployment
```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### Matrix Testing
```yaml
strategy:
  matrix:
    node-version: [16.x, 18.x, 20.x]
```

### Docker Build
```yaml
- uses: docker/build-push-action@v5
```

### Upload Artifacts
```yaml
- uses: actions/upload-artifact@v4
```
EOF
    
    log_success "Created best practices guide"
}

# Initialize git hooks
setup_git_hooks() {
    log_info "Setting up git hooks..."
    
    mkdir -p .git/hooks
    
    cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
# Pre-push hook to validate workflows before pushing

echo "Validating workflows..."

if command -v yamllint &> /dev/null; then
    for workflow in .github/workflows/*.yml; do
        if ! yamllint "$workflow"; then
            echo "❌ Invalid workflow: $workflow"
            exit 1
        fi
    done
    echo "✓ All workflows are valid"
else
    echo "⚠ yamllint not installed, skipping validation"
fi
EOF
    
    chmod +x .git/hooks/pre-push
    log_success "Created git pre-push hook"
}

# Create documentation
create_documentation() {
    log_info "Creating documentation..."
    
    cat > GITHUB_ACTIONS.md << 'EOF'
# GitHub Actions Configuration

This project uses GitHub Actions for CI/CD automation.

## Workflows

### CI Pipeline (.github/workflows/ci.yml)
- Runs on: push to main/develop, pull requests
- Jobs: build, test, lint

### Security Scanning (.github/workflows/security.yml)
- Runs: weekly + on-demand
- Jobs: Trivy vulnerability scan, dependency check

## Setup

### 1. Repository Secrets
Add these to Settings > Secrets and variables > Actions:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKER_PASSWORD
SLACK_WEBHOOK
```

### 2. Branch Protection
Enable in Settings > Branches > Branch protection rules:
- Require status checks to pass
- Require code reviews
- Dismiss stale pull request approvals

### 3. Environment Protection
Configure in Settings > Environments:
- production: Require manual approval
- staging: Auto-approve

## Running Locally

Install act to test workflows locally:
```bash
brew install act
act -j build
```

## Monitoring

View workflow runs: https://github.com/YOUR_ORG/YOUR_REPO/actions

## Troubleshooting

**Workflow not triggering?**
- Check branch name matches conditions
- Verify YAML syntax in workflow editor
- Check commit in correct branch

**Secret not available?**
- Secrets are case-sensitive
- Reference as `${{ secrets.SECRET_NAME }}`
- Verify secret exists in Settings

**Out of disk space?**
- Remove unnecessary artifacts
- Clean Docker layers: `docker system prune`
- Check job logs for large files

## Resources

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Workflow Syntax](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- [Action Marketplace](https://github.com/marketplace?type=actions)
EOF
    
    log_success "Created GitHub Actions documentation"
}

# Print summary
print_summary() {
    echo ""
    log_success "Setup Complete!"
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo "  ✓ Directory structure created"
    echo "  ✓ CI workflow configured"
    echo "  ✓ Security workflow configured"
    echo "  ✓ Secrets template created"
    echo "  ✓ Issue templates created"
    echo "  ✓ Documentation created"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Review .github/workflows/ci.yml and add your build commands"
    echo "  2. Create secrets in Settings > Secrets and variables > Actions"
    echo "  3. Commit and push changes"
    echo "  4. View workflow runs in Actions tab"
    echo ""
    echo -e "${BLUE}Resources:${NC}"
    echo "  • Documentation: GITHUB_ACTIONS.md"
    echo "  • Best Practices: .github/GITHUB_ACTIONS_GUIDE.md"
    echo "  • Secrets: .github/workflows/.secrets-template.txt"
    echo ""
}

# Main execution
main() {
    log_info "GitHub Actions Setup Script"
    echo ""
    
    check_requirements
    init_actions_directory
    create_basic_workflow
    create_security_workflow
    create_workflow_validator
    setup_secrets
    create_issue_templates
    create_best_practices_guide
    setup_git_hooks
    create_documentation
    print_summary
}

main "$@"
