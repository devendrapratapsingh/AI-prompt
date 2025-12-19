#!/bin/bash
# Concourse CI - Comprehensive Security Scanning Script
# Runs SAST, container scanning, and signature verification locally
# Exit codes: 0=success, 1=failure, 2=warnings

set -e  # Exit on error
set -o pipefail  # Catch pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCAN_RESULTS_DIR="$PROJECT_ROOT/security-scan-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Tool versions
TRIVY_VERSION="0.40.0"
COSIGN_VERSION="2.0.0"
SEMGREP_VERSION="latest"

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_WARNINGS=2

# Tracking
HAS_ERRORS=0
HAS_WARNINGS=0

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    HAS_WARNINGS=1
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    HAS_ERRORS=1
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed"
        return 1
    fi
    log_success "$1 is available"
    return 0
}

install_trivy() {
    log_info "Installing Trivy $TRIVY_VERSION..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v$TRIVY_VERSION
    log_success "Trivy installed"
}

install_cosign() {
    log_info "Installing Cosign $COSIGN_VERSION..."
    curl -sLO "https://github.com/sigstore/cosign/releases/download/v$COSIGN_VERSION/cosign-linux-amd64"
    sudo mv cosign-linux-amd64 /usr/local/bin/cosign
    sudo chmod +x /usr/local/bin/cosign
    log_success "Cosign installed"
}

install_semgrep() {
    log_info "Installing Semgrep..."
    pip3 install semgrep
    log_success "Semgrep installed"
}

setup_scan_environment() {
    log_info "Setting up scan environment..."
    
    # Create results directory
    mkdir -p "$SCAN_RESULTS_DIR"
    
    # Check for required tools
    local tools_missing=0
    
    if ! check_command "trivy"; then
        install_trivy || tools_missing=1
    fi
    
    if ! check_command "cosign"; then
        install_cosign || tools_missing=1
    fi
    
    if ! check_command "semgrep"; then
        install_semgrep || tools_missing=1
    fi
    
    if [ $tools_missing -eq 1 ]; then
        log_error "Failed to install required tools"
        return 1
    fi
    
    log_success "Scan environment ready"
    return 0
}

