#!/bin/bash

# GitLab CI/CD Validation Script
# This script validates your .gitlab-ci.yml configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS++))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
   ____ _ _   _           _       ____ ___   __     __    _ _     _       _             
  / ___(_) |_| |    __ _| |__   / ___|_ _|  \ \   / /_ _| (_) __| | __ _| |_ ___  _ __ 
 | |  _| | __| |   / _` | '_ \ | |    | |    \ \ / / _` | | |/ _` |/ _` | __/ _ \| '__|
 | |_| | | |_| |__| (_| | |_) || |___ | |     \ V / (_| | | | (_| | (_| | || (_) | |   
  \____|_|\__|_____\__,_|_.__/  \____|___|     \_/ \__,_|_|_|\__,_|\__,_|\__\___/|_|   
                                                                                          
  Validation Script v1.0
EOF
echo -e "${NC}"

# Check if .gitlab-ci.yml exists
check_file_exists() {
    log_info "Checking for .gitlab-ci.yml..."
    
    if [ ! -f ".gitlab-ci.yml" ]; then
        log_error ".gitlab-ci.yml not found in current directory"
        echo "Run this script from your project root directory."
        exit 1
    fi
    log_success ".gitlab-ci.yml found"
}

# Check YAML syntax
check_yaml_syntax() {
    log_info "Checking YAML syntax..."
    
    if command -v yamllint &> /dev/null; then
        if yamllint -d relaxed .gitlab-ci.yml > /dev/null 2>&1; then
            log_success "YAML syntax is valid"
        else
            log_error "YAML syntax errors detected"
            yamllint -d relaxed .gitlab-ci.yml
        fi
    elif command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))" > /dev/null 2>&1; then
            log_success "YAML syntax is valid (basic check)"
        else
            log_error "YAML syntax errors detected"
            python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))"
        fi
    else
        log_warn "No YAML validator found (install yamllint or python3-yaml)"
    fi
}

# Check stages definition
check_stages() {
    log_info "Checking stages definition..."
    
    if grep -q "^stages:" .gitlab-ci.yml; then
        log_success "Stages are defined"
        
        # List stages
        echo "  Defined stages:"
        grep -A 10 "^stages:" .gitlab-ci.yml | grep -E "^\s+-\s+" | sed 's/^/    /'
    else
        log_warn "No stages explicitly defined (using default: .pre, build, test, deploy, .post)"
    fi
}

# Check for required jobs
check_jobs() {
    log_info "Checking for jobs..."
    
    # Count jobs (lines ending with : that are not indented and not keywords)
    JOB_COUNT=$(grep -E "^[a-zA-Z0-9_-]+:" .gitlab-ci.yml | grep -v -E "^(stages|variables|workflow|default|include|cache|artifacts|services|before_script|after_script):" | wc -l)
    
    if [ "$JOB_COUNT" -gt 0 ]; then
        log_success "Found $JOB_COUNT job(s)"
    else
        log_error "No jobs found in pipeline"
    fi
}

# Check for script sections
check_scripts() {
    log_info "Checking for script sections..."
    
    if grep -q "script:" .gitlab-ci.yml; then
        log_success "Jobs have script sections"
    else
        log_error "No script sections found in jobs"
    fi
}

# Check for image definition
check_images() {
    log_info "Checking for Docker images..."
    
    if grep -q "image:" .gitlab-ci.yml; then
        log_success "Docker images are defined"
        
        # Check for specific versions
        if grep "image:" .gitlab-ci.yml | grep -q ":latest"; then
            log_warn "Using 'latest' tag is not recommended for reproducibility"
        fi
    else
        log_warn "No Docker images defined (will use runner's default)"
    fi
}

# Check for caching
check_cache() {
    log_info "Checking for cache configuration..."
    
    if grep -q "cache:" .gitlab-ci.yml; then
        log_success "Cache is configured"
        
        # Check for cache key
        if grep -A 5 "cache:" .gitlab-ci.yml | grep -q "key:"; then
            log_success "Cache key is defined"
        else
            log_warn "Cache key not defined (using default)"
        fi
    else
        log_warn "No cache configured (builds may be slower)"
    fi
}

