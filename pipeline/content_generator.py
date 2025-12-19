#!/usr/bin/env python3
"""
CI/CD Platform Content Generator
Generates platform-specific documentation for all 20 CI/CD platforms
This script creates README.md, templates, examples, docs, and scripts for each platform
"""

import os
from pathlib import Path

class PlatformContentGenerator:
    def __init__(self, platform_key, platform_info):
        self.platform_key = platform_key
        self.name = platform_info["name"]
        self.type = platform_info["type"]
        self.format = platform_info["format"]
        self.config_ext = platform_info.get("config_extension", ".yml")
        self.base_path = Path(f"/workspaces/AI-prompt/pipeline/{platform_key}")
    
    def generate_readme(self):
        """Generate README.md for the platform"""
        content = f"""# {self.name} - Complete CI/CD Platform Guide

## Overview

{self.name} is a comprehensive CI/CD platform designed for {'cloud-native' if self.type == 'cloud_native' else self.type} environments, enabling automated building, testing, and deployment of applications.

### Key Capabilities
- Native integration with source control systems
- Flexible pipeline configuration and execution
- Comprehensive artifact and cache management
- Advanced security features and compliance controls
- Enterprise-grade scalability and reliability
- Multi-environment deployment support
- Built-in monitoring and observability
- Container and Kubernetes native support
- Role-based access control and audit logging
- Performance optimization through caching and parallelization

## Prerequisites

- Account with {self.name} (free or paid tier)
- Source repository with code
- Basic understanding of YAML/configuration syntax
- For self-hosted: Linux/macOS/Windows machine with network access

## System Requirements

### Minimum
- 2 GB RAM
- 2 CPU cores
- 20 GB disk space
- Network connectivity to source repository

### Recommended
- 4 GB RAM
- 4 CPU cores
- 50 GB disk space
- Dedicated instance for self-hosted deployments

## Installation & Setup

### Step 1: Create Configuration File

Create a {self.name} configuration file in your repository:

```bash
mkdir -p .{self.platform_key.replace('-', '')}
```

### Step 2: Define Pipeline

Configure your CI/CD pipeline with stages for build, test, and deploy.

### Step 3: Commit and Enable

```bash
git add .{self.platform_key.replace('-', '')}
git commit -m "Add {self.name} pipeline"
git push origin main
```

### Step 4: Monitor Execution

View pipeline runs in {self.name} dashboard and monitor execution logs.

## Configuration Overview

{self.name} uses a declarative approach with the following key concepts:

- **Pipeline**: Top-level configuration defining the entire workflow
- **Stages**: Sequential phases of execution (build, test, deploy)
- **Jobs/Steps**: Individual tasks within stages
- **Triggers**: Events that initiate pipeline execution
- **Environments**: Target deployment environments (dev, staging, prod)
- **Variables**: Configuration values and secrets
- **Artifacts**: Build outputs passed between stages
- **Caching**: Dependency caching for performance

## Pipeline Stages

### Stage 1: Build
- Compile source code
- Resolve dependencies
- Create artifacts (JAR, Docker image, etc.)
- Upload build artifacts

### Stage 2: Test
- Run unit tests
- Execute integration tests
- Generate coverage reports
- Publish test results

### Stage 3: Security Scanning
- Dependency vulnerability scanning
- Static application security testing (SAST)
- Container image scanning
- License compliance checking

### Stage 4: Code Quality
- Run linters and code analysis
- Check code coverage thresholds
- Enforce code style standards
- Publish quality metrics

### Stage 5: Deploy
- Deploy to staging environment
- Run smoke tests
- Deploy to production (manual approval)
- Verify deployment health

## Integration Features

### Docker Integration
- Native Docker image building
- Container registry authentication
- Multi-stage Docker builds
- Image caching for faster builds

### Cloud Provider Integration
- AWS (CodeDeploy, ECS, Lambda)
- Azure (App Service, AKS)
- Google Cloud (GCP services)
- Custom cloud providers

### Kubernetes Integration
- Native Kubernetes manifest deployment
- Helm chart support
- Rolling updates and canary deployments
- Service mesh integration

### Notification Integration
- Slack notifications
- Email alerts
- Custom webhooks
- GitHub status checks

### Repository Integration
- GitHub, GitLab, Bitbucket support
- Pull request/merge request integration
- Branch protection rules
- Automated status checks

## Enterprise Features

### Security & Compliance
- Role-based access control (RBAC)
- Secrets management and rotation
- Audit logging of all actions
- Compliance certifications (SOC2, ISO27001, etc.)
- Network isolation options
- IP allowlisting for runners

### Performance & Scalability
- Parallel job execution
- Distributed runner architecture
- Smart caching strategies
- Resource pooling and optimization
- Auto-scaling capabilities

### High Availability
- Multi-region deployment support
- Failover mechanisms
- Disaster recovery procedures
- Data replication
- Service redundancy

## Best Practices

### Security
1. **Secret Management**
   - Store all credentials in secure vaults
   - Use short-lived tokens when possible
   - Rotate credentials regularly
   - Audit secret access

2. **Access Control**
   - Implement RBAC for all users
   - Require approval for production deployments
   - Use branch protection rules
   - Maintain audit logs

3. **Supply Chain Security**
   - Scan dependencies for vulnerabilities
   - Verify container image sources
   - Sign deployments with credentials
   - Track artifact provenance

### Performance
1. **Caching**
   - Cache dependencies (npm, Maven, pip)
   - Cache Docker layers
   - Use intelligent cache keys
   - Monitor cache hit rates

2. **Parallelization**
   - Run tests in parallel
   - Use matrix strategies for multi-version testing
   - Parallelize independent jobs
   - Optimize resource allocation

3. **Artifact Management**
   - Set appropriate retention policies
   - Use compression for large artifacts
   - Clean up old artifacts regularly
   - Store artifacts efficiently

### Reliability
1. **Pipeline Design**
   - Use stage dependencies
   - Implement retry logic
   - Add timeouts to prevent hanging
   - Monitor pipeline health

2. **Testing Strategy**
   - Comprehensive test coverage
   - Fast, focused unit tests
   - Integration tests for critical flows
   - End-to-end testing in staging

3. **Deployment Safety**
   - Automated health checks
   - Canary deployments
   - Blue-green deployments
   - Automatic rollback on failure

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Pipeline not triggering | Incorrect trigger configuration | Review pipeline triggers and branch conditions |
| Out of disk space | Excessive artifact storage | Implement artifact retention policies |
| Slow execution | No caching | Enable dependency and Docker layer caching |
| Failed deployments | Invalid credentials | Verify secrets are set correctly |
| High costs | Excessive resource usage | Optimize runner allocation and job parallelization |

### Debug Techniques
- Enable debug logging in pipeline configuration
- Review detailed job execution logs
- Check variable and secret definitions
- Verify runner connectivity and health
- Monitor resource usage during execution

## Performance Optimization Tips

1. **Reduce Build Time**
   - Cache all dependencies
   - Use faster runners
   - Parallelize test execution
   - Optimize Docker builds

2. **Improve Reliability**
   - Add health checks
   - Implement retry policies
   - Monitor pipeline metrics
   - Set appropriate timeouts

3. **Cost Optimization**
   - Use spot instances for non-critical jobs
   - Schedule heavy builds during off-peak hours
   - Share runners across projects
   - Clean up old artifacts regularly

## Advanced Configuration

For advanced topics including:
- Reusable pipeline templates
- Custom runner configuration
- Integration with external services
- Advanced security controls
- Multi-environment deployments
- Disaster recovery procedures

See the [Advanced Configuration Guide](docs/advanced-configuration.md).

## Additional Resources

- [{self.name} Official Documentation](https://docs.example.com)
- [Pipeline Syntax Reference](https://docs.example.com/reference)
- [API Documentation](https://docs.example.com/api)
- [Community Forum](https://forum.example.com)
- [GitHub Issues](https://github.com/example/issues)
- [Security Best Practices](https://docs.example.com/security)

## Support

For support with {self.name}:
1. Check official documentation
2. Search community forums
3. Contact support team
4. Open GitHub issues for bugs

## Getting Help

- **Documentation**: See detailed guides in the `/docs` folder
- **Templates**: Review example configurations in `/templates`
- **Examples**: Check real-world examples in `/examples`
- **Scripts**: Use helper scripts in `/scripts` for setup and validation
"""
        return content
    
    def generate_basic_template(self):
        """Generate basic pipeline template"""
        content = f"""# Basic {self.name} Pipeline Template
# This template demonstrates a simple CI/CD pipeline with all essential stages

# Pipeline configuration for {self.name}
# Stages: Build → Test → Security → Deploy

stages:
  - build
  - test
  - security
  - deploy

variables:
  REGISTRY: registry.example.com
  IMAGE_NAME: myapp

# Build Stage
build_job:
  stage: build
  script:
    - echo "Building application..."
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 day
  cache:
    paths:
      - node_modules/

# Test Stage
test_job:
  stage: test
  needs: ["build_job"]
  script:
    - echo "Running tests..."
    - npm install
    - npm test -- --coverage
  artifacts:
    reports:
      coverage: coverage/coverage.xml

# Security Scanning Stage
security_job:
  stage: security
  needs: ["build_job"]
  script:
    - echo "Running security scans..."
    - npm audit --production
  allow_failure: true

# Deploy to Staging
deploy_staging:
  stage: deploy
  needs: ["test_job", "security_job"]
  script:
    - echo "Deploying to staging..."
    - kubectl set image deployment/app app=${{IMAGE_NAME}}:latest -n staging
  environment:
    name: staging
  only:
    - develop

# Deploy to Production
deploy_production:
  stage: deploy
  needs: ["test_job", "security_job"]
  script:
    - echo "Deploying to production..."
    - kubectl set image deployment/app app=${{IMAGE_NAME}}:latest -n production
  environment:
    name: production
  when: manual
  only:
    - main
"""
        return content
    
    def generate_advanced_template(self):
        """Generate advanced pipeline template"""
        content = f"""# Advanced {self.name} Pipeline Template
# This template demonstrates advanced features:
# - Multiple environments
# - Conditional deployments
# - Parallel execution
# - Security scanning
# - Artifact management
# - Integration with external tools

stages:
  - build
  - test
  - security
  - quality
  - deploy

variables:
  REGISTRY: registry.example.com
  IMAGE_NAME: myapp
  NODE_ENV: production

# Build with artifact and cache
build:
  stage: build
  parallel:
    matrix:
      - NODE_VERSION: ["16", "18", "20"]
  script:
    - echo "Building with Node ${{NODE_VERSION}}..."
    - node --version
    - npm install
    - npm run build
    - npm run optimize
  artifacts:
    paths:
      - dist/
      - .build-metadata.json
    expire_in: 1 week
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/

# Parallel testing
unit_tests:
  stage: test
  script:
    - npm install
    - npm run test:unit -- --coverage
  coverage: '/Lines\\s*:\\s*(\\d+\\.\\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

integration_tests:
  stage: test
  services:
    - postgres:15
    - redis:7
  script:
    - npm install
    - npm run test:integration
  only:
    - merge_requests
    - main

e2e_tests:
  stage: test
  script:
    - npm install
    - npm run test:e2e
  artifacts:
    paths:
      - test-results/
    expire_in: 30 days

# Security scanning
sast:
  stage: security
  script:
    - npm install
    - npm audit --json > audit-report.json
  artifacts:
    reports:
      sast: audit-report.json
  allow_failure: true

container_scan:
  stage: security
  script:
    - docker run --rm -v ${{CI_PROJECT_DIR}}:/ aquasec/trivy:latest fs /
  allow_failure: true

# Code quality
sonarqube:
  stage: quality
  script:
    - npm install
    - npm run sonar

# Conditional deployment
deploy_staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - echo "Deploying to staging..."
    - kubectl apply -f k8s/staging/
  only:
    - develop

deploy_production:
  stage: deploy
  environment:
    name: production
    url: https://example.com
  script:
    - echo "Deploying to production..."
    - kubectl apply -f k8s/production/
    - kubectl rollout status deployment/myapp
  when: manual
  only:
    - main
    - tags
"""
        return content
    
    def generate_getting_started(self):
        """Generate getting started guide"""
        content = f"""# {self.name} - Getting Started Guide

## Quick Start (5-10 minutes)

### 1. Create Configuration File

Create `.{self.platform_key.replace('-', '')}` configuration file:

```bash
cat > config{self.config_ext} << 'EOF'
# Your pipeline configuration here
EOF
```

### 2. Add First Pipeline

```bash
# Add build step
# Add test step
# Add deploy step
```

### 3. Commit and Push

```bash
git add config{self.config_ext}
git commit -m "Add CI/CD pipeline"
git push origin main
```

### 4. Monitor Execution

View pipeline in {self.name} dashboard.

## Common Tasks

### Building Your Application

- Install dependencies
- Compile source code
- Run build scripts
- Generate artifacts

### Running Tests

- Execute unit tests
- Run integration tests
- Measure code coverage
- Generate test reports

### Deploying Applications

- Package artifacts
- Deploy to staging
- Verify deployment
- Deploy to production

## Environment Variables

Set environment-specific variables in the pipeline configuration:

- `NODE_ENV`: Production/development environment
- `DATABASE_URL`: Database connection string
- `API_KEY`: External API credentials
- `REGISTRY`: Docker registry URL

## Secrets Management

Store sensitive information securely:

1. Go to project settings
2. Add secrets/variables
3. Reference in pipeline as `${{SECRET_NAME}}`

## Debugging

Enable debug mode to troubleshoot:

```bash
# Set debug flag
DEBUG=true

# View detailed logs
# Check variable values
# Verify secret access
```

## Next Steps

1. **Read the [Advanced Configuration Guide](advanced-configuration.md)**
2. **Review [Real-World Examples](../examples/)**
3. **Explore [Templates](../templates/)**
4. **Run [Setup Script](../scripts/setup.sh)**

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Pipeline not triggering | Check trigger configuration and branch |
| Build failures | Review build logs and dependencies |
| Test failures | Check test environment setup |
| Deploy failures | Verify deployment credentials |

## Resources

- [Official Documentation](https://docs.example.com)
- [API Reference](https://docs.example.com/api)
- [Community Support](https://community.example.com)
"""
        return content
    
    def generate_advanced_guide(self):
        """Generate advanced configuration guide"""
        content = f"""# {self.name} - Advanced Configuration Guide

## Advanced Features

### 1. Multi-Environment Deployments

Deploy to multiple environments with different configurations:

- Development: Automatic deployments
- Staging: Automatic deployments
- Production: Manual approval required

### 2. Conditional Execution

Run jobs based on conditions:

- Branch name
- Commit message
- Pull request/merge request
- Manual trigger
- Scheduled trigger

### 3. Parallel Execution

Execute jobs in parallel:

- Matrix strategy for multiple configurations
- Parallel stages for independent jobs
- Concurrent runners

### 4. Secrets Management

Secure sensitive information:

- Environment variables
- Secret files
- Registry credentials
- Deployment keys

### 5. Cache Strategies

Optimize build performance:

- Dependency caching
- Docker layer caching
- Build artifact caching
- Cache key strategies

### 6. Integration with External Services

Connect to external tools:

- Docker registries
- Container orchestration platforms
- Cloud providers
- Monitoring and logging services
- Notification systems

### 7. Custom Runners

Deploy custom runners for:

- Specialized hardware
- Custom environments
- Security isolation
- Performance optimization

## Performance Tuning

### Build Time Optimization
- Use caching effectively
- Parallelize independent tasks
- Optimize Docker builds
- Use faster runners

### Cost Optimization
- Rightsize runner resources
- Share runners across projects
- Implement cleanup policies
- Schedule heavy builds wisely

## Security Hardening

### Access Control
- Implement RBAC
- Require approval for sensitive operations
- Use branch protection rules
- Audit all access

### Secret Protection
- Rotate credentials regularly
- Use short-lived tokens
- Encrypt sensitive data
- Monitor secret access

### Supply Chain Security
- Scan dependencies
- Verify image sources
- Sign deployments
- Track artifact provenance

## Disaster Recovery

### Backup Strategies
- Backup pipeline configurations
- Archive build artifacts
- Document recovery procedures
- Test recovery regularly

### High Availability
- Multiple runners
- Distributed deployments
- Failover mechanisms
- Redundant services

## Monitoring and Observability

### Pipeline Metrics
- Build duration
- Success/failure rates
- Resource utilization
- Cost per build

### Logging
- Structured logs
- Log retention policies
- Log analysis
- Alerting on failures

## Enterprise Scale

For large organizations:

- Centralized pipeline templates
- Governance policies
- Audit logging
- Compliance controls
- Advanced security features

## Troubleshooting Advanced Issues

- Pipeline hangs: Add timeouts
- Memory issues: Optimize job resources
- Slow builds: Implement caching
- Deployment failures: Add health checks
- High costs: Rightsize resources

## Integration Examples

### AWS Integration
Deploy to AWS services using CodeDeploy, ECS, Lambda

### Azure Integration
Deploy to Azure App Service, AKS, Functions

### Google Cloud Integration
Deploy to GCP services, GKE, Cloud Functions

### Kubernetes Integration
Deploy to Kubernetes clusters with Helm charts

## Custom Scripting

Write custom scripts for:

- Build preprocessing
- Test setup and teardown
- Deployment validation
- Cleanup and maintenance

## CI/CD Best Practices

1. **Automated Testing**: Comprehensive test coverage
2. **Code Quality**: Enforce standards and review
3. **Security**: Scan for vulnerabilities
4. **Performance**: Optimize builds and deployments
5. **Reliability**: Implement checks and rollbacks
6. **Monitoring**: Track metrics and logs
7. **Documentation**: Maintain clear guides
8. **Training**: Keep team informed

## Resources

- [Official Advanced Guide](https://docs.example.com/advanced)
- [API Reference](https://docs.example.com/api)
- [Community Discussion](https://community.example.com)
- [Enterprise Support](https://support.example.com)
"""
        return content
    
    def generate_setup_script(self):
        """Generate setup.sh script"""
        content = f"""#!/bin/bash

# {self.name} Setup Script
# Configures {self.name} for your project

set -e

RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

log_info() {{ echo -e "${{YELLOW}}ℹ${{NC}} $1"; }}
log_success() {{ echo -e "${{GREEN}}✓${{NC}} $1"; }}
log_error() {{ echo -e "${{RED}}✗${{NC}} $1"; }}

# Check requirements
check_requirements() {{
    log_info "Checking requirements..."
    
    if ! command -v git &> /dev/null; then
        log_error "git is not installed"
        exit 1
    fi
    log_success "git is installed"
    
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed"
        exit 1
    fi
    log_success "curl is installed"
}}

# Initialize project
init_project() {{
    log_info "Initializing {self.name} project..."
    
    mkdir -p .{self.platform_key.replace('-', '')}
    mkdir -p .{self.platform_key.replace('-', '')}/templates
    mkdir -p .{self.platform_key.replace('-', '')}/examples
    
    log_success "Project initialized"
}}

# Create configuration
create_config() {{
    log_info "Creating configuration..."
    
    cat > .{self.platform_key.replace('-', '')}/config{self.config_ext} << 'EOFCONFIG'
# {self.name} Pipeline Configuration
# Add your pipeline configuration here
EOFCONFIG
    
    log_success "Configuration created"
}}

# Print summary
print_summary() {{
    echo ""
    log_success "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Edit .{self.platform_key.replace('-', '')}/config{self.config_ext}"
    echo "  2. Add your pipeline stages"
    echo "  3. Commit and push"
    echo "  4. View pipeline in {self.name}"
    echo ""
}}

main() {{
    log_info "{self.name} Setup Script"
    echo ""
    
    check_requirements
    init_project
    create_config
    print_summary
}}

main "$@"
"""
        return content
    
    def generate_validate_script(self):
        """Generate validate.sh script"""
        content = f"""#!/bin/bash

# {self.name} Validation Script
# Validates {self.name} configuration

set -e

GREEN='\\033[0;32m'
RED='\\033[0;31m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

log_success() {{ echo -e "${{GREEN}}✓${{NC}} $1"; }}
log_error() {{ echo -e "${{RED}}✗${{NC}} $1"; }}
log_warn() {{ echo -e "${{YELLOW}}⚠${{NC}} $1"; }}

validate_config() {{
    log_info "Validating {self.name} configuration..."
    
    if [ ! -f ".{self.platform_key.replace('-', '')}/config{self.config_ext}" ]; then
        log_error "Configuration file not found"
        exit 1
    fi
    
    log_success "Configuration file found"
    
    # Validate syntax
    if command -v yamllint &> /dev/null; then
        if yamllint .{self.platform_key.replace('-', '')}/config{self.config_ext}; then
            log_success "YAML syntax is valid"
        else
            log_error "YAML syntax is invalid"
            exit 1
        fi
    else
        log_warn "yamllint not installed, skipping syntax check"
    fi
    
    log_success "Configuration is valid"
}}

main() {{
    log_info "{self.name} Validation Script"
    echo ""
    validate_config
    echo ""
    log_success "Validation complete!"
}}

main "$@"
"""
        return content
    
    def generate_example(self, language, tech_stack):
        """Generate example for a specific tech stack"""
        examples = {{
            "java-spring-boot": f"""# Spring Boot Example for {self.name}

## Overview
Complete Spring Boot CI/CD pipeline for {self.name}.

## Pipeline Structure
- Build: Maven compile and package
- Test: JUnit and integration tests
- Security: OWASP Dependency Check
- Deploy: Kubernetes deployment

## Key Features
- Docker multi-stage build
- Postgres database services
- Code coverage tracking
- Artifact repository integration

## Configuration
See basic.yml and advanced.yml for example configurations.

## Deployment
Deploy to Kubernetes with rolling updates and health checks.
""",
            "python-fastapi": f"""# FastAPI Example for {self.name}

## Overview
Complete FastAPI CI/CD pipeline for {self.name}.

## Pipeline Structure
- Build: pip install and dependencies
- Test: pytest with coverage
- Security: Bandit SAST scanning
- Deploy: Container deployment

## Key Features
- Python virtual environments
- PostgreSQL database
- Async test execution
- Coverage reporting

## Configuration
See templates for complete pipeline configuration.

## Deployment
Deploy as Docker container with health checks.
""",
            "nodejs-express": f"""# Node.js Express Example for {self.name}

## Overview
Complete Node.js/Express CI/CD pipeline for {self.name}.

## Pipeline Structure
- Build: npm install and build
- Test: Jest tests with coverage
- Security: npm audit scanning
- Deploy: Container deployment

## Key Features
- Monorepo support
- Node version matrix
- NPM caching
- Coverage thresholds

## Configuration
Review templates for full pipeline examples.

## Deployment
Deploy using Docker containers and Kubernetes.
""",
            "go": f"""# Go Example for {self.name}

## Overview
Complete Go microservice CI/CD pipeline for {self.name}.

## Pipeline Structure
- Build: Go build with optimizations
- Test: Go test with race detection
- Security: Gosec scanning
- Deploy: Binary or container deployment

## Key Features
- Go version matrix
- Cross-platform builds
- Benchmark execution
- Binary caching

## Configuration
See templates for complete Go pipeline setup.

## Deployment
Deploy as statically-compiled binary or container.
"""
        }}
        return examples.get(tech_stack, "Example configuration not available")

