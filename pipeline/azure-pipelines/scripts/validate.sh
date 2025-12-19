#!/bin/bash

# Azure Pipelines Validation Script
# Validates azure-pipelines.yml configuration

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
CHECKS=0

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; ((CHECKS++)); }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
log_error() { echo -e "${RED}✗${NC} $1"; ((ERRORS++)); }

echo -e "${BLUE}"
cat << "EOF"
     _                      __     __    _ _     _       _             
    / \    _____   _ _ __ __\ \   / /_ _| (_) __| | __ _| |_ ___  _ __ 
   / _ \  |_  / | | | '__/ _ \ \ / / _` | | |/ _` |/ _` | __/ _ \| '__|
  / ___ \  / /| |_| | | |  __/\ V / (_| | | | (_| | (_| | || (_) | |   
 /_/   \_\/___|\__,_|_|  \___| \_/ \__,_|_|_|\__,_|\__,_|\__\___/|_|   
                                                                         
  Validation Script v1.0
EOF
echo -e "${NC}"

check_file_exists() {
    log_info "Checking for azure-pipelines.yml..."
    
    if [ ! -f "azure-pipelines.yml" ]; then
        log_error "azure-pipelines.yml not found"
        exit 1
    fi
    log_success "azure-pipelines.yml found"
}

check_yaml_syntax() {
    log_info "Checking YAML syntax..."
    
    if command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('azure-pipelines.yml'))" > /dev/null 2>&1; then
            log_success "YAML syntax is valid"
        else
            log_error "YAML syntax errors detected"
        fi
    else
        log_warn "Python3 not found, skipping YAML validation"
    fi
}

check_trigger() {
    log_info "Checking trigger configuration..."
    
    if grep -q "^trigger:" azure-pipelines.yml; then
        log_success "Trigger is defined"
    else
        log_warn "No trigger defined (pipeline will run on all changes)"
    fi
}

check_pool() {
    log_info "Checking pool configuration..."
    
    if grep -q "pool:" azure-pipelines.yml; then
        log_success "Pool is defined"
        
        if grep "pool:" azure-pipelines.yml -A 1 | grep -q "vmImage:.*latest"; then
            log_warn "Using 'latest' image tag (consider specific versions)"
        fi
    else
        log_error "No pool defined"
    fi
}

check_stages_or_jobs() {
    log_info "Checking pipeline structure..."
    
    if grep -q "^stages:" azure-pipelines.yml; then
        log_success "Using multi-stage pipeline"
    elif grep -q "^jobs:" azure-pipelines.yml; then
        log_success "Using jobs"
    elif grep -q "^steps:" azure-pipelines.yml; then
        log_success "Using simple steps"
    else
        log_error "No stages, jobs, or steps found"
    fi
}

check_tasks() {
    log_info "Checking for tasks..."
    
    TASK_COUNT=$(grep -c "task:" azure-pipelines.yml || echo "0")
    if [ "$TASK_COUNT" -gt 0 ]; then
        log_success "Found $TASK_COUNT task(s)"
        
        if grep "task:" azure-pipelines.yml | grep -q "@\*"; then
            log_warn "Using wildcard task versions (specify exact versions)"
        fi
    else
        log_warn "No tasks found (using scripts only)"
    fi
}

check_artifacts() {
    log_info "Checking for artifacts..."
    
    if grep -q "PublishBuildArtifacts" azure-pipelines.yml || grep -q "PublishPipelineArtifact" azure-pipelines.yml; then
        log_success "Artifact publishing configured"
    else
        log_warn "No artifacts configured"
    fi
}

check_testing() {
    log_info "Checking for test configuration..."
    
    if grep -q "PublishTestResults" azure-pipelines.yml; then
        log_success "Test result publishing configured"
    else
        log_warn "No test result publishing"
    fi
    
    if grep -q "PublishCodeCoverageResults" azure-pipelines.yml; then
        log_success "Code coverage configured"
    else
        log_warn "No code coverage reporting"
    fi
}

check_security() {
    log_info "Checking for hardcoded secrets..."
    
    PATTERNS=(
        "password.*:.*['\"]"
        "token.*:.*['\"]"
        "api[_-]?key.*:.*['\"]"
        "secret.*:.*['\"]"
    )
    
    FOUND=0
    for pattern in "${PATTERNS[@]}"; do
        if grep -iE "$pattern" azure-pipelines.yml > /dev/null 2>&1; then
            log_error "Possible hardcoded secret: $pattern"
            ((FOUND++))
        fi
    done
    
    if [ $FOUND -eq 0 ]; then
        log_success "No obvious hardcoded secrets"
    fi
}

check_conditions() {
    log_info "Checking for deployment conditions..."
    
    if grep -q "condition:" azure-pipelines.yml; then
        log_success "Conditions defined"
    else
        log_warn "No conditions (all stages/jobs run always)"
    fi
}

check_best_practices() {
    log_info "Checking best practices..."
    
    if grep -q "dependsOn:" azure-pipelines.yml; then
        log_success "Using stage/job dependencies"
    fi
    
    if grep -q "variables:" azure-pipelines.yml; then
        log_success "Variables section defined"
    fi
    
    FILE_SIZE=$(wc -l < azure-pipelines.yml)
    if [ "$FILE_SIZE" -gt 500 ]; then
        log_warn "Large pipeline file ($FILE_SIZE lines). Consider templates"
    fi
}

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
        log_info "Next steps:"
        echo "  1. Review warnings"
        echo "  2. Commit azure-pipelines.yml"
        echo "  3. Create pipeline in Azure DevOps"
        echo "  4. Monitor first run"
        return 0
    else
        log_error "Fix errors before proceeding"
        return 1
    fi
}

main() {
    echo
    log_info "Starting validation..."
    echo
    
    check_file_exists
    echo
    check_yaml_syntax
    echo
    check_trigger
    echo
    check_pool
    echo
    check_stages_or_jobs
    echo
    check_tasks
    echo
    check_artifacts
    echo
    check_testing
    echo
    check_security
    echo
    check_conditions
    echo
    check_best_practices
    echo
    
    generate_report
}

main
exit $?