run_sast_scanning() {
    log_info "Running SAST scanning..."
    
    local sast_dir="$SCAN_RESULTS_DIR/sast"
    mkdir -p "$sast_dir"
    
    # Semgrep scanning
    log_info "Running Semgrep..."
    if semgrep --config=auto --json --output="$sast_dir/semgrep-$TIMESTAMP.json" "$PROJECT_ROOT"; then
        log_success "Semgrep scan completed"
    else
        log_error "Semgrep scan failed"
        return 1
    fi
    
    # Check for high severity issues
    local high_issues=$(jq '[.results[] | select(.extra.severity == "ERROR")] | length' "$sast_dir/semgrep-$TIMESTAMP.json")
    if [ "$high_issues" -gt 0 ]; then
        log_error "Found $high_issues high severity issues"
        HAS_ERRORS=1
    else
        log_success "No high severity issues found"
    fi
    
    # Language-specific scanning
    if [ -f "$PROJECT_ROOT/pom.xml" ]; then
        log_info "Running Java security checks..."
        run_java_sast "$sast_dir"
    fi
    
    if [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
        log_info "Running Python security checks..."
        run_python_sast "$sast_dir"
    fi
    
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        log_info "Running JavaScript security checks..."
        run_javascript_sast "$sast_dir"
    fi
    
    if [ -f "$PROJECT_ROOT/go.mod" ]; then
        log_info "Running Go security checks..."
        run_go_sast "$sast_dir"
    fi
    
    log_success "SAST scanning completed"
    return 0
}

run_java_sast() {
    local output_dir="$1"
    
    # SpotBugs
    if command -v mvn &> /dev/null; then
        log_info "Running SpotBugs..."
        mvn spotbugs:check || log_warning "SpotBugs found issues"
    fi
    
    # PMD
    log_info "Running PMD..."
    mvn pmd:check || log_warning "PMD found issues"
    
    # Checkstyle
    log_info "Running Checkstyle..."
    mvn checkstyle:check || log_warning "Checkstyle found issues"
}

run_python_sast() {
    local output_dir="$1"
    
    # Bandit
    if command -v bandit &> /dev/null; then
        log_info "Running Bandit..."
        bandit -r "$PROJECT_ROOT" -f json -o "$output_dir/bandit-$TIMESTAMP.json" || log_warning "Bandit found issues"
    else
        log_info "Installing Bandit..."
        pip3 install bandit
        bandit -r "$PROJECT_ROOT" -f json -o "$output_dir/bandit-$TIMESTAMP.json" || log_warning "Bandit found issues"
    fi
    
    # Safety (dependency check)
    if command -v safety &> /dev/null; then
        log_info "Running Safety..."
        safety check --json --output "$output_dir/safety-$TIMESTAMP.json" || log_warning "Safety found vulnerabilities"
    fi
}

run_javascript_sast() {
    local output_dir="$1"
    
    # ESLint with security plugin
    if command -v npx &> /dev/null; then
        log_info "Running ESLint with security plugins..."
        npx eslint --ext .js,.jsx,.ts,.tsx "$PROJECT_ROOT" -f json -o "$output_dir/eslint-$TIMESTAMP.json" || log_warning "ESLint found issues"
    fi
    
    # npm audit
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        log_info "Running npm audit..."
        npm audit --json > "$output_dir/npm-audit-$TIMESTAMP.json" || log_warning "npm audit found vulnerabilities"
    fi
}

run_go_sast() {
    local output_dir="$1"
    
    # Gosec
    if command -v gosec &> /dev/null; then
        log_info "Running Gosec..."
        gosec -fmt=json -out="$output_dir/gosec-$TIMESTAMP.json" ./... || log_warning "Gosec found issues"
    else
        log_info "Installing Gosec..."
        go install github.com/securego/gosec/v2/cmd/gosec@latest
        gosec -fmt=json -out="$output_dir/gosec-$TIMESTAMP.json" ./... || log_warning "Gosec found issues"
    fi
}

run_dependency_scanning() {
    log_info "Running dependency scanning..."
    
    local deps_dir="$SCAN_RESULTS_DIR/dependencies"
    mkdir -p "$deps_dir"
    
    # Trivy filesystem scan
    log_info "Scanning dependencies with Trivy..."
    if trivy fs --format json --output "$deps_dir/trivy-deps-$TIMESTAMP.json" "$PROJECT_ROOT"; then
        log_success "Trivy dependency scan completed"
    else
        log_error "Trivy dependency scan failed"
        return 1
    fi
    
    # Check for critical vulnerabilities
    local critical_vulns=$(trivy fs --severity CRITICAL --format json "$PROJECT_ROOT" | jq '.Results[].Vulnerabilities | length')
    if [ "$critical_vulns" -gt 0 ]; then
        log_error "Found $critical_vulns critical vulnerabilities in dependencies"
        HAS_ERRORS=1
    else
        log_success "No critical vulnerabilities in dependencies"
    fi
    
    return 0
}

run_container_scanning() {
    log_info "Running container scanning..."
    
    local container_dir="$SCAN_RESULTS_DIR/containers"
    mkdir -p "$container_dir"
    
    # Find Docker images
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")
    
    if [ -z "$images" ]; then
        log_warning "No Docker images found to scan"
        return 0
    fi
    
    # Scan each image
    for image in $images; do
        log_info "Scanning image: $image"
        
        # Trivy scan
        trivy image --format json --output "$container_dir/trivy-${image//\//_}-$TIMESTAMP.json" "$image"
        
        # Check for HIGH and CRITICAL vulnerabilities
        local vuln_count=$(trivy image --severity HIGH,CRITICAL --format json "$image" | jq '.Results[].Vulnerabilities | length')
        if [ "$vuln_count" -gt 0 ]; then
            log_warning "Image $image has $vuln_count HIGH/CRITICAL vulnerabilities"
            HAS_WARNINGS=1
        else
            log_success "Image $image has no HIGH/CRITICAL vulnerabilities"
        fi
    done
    
    log_success "Container scanning completed"
    return 0
}

generate_sbom() {
    log_info "Generating SBOM..."
    
    local sbom_dir="$SCAN_RESULTS_DIR/sbom"
    mkdir -p "$sbom_dir"
    
    # Generate SBOM for project
    log_info "Generating project SBOM..."
    trivy fs --format cyclonedx --output "$sbom_dir/sbom-cyclonedx-$TIMESTAMP.json" "$PROJECT_ROOT"
    trivy fs --format spdx --output "$sbom_dir/sbom-spdx-$TIMESTAMP.json" "$PROJECT_ROOT"
    
    # Generate SBOM for Docker images
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | head -1)
    if [ -n "$images" ]; then
        for image in $images; do
            log_info "Generating SBOM for image: $image"
            trivy image --format cyclonedx --output "$sbom_dir/sbom-${image//\//_}-cyclonedx-$TIMESTAMP.json" "$image"
        done
    fi
    
    log_success "SBOM generation completed"
    return 0
}

