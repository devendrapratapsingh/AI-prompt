#!/bin/bash

# GitLab CI/CD Setup Script
# This script helps configure GitLab CI/CD for your project

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

# Banner
echo -e "${BLUE}"
cat << "EOF"
   ____ _ _   _           _       ____ ___    ____ ____  
  / ___(_) |_| |    __ _| |__   / ___|_ _|  / ___| __ \ 
 | |  _| | __| |   / _` | '_ \ | |    | |  | |   |  _ \ 
 | |_| | | |_| |__| (_| | |_) || |___ | |  | |___| |_) |
  \____|_|\__|_____\__,_|_.__/  \____|___|  \____|____/ 
                                                          
  Setup Script v1.0
EOF
echo -e "${NC}"

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v git &> /dev/null; then
        log_error "git is not installed"
        exit 1
    fi
    log_success "git is installed"
    
    if ! command -v curl &> /dev/null; then
        log_warn "curl is not installed (recommended)"
    else
        log_success "curl is installed"
    fi
    
    if ! command -v docker &> /dev/null; then
        log_warn "Docker not found (required for Docker executor)"
    else
        log_success "Docker is installed"
    fi
    
    if ! command -v gitlab-runner &> /dev/null; then
        log_warn "GitLab Runner not installed (needed for local testing)"
        log_info "Install from: https://docs.gitlab.com/runner/install/"
    else
        log_success "GitLab Runner is installed"
        gitlab-runner --version
    fi
}

# Detect project type
detect_project_type() {
    log_info "Detecting project type..."
    
    if [ -f "package.json" ]; then
        echo "nodejs"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ]; then
        echo "java-maven"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java-gradle"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "composer.json" ]; then
        echo "php"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

# Create .gitlab-ci.yml for Node.js
create_nodejs_pipeline() {
    cat > .gitlab-ci.yml << 'EOF'
image: node:18

stages:
  - build
  - test
  - deploy

variables:
  NODE_ENV: production

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/

build:
  stage: build
  before_script:
    - node --version
    - npm --version
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
      - node_modules/
    expire_in: 1 hour

test:unit:
  stage: test
  dependencies:
    - build
  script:
    - npm run test
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'

test:lint:
  stage: test
  script:
    - npm ci
    - npm run lint
  allow_failure: true

deploy:staging:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to staging"
    # Add your deployment commands here
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy:production:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to production"
    # Add your deployment commands here
  environment:
    name: production
    url: https://production.example.com
  only:
    - main
  when: manual
EOF
    log_success "Created Node.js pipeline configuration"
}

# Create .gitlab-ci.yml for Python
create_python_pipeline() {
    cat > .gitlab-ci.yml << 'EOF'
image: python:3.11

stages:
  - build
  - test
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .cache/pip
    - venv/

before_script:
  - python --version
  - pip install virtualenv
  - virtualenv venv
  - source venv/bin/activate

build:
  stage: build
  script:
    - pip install -r requirements.txt
    - echo "Build completed"
  artifacts:
    paths:
      - venv/
    expire_in: 1 hour

test:unit:
  stage: test
  dependencies:
    - build
  script:
    - pip install pytest pytest-cov
    - pytest tests/ --cov=app --cov-report=term --cov-report=xml
  coverage: '/(?i)total.*? (100(?:\.0+)?\%|[1-9]?\d(?:\.\d+)?\%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

test:lint:
  stage: test
  script:
    - pip install flake8 black
    - flake8 app/
    - black --check app/
  allow_failure: true

deploy:staging:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to staging"
    # Add your deployment commands here
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy:production:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to production"
    # Add your deployment commands here
  environment:
    name: production
    url: https://production.example.com
  only:
    - main
  when: manual
EOF
    log_success "Created Python pipeline configuration"
}

# Create .gitlab-ci.yml for Go
create_go_pipeline() {
    cat > .gitlab-ci.yml << 'EOF'
image: golang:1.21

stages:
  - build
  - test
  - deploy

variables:
  CGO_ENABLED: "0"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .go/pkg/mod/

before_script:
  - go version
  - mkdir -p .go
  - export GOPATH=$CI_PROJECT_DIR/.go

build:
  stage: build
  script:
    - go mod download
    - go build -v ./...
  artifacts:
    paths:
      - .go/
    expire_in: 1 hour

test:unit:
  stage: test
  dependencies:
    - build
  script:
    - go test -v -race -coverprofile=coverage.out ./...
    - go tool cover -func=coverage.out
  coverage: '/total:.*?(\d+\.\d+)%/'

test:lint:
  stage: test
  image: golangci/golangci-lint:latest
  script:
    - golangci-lint run
  allow_failure: true

deploy:staging:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to staging"
    # Add your deployment commands here
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy:production:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to production"
    # Add your deployment commands here
  environment:
    name: production
    url: https://production.example.com
  only:
    - main
  when: manual
EOF
    log_success "Created Go pipeline configuration"
}

# Create .gitlab-ci.yml for Java Maven
create_java_maven_pipeline() {
    cat > .gitlab-ci.yml << 'EOF'
image: maven:3.9-eclipse-temurin-17

stages:
  - build
  - test
  - deploy

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .m2/repository/

build:
  stage: build
  script:
    - mvn clean compile
  artifacts:
    paths:
      - target/
      - .m2/
    expire_in: 1 hour

test:unit:
  stage: test
  dependencies:
    - build
  script:
    - mvn test
    - mvn jacoco:report
  coverage: '/Total.*?([0-9]{1,3})%/'
  artifacts:
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml

test:lint:
  stage: test
  script:
    - mvn checkstyle:check
  allow_failure: true

deploy:staging:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to staging"
    # Add your deployment commands here
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy:production:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploy to production"
    # Add your deployment commands here
  environment:
    name: production
    url: https://production.example.com
  only:
    - main
  when: manual
EOF
    log_success "Created Java Maven pipeline configuration"
}

# Create generic pipeline
create_generic_pipeline() {
    cat > .gitlab-ci.yml << 'EOF'
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - echo "Add your build commands here"
    # Example: npm run build, go build, mvn package

test:
  stage: test
  script:
    - echo "Add your test commands here"
    # Example: npm test, go test, mvn test

deploy:
  stage: deploy
  script:
    - echo "Add your deployment commands here"
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
EOF
    log_success "Created generic pipeline configuration"
}

# Setup GitLab Runner locally
setup_runner() {
    if ! command -v gitlab-runner &> /dev/null; then
        log_warn "GitLab Runner not installed. Skipping runner setup."
        log_info "Install from: https://docs.gitlab.com/runner/install/"
        return
    fi
    
    log_info "GitLab Runner is installed"
    
    read -p "Do you want to register a new runner? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Starting runner registration..."
        log_info "You'll need:"
        log_info "  1. GitLab instance URL (e.g., https://gitlab.com)"
        log_info "  2. Registration token (from Project → Settings → CI/CD → Runners)"
        echo
        sudo gitlab-runner register
        log_success "Runner registered successfully"
    fi
}

# Create .gitignore
create_gitignore() {
    if [ ! -f ".gitignore" ]; then
        log_info "Creating .gitignore..."
        cat > .gitignore << 'EOF'
# CI/CD artifacts
.gitlab-ci-local/
coverage/
dist/
build/

# Logs
*.log
logs/

# Dependencies
node_modules/
.go/
.m2/
.cache/
venv/
EOF
        log_success "Created .gitignore"
    else
        log_info ".gitignore already exists"
    fi
}

# Create README section
add_readme_section() {
    log_info "Adding CI/CD section to README..."
    
    if [ ! -f "README.md" ]; then
        cat > README.md << 'EOF'
# Project

## CI/CD Pipeline

This project uses GitLab CI/CD for continuous integration and deployment.

### Pipeline Stages

1. **Build**: Compile and build the application
2. **Test**: Run unit tests and code quality checks
3. **Deploy**: Deploy to staging/production environments

### Running Locally

To test the pipeline locally:

```bash
gitlab-runner exec docker build
gitlab-runner exec docker test
```

### Configuration

Pipeline configuration is in `.gitlab-ci.yml`. Customize stages, jobs, and scripts as needed.

EOF
        log_success "Created README.md with CI/CD section"
    else
        log_info "README.md already exists. Please add CI/CD documentation manually."
    fi
}

# Main setup function
main() {
    echo
    log_info "Starting GitLab CI/CD setup..."
    echo
    
    check_requirements
    echo
    
    PROJECT_TYPE=$(detect_project_type)
    log_info "Detected project type: $PROJECT_TYPE"
    echo
    
    if [ -f ".gitlab-ci.yml" ]; then
        log_warn ".gitlab-ci.yml already exists"
        read -p "Overwrite existing .gitlab-ci.yml? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping pipeline creation"
            exit 0
        fi
    fi
    
    case $PROJECT_TYPE in
        nodejs)
            create_nodejs_pipeline
            ;;
        python)
            create_python_pipeline
            ;;
        go)
            create_go_pipeline
            ;;
        java-maven)
            create_java_maven_pipeline
            ;;
        *)
            log_warn "Unknown project type. Creating generic pipeline."
            create_generic_pipeline
            ;;
    esac
    
    echo
    create_gitignore
    echo
    add_readme_section
    echo
    setup_runner
    
    echo
    log_success "GitLab CI/CD setup complete!"
    echo
    log_info "Next steps:"
    echo "  1. Review and customize .gitlab-ci.yml"
    echo "  2. Set up CI/CD variables in GitLab: Settings → CI/CD → Variables"
    echo "  3. Commit and push changes: git add . && git commit -m 'Add CI/CD' && git push"
    echo "  4. View your pipeline: Project → CI/CD → Pipelines"
    echo
    log_info "For more information, visit: https://docs.gitlab.com/ee/ci/"
}

# Run main function
main