# Check for artifacts
check_artifacts() {
    log_info "Checking for artifacts..."
    
    if grep -q "artifacts:" .gitlab-ci.yml; then
        log_success "Artifacts are configured"
        
        # Check for expiration
        if grep -A 10 "artifacts:" .gitlab-ci.yml | grep -q "expire_in:"; then
            log_success "Artifact expiration is set"
        else
            log_warn "Artifact expiration not set (will use GitLab default: 30 days)"
        fi
    else
        log_warn "No artifacts configured"
    fi
}

# Check for dependencies
check_dependencies() {
    log_info "Checking for job dependencies..."
    
    if grep -q "dependencies:" .gitlab-ci.yml || grep -q "needs:" .gitlab-ci.yml; then
        log_success "Job dependencies are defined"
    else
        log_warn "No explicit dependencies (jobs will download all artifacts from previous stages)"
    fi
}

# Check for environment configuration
check_environments() {
    log_info "Checking for environment configuration..."
    
    if grep -q "environment:" .gitlab-ci.yml; then
        log_success "Environments are configured"
    else
        log_warn "No environments defined"
    fi
}

# Check for only/except or rules
check_conditions() {
    log_info "Checking for execution conditions..."
    
    if grep -q "rules:" .gitlab-ci.yml; then
        log_success "Using 'rules' for job conditions"
    elif grep -q -E "(only:|except:)" .gitlab-ci.yml; then
        log_warn "Using 'only/except' (consider migrating to 'rules')"
    else
        log_warn "No execution conditions defined (jobs will run on all branches)"
    fi
}

# Check for secrets/variables
check_variables() {
    log_info "Checking for hardcoded secrets..."
    
    # Patterns that might indicate hardcoded secrets
    PATTERNS=(
        "password.*=.*['\"]"
        "token.*=.*['\"]"
        "api[_-]?key.*=.*['\"]"
        "secret.*=.*['\"]"
        "AWS_SECRET_ACCESS_KEY.*=.*['\"]"
        "PRIVATE_KEY.*=.*['\"]"
    )
    
    FOUND_SECRETS=0
    for pattern in "${PATTERNS[@]}"; do
        if grep -iE "$pattern" .gitlab-ci.yml > /dev/null 2>&1; then
            log_error "Possible hardcoded secret found matching pattern: $pattern"
            ((FOUND_SECRETS++))
        fi
    done
    
    if [ $FOUND_SECRETS -eq 0 ]; then
        log_success "No obvious hardcoded secrets found"
    fi
    
    # Check for variables section
    if grep -q "variables:" .gitlab-ci.yml; then
        log_success "Variables section defined"
    else
        log_warn "No variables section (consider using variables for configuration)"
    fi
}

# Check for security scanning
check_security_scanning() {
    log_info "Checking for security scanning..."
    
    SECURITY_FEATURES=0
    
    if grep -q "SAST" .gitlab-ci.yml || grep -q "sast:" .gitlab-ci.yml; then
        log_success "SAST (Static Application Security Testing) enabled"
        ((SECURITY_FEATURES++))
    fi
    
    if grep -q "dependency.*scanning" .gitlab-ci.yml || grep -q "Dependency-Scanning" .gitlab-ci.yml; then
        log_success "Dependency scanning enabled"
        ((SECURITY_FEATURES++))
    fi
    
    if grep -q "container.*scanning" .gitlab-ci.yml || grep -q "Container-Scanning" .gitlab-ci.yml; then
        log_success "Container scanning enabled"
        ((SECURITY_FEATURES++))
    fi
    
    if [ $SECURITY_FEATURES -eq 0 ]; then
        log_warn "No security scanning configured (consider adding SAST, dependency scanning)"
    fi
}

# Check for testing
check_testing() {
    log_info "Checking for testing configuration..."
    
    if grep -iE "(test|spec)" .gitlab-ci.yml > /dev/null; then
        log_success "Testing jobs found"
        
        # Check for coverage
        if grep -q "coverage:" .gitlab-ci.yml; then
            log_success "Coverage reporting configured"
        else
            log_warn "No coverage reporting (consider adding coverage regex)"
        fi
    else
        log_warn "No testing jobs found"
    fi
}

# Check for manual jobs
check_manual_jobs() {
    log_info "Checking for manual deployment jobs..."
    
    if grep -A 5 "environment:" .gitlab-ci.yml | grep -q "when: manual"; then
        log_success "Manual deployment jobs found (production safety)"
    else
        log_warn "No manual jobs found (consider manual approval for production)"
    fi
}

