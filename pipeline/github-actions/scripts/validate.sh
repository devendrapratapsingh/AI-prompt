#!/bin/bash

# GitHub Actions Validation Script
# Validates GitHub Actions workflows and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_CHECKS++))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_CHECKS++))
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Validate YAML syntax
validate_yaml_syntax() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if command_exists python3; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            log_success "YAML syntax valid: $file"
            return 0
        else
            log_error "YAML syntax invalid: $file"
            return 1
        fi
    elif command_exists yamllint; then
        if yamllint "$file" > /dev/null 2>&1; then
            log_success "YAML valid: $file"
            return 0
        else
            log_error "YAML invalid: $file"
            yamllint "$file"
            return 1
        fi
    else
        log_warn "Skipping YAML validation (yamllint not installed)"
        return 0
    fi
}

# Check for required fields in workflow
check_workflow_fields() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    # Check for 'name'
    if grep -q "^name:" "$file"; then
        log_success "Workflow has 'name' field: $file"
    else
        log_error "Missing 'name' field in: $file"
        return 1
    fi
    
    # Check for 'on'
    if grep -q "^on:" "$file"; then
        log_success "Workflow has 'on' trigger: $file"
    else
        log_error "Missing 'on' trigger in: $file"
        return 1
    fi
    
    # Check for 'jobs'
    if grep -q "^jobs:" "$file"; then
        log_success "Workflow has 'jobs' section: $file"
    else
        log_error "Missing 'jobs' section in: $file"
        return 1
    fi
    
    return 0
}

# Validate workflow triggers
validate_workflow_triggers() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "on:\s*$" "$file"; then
        log_success "Valid 'on' trigger format: $file"
        return 0
    else
        log_error "Invalid 'on' trigger format: $file"
        return 1
    fi
}

# Check for pinned action versions
check_pinned_versions() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    local unpinned=$(grep -o "uses: [^@]*$" "$file" || true)
    
    if [ -z "$unpinned" ]; then
        log_success "All actions are version-pinned: $file"
        return 0
    else
        log_warn "Found unpinned actions: $file"
        echo "$unpinned"
        return 0
    fi
}

# Check for secret usage patterns
check_secret_usage() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    # Check for hardcoded credentials
    if grep -q "password\|secret\|token" "$file" | grep -v '\${{' > /dev/null 2>&1; then
        log_error "Possible hardcoded secrets in: $file"
        grep -n "password\|secret\|token" "$file" | head -5
        return 1
    else
        log_success "No obvious hardcoded secrets: $file"
        return 0
    fi
}

# Check for timeout configuration
check_timeout_config() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "timeout-minutes" "$file"; then
        log_success "Timeout configured: $file"
        return 0
    else
        log_warn "No timeout configured: $file"
        return 0
    fi
}

# Check artifact handling
check_artifact_handling() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "upload-artifact\|download-artifact" "$file"; then
        log_success "Artifact handling configured: $file"
        
        # Check for retention policy
        if grep -q "retention-days" "$file"; then
            log_success "Artifact retention policy set: $file"
        else
            log_warn "No artifact retention policy in: $file"
        fi
        return 0
    else
        log_info "No artifacts configured: $file"
        return 0
    fi
}

# Check caching
check_caching() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "actions/cache" "$file"; then
        log_success "Caching configured: $file"
        return 0
    else
        log_info "No caching configured: $file"
        return 0
    fi
}

# Check permissions
check_permissions() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "^permissions:" "$file"; then
        log_success "Permissions explicitly set: $file"
        return 0
    else
        log_warn "Permissions not explicitly set: $file (will use defaults)"
        return 0
    fi
}

# Check for environment variables
check_environment_variables() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "^env:" "$file" || grep -q "^\s*env:" "$file"; then
        log_success "Environment variables configured: $file"
        return 0
    else
        log_info "No environment variables configured: $file"
        return 0
    fi
}