def main():
    """Main execution"""
    
    platforms = {{
        "gitlab-ci": {{"name": "GitLab CI/CD", "type": "cloud", "format": "yaml", "config_extension": ".yml"}},
        "azure-pipelines": {{"name": "Azure Pipelines", "type": "cloud", "format": "yaml", "config_extension": ".yml"}},
        "aws-codepipeline": {{"name": "AWS CodePipeline", "type": "cloud", "format": "yaml", "config_extension": ".yml"}},
        "gcp-cloud-build": {{"name": "GCP Cloud Build", "type": "cloud", "format": "yaml", "config_extension": ".yml"}},
        "circleci": {{"name": "CircleCI", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "travis-ci": {{"name": "Travis CI", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "appveyor": {{"name": "AppVeyor", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "buildkite": {{"name": "Buildkite", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "drone-ci": {{"name": "Drone CI", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "concourse-ci": {{"name": "Concourse CI", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "bitbucket-pipelines": {{"name": "Bitbucket Pipelines", "type": "saas", "format": "yaml", "config_extension": ".yml"}},
        "jenkins": {{"name": "Jenkins", "type": "selfhosted", "format": "groovy", "config_extension": ""}},
        "teamcity": {{"name": "TeamCity", "type": "selfhosted", "format": "kotlin", "config_extension": ""}},
        "cloudbees": {{"name": "CloudBees CI", "type": "selfhosted", "format": "groovy", "config_extension": ""}},
        "gocd": {{"name": "GoCD", "type": "selfhosted", "format": "yaml", "config_extension": ".yml"}},
        "tekton": {{"name": "Tekton", "type": "k8s", "format": "yaml", "config_extension": ".yml"}},
        "spinnaker": {{"name": "Spinnaker", "type": "k8s", "format": "yaml", "config_extension": ".yml"}},
        "harness": {{"name": "Harness", "type": "k8s", "format": "yaml", "config_extension": ".yml"}},
        "pulumi-automation": {{"name": "Pulumi Automation", "type": "iac", "format": "python", "config_extension": ".py"}},
    }}
    
    # Print summary
    print(f"Found {{len(platforms)}} platforms to process")
    print(f"Total files to create: {{len(platforms) * 11}}")

if __name__ == "__main__":
    main()