# Validate with GitLab API (if available)
validate_with_gitlab_api() {
    log_info "Validating with GitLab API..."
    
    if ! command -v curl &> /dev/null; then
        log_warn "curl not found, skipping API validation"
        return
    fi
    
    # Try to validate using GitLab's CI Lint API
    GITLAB_URL="${CI_SERVER_URL:-https://gitlab.com}"
    
    if [ -n "$CI_PROJECT_ID" ] && [ -n "$CI_JOB_TOKEN" ]; then
        RESPONSE=$(curl -s --header "JOB-TOKEN: $CI_JOB_TOKEN" \
            --header "Content-Type: application/json" \
            --data "{\"content\": $(cat .gitlab-ci.yml | jq -Rs .)}" \
            "$GITLAB_URL/api/v4/projects/$CI_PROJECT_ID/ci/lint" 2>/dev/null || echo "{}")
        
        if echo "$RESPONSE" | grep -q '"valid":true'; then
            log_success "GitLab API validation passed"
        elif echo "$RESPONSE" | grep -q '"valid":false'; then
            log_error "GitLab API validation failed"
            echo "$RESPONSE" | grep -o '"errors":\[.*\]' || echo "$RESPONSE"
        fi
    else
        log_warn "Not running in GitLab CI, skipping API validation"
        log_info "To validate online, visit: $GITLAB_URL/ci/lint"
    fi
}

# Check best practices
check_best_practices() {
    log_info "Checking best practices..."
    
    # Check for default section
    if grep -q "^default:" .gitlab-ci.yml; then
        log_success "Using 'default' section for common configuration"
    fi
    
    # Check for before_script optimization
    BEFORE_SCRIPT_COUNT=$(grep -c "before_script:" .gitlab-ci.yml || echo "0")
    if [ "$BEFORE_SCRIPT_COUNT" -gt 3 ]; then
        log_warn "Multiple before_script sections ($BEFORE_SCRIPT_COUNT). Consider using 'default' or templates"
    fi
    
    # Check for DRY principle (templates)
    if grep -q "^\." .gitlab-ci.yml; then
        log_success "Using templates/hidden jobs (DRY principle)"
    else
        log_warn "No templates found. Consider using hidden jobs (starting with .) for reusability"
    fi
    
    # Check file size
    FILE_SIZE=$(wc -l < .gitlab-ci.yml)
    if [ "$FILE_SIZE" -gt 500 ]; then
        log_warn "Large .gitlab-ci.yml file ($FILE_SIZE lines). Consider splitting with 'include'"
    fi
}

# Generate report
generate_report() {
    echo
    echo "=================================="
    echo "       VALIDATION REPORT"
    echo "=================================="
    echo
    log_success "Successful checks: $CHECKS"
    if [ $WARNINGS -gt 0 ]; then
        log_warn "Warnings: $WARNINGS"
    fi
    if [ $ERRORS -gt 0 ]; then
        log_error "Errors: $ERRORS"
    fi
    echo
    
    if [ $ERRORS -eq 0 ]; then
        log_success "Validation completed successfully!"
        echo
        log_info "Your .gitlab-ci.yml appears to be valid."
        log_info "Recommended next steps:"
        echo "  1. Review warnings and consider improvements"
        echo "  2. Test locally: gitlab-runner exec docker <job-name>"
        echo "  3. Commit and push to trigger pipeline"
        echo "  4. Monitor pipeline: Project → CI/CD → Pipelines"
        return 0
    else
        log_error "Validation found errors that need to be fixed"
        echo
        log_info "Please fix the errors above and run validation again."
        return 1
    fi
}

# Main validation function
main() {
    echo
    log_info "Starting GitLab CI/CD validation..."
    echo
    
    check_file_exists
    echo
    check_yaml_syntax
    echo
    check_stages
    echo
    check_jobs
    echo
    check_scripts
    echo
    check_images
    echo
    check_cache
    echo
    check_artifacts
    echo
    check_dependencies
    echo
    check_environments
    echo
    check_conditions
    echo
    check_variables
    echo
    check_security_scanning
    echo
    check_testing
    echo
    check_manual_jobs
    echo
    check_best_practices
    echo
    validate_with_gitlab_api
    echo
    
    generate_report
}

# Run main function
main
exit $?