# Test workflow locally if act is available
test_workflow_locally() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if ! command_exists act; then
        log_warn "act not installed - cannot test locally"
        log_info "Install act: https://github.com/nektos/act"
        return 0
    fi
    
    log_info "Testing workflow locally: $file"
    
    if act -l --workflows "$file" > /dev/null 2>&1; then
        log_success "Workflow can be executed locally: $file"
        return 0
    else
        log_error "Workflow failed local execution test: $file"
        return 1
    fi
}

# Check directory structure
check_directory_structure() {
    ((TOTAL_CHECKS++))
    
    if [ -d ".github" ]; then
        log_success "Found .github directory"
    else
        log_error "Missing .github directory"
        return 1
    fi
    
    if [ -d ".github/workflows" ]; then
        log_success "Found .github/workflows directory"
    else
        log_error "Missing .github/workflows directory"
        return 1
    fi
    
    return 0
}

# Check for secrets configuration
check_secrets_config() {
    ((TOTAL_CHECKS++))
    
    if [ -f ".env.example" ]; then
        log_success "Found .env.example template"
    else
        log_warn "Missing .env.example template"
    fi
    
    if [ -f ".github/workflows/.secrets-template.txt" ]; then
        log_success "Found secrets template"
    else
        log_warn "Missing secrets template"
    fi
    
    return 0
}

# Validate service dependencies
validate_service_dependencies() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "services:" "$file"; then
        log_success "Service dependencies configured: $file"
        
        # Check health checks
        if grep -q "health-cmd\|health-interval" "$file"; then
            log_success "Health checks configured for services: $file"
        else
            log_warn "No health checks configured for services: $file"
        fi
        return 0
    else
        log_info "No service dependencies: $file"
        return 0
    fi
}

# Check for matrix strategy
check_matrix_strategy() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "strategy:" "$file"; then
        log_success "Matrix strategy configured: $file"
        return 0
    else
        log_info "No matrix strategy: $file"
        return 0
    fi
}

# Validate conditional execution
validate_conditionals() {
    local file=$1
    ((TOTAL_CHECKS++))
    
    if grep -q "if:" "$file"; then
        log_success "Conditional execution configured: $file"
        return 0
    else
        log_info "No conditional execution: $file"
        return 0
    fi
}

# Print summary report
print_summary() {
    echo ""
    echo "========================================="
    echo "       Validation Summary"
    echo "========================================="
    echo "Total Checks:   $TOTAL_CHECKS"
    log_success "Passed: $PASSED_CHECKS"
    log_error "Failed: $FAILED_CHECKS"
    echo "========================================="
    echo ""
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        log_success "All validations passed!"
        return 0
    else
        log_error "$FAILED_CHECKS checks failed"
        return 1
    fi
}

# Main execution
main() {
    log_info "GitHub Actions Validation Script"
    echo ""
    
    # Check directory structure
    check_directory_structure
    check_secrets_config
    echo ""
    
    # Find all workflow files
    WORKFLOWS=$(.github/workflows/*.yml 2>/dev/null || true)
    
    if [ -z "$WORKFLOWS" ]; then
        log_warn "No workflows found in .github/workflows/"
        exit 0
    fi
    
    # Validate each workflow
    for workflow in .github/workflows/*.yml; do
        if [ -f "$workflow" ]; then
            log_info "Validating: $workflow"
            
            # Run all checks
            validate_yaml_syntax "$workflow"
            check_workflow_fields "$workflow"
            check_secret_usage "$workflow"
            check_timeout_config "$workflow"
            check_artifact_handling "$workflow"
            check_caching "$workflow"
            check_permissions "$workflow"
            check_environment_variables "$workflow"
            validate_service_dependencies "$workflow"
            check_matrix_strategy "$workflow"
            validate_conditionals "$workflow"
            
            echo ""
        fi
    done
    
    # Print summary
    print_summary
}

main "$@"