verify_signatures() {
    log_info "Verifying container signatures..."
    
    local verify_dir="$SCAN_RESULTS_DIR/verification"
    mkdir -p "$verify_dir"
    
    # Find Docker images
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")
    
    if [ -z "$images" ]; then
        log_warning "No Docker images found to verify"
        return 0
    fi
    
    # Verify each image
    for image in $images; do
        log_info "Verifying signatures for: $image"
        
        # Check if image is signed
        if cosign verify --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" "$image" 2>&1 | tee "$verify_dir/cosign-${image//\//_}-$TIMESTAMP.log"; then
            log_success "Image $image signature verified"
        else
            log_warning "Image $image is not signed or verification failed"
            HAS_WARNINGS=1
        fi
    done
    
    return 0
}

generate_security_report() {
    log_info "Generating security report..."
    
    local report_file="$SCAN_RESULTS_DIR/security-report-$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Security Scan Report
**Generated**: $(date)
**Project**: $PROJECT_ROOT
**Platform**: Concourse CI

## Summary

- **SAST Scans**: $(find "$SCAN_RESULTS_DIR/sast" -type f 2>/dev/null | wc -l) files
- **Dependency Scans**: $(find "$SCAN_RESULTS_DIR/dependencies" -type f 2>/dev/null | wc -l) files
- **Container Scans**: $(find "$SCAN_RESULTS_DIR/containers" -type f 2>/dev/null | wc -l) files
- **SBOMs Generated**: $(find "$SCAN_RESULTS_DIR/sbom" -type f 2>/dev/null | wc -l) files
- **Errors**: $HAS_ERRORS
- **Warnings**: $HAS_WARNINGS

## Scan Results

### SAST Findings
$(find "$SCAN_RESULTS_DIR/sast" -type f -name "*.json" -exec echo "- {}" \;)

### Dependency Vulnerabilities
$(find "$SCAN_RESULTS_DIR/dependencies" -type f -name "*.json" -exec echo "- {}" \;)

### Container Vulnerabilities
$(find "$SCAN_RESULTS_DIR/containers" -type f -name "*.json" -exec echo "- {}" \;)

## Recommendations

1. Review and remediate all high severity findings
2. Update vulnerable dependencies
3. Sign all container images with Cosign
4. Implement signature verification in deployment pipeline
5. Regular security scanning in CI/CD

## Next Steps

- Address critical vulnerabilities immediately
- Create tickets for medium severity issues
- Update security policies as needed
- Schedule regular security reviews

---
**Report Location**: $report_file
EOF
    
    log_success "Security report generated: $report_file"
    echo "$report_file"
}

cleanup() {
    log_info "Cleaning up temporary files..."
    # Add cleanup logic if needed
    log_success "Cleanup completed"
}

main() {
    echo "========================================"
    echo "  Concourse CI Security Scanner"
    echo "========================================"
    echo ""
    
    # Setup environment
    setup_scan_environment || {
        log_error "Failed to setup scan environment"
        exit $EXIT_FAILURE
    }
    
    # Run all scans
    run_sast_scanning || log_error "SAST scanning failed"
    run_dependency_scanning || log_error "Dependency scanning failed"
    run_container_scanning || log_error "Container scanning failed"
    generate_sbom || log_error "SBOM generation failed"
    verify_signatures || log_warning "Signature verification had warnings"
    
    # Generate report
    report_file=$(generate_security_report)
    
    # Cleanup
    cleanup
    
    # Summary
    echo ""
    echo "========================================"
    echo "  Scan Complete"
    echo "========================================"
    echo "Results directory: $SCAN_RESULTS_DIR"
    echo "Report: $report_file"
    echo ""
    
    # Exit with appropriate code
    if [ $HAS_ERRORS -eq 1 ]; then
        log_error "Security scan completed with errors"
        exit $EXIT_FAILURE
    elif [ $HAS_WARNINGS -eq 1 ]; then
        log_warning "Security scan completed with warnings"
        exit $EXIT_WARNINGS
    else
        log_success "Security scan completed successfully"
        exit $EXIT_SUCCESS
    fi
}

# Run main function
main "$@"
