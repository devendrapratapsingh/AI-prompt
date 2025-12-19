# Drone CI - Security Hardening Guide

## Table of Contents
1. [Overview](#overview)
2. [SAST Integration](#sast-integration)
3. [Container Scanning](#container-scanning)
4. [Image Signing](#image-signing)
5. [Supply Chain Security](#supply-chain-security)
6. [Secrets Management](#secrets-management)
7. [Network Security](#network-security)
8. [Access Control](#access-control)
9. [Audit Logging](#audit-logging)
10. [Compliance](#compliance)

## Overview

Security hardening for Drone CI involves implementing multiple layers of security controls
throughout the CI/CD pipeline. This guide covers enterprise-grade security practices.

### Security Principles
- **Defense in Depth**: Multiple security layers
- **Least Privilege**: Minimal access rights
- **Zero Trust**: Verify everything
- **Shift Left**: Security early in SDLC
- **Automation**: Automated security checks

## SAST Integration

### SonarQube Setup

Configure SonarQube for comprehensive code analysis:

```yaml
# .drone.yml
sast:sonarqube:
  stage: security
  image: sonarsource/sonar-scanner-cli:5.0
  variables:
    SONAR_USER_HOME: "$CI_PROJECT_DIR/.sonar"
    GIT_DEPTH: "0"
  script:
    - sonar-scanner 
        -Dsonar.projectKey=$PROJECT_KEY
        -Dsonar.sources=src
        -Dsonar.host.url=$SONAR_URL
        -Dsonar.login=$SONAR_TOKEN
        -Dsonar.qualitygate.wait=true
  allow_failure: false
```

#### Quality Gate Configuration
- **Code Coverage**: Minimum 80%
- **Duplicated Lines**: Maximum 3%
- **Maintainability Rating**: A or B
- **Reliability Rating**: A
- **Security Rating**: A
- **Security Hotspots**: 100% reviewed

### Semgrep Configuration

```yaml
sast:semgrep:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    # Run Semgrep with multiple rulesets
    - semgrep --config=auto --json --output=semgrep.json src/
    - semgrep --config=p/security-audit --json --output=semgrep-security.json src/
    - semgrep --config=p/owasp-top-ten --json --output=semgrep-owasp.json src/
    
    # Fail on high severity findings
    - semgrep --config=auto --error --severity ERROR src/
  artifacts:
    reports:
      sast: semgrep.json
```

### Language-Specific SAST

#### Java (SpotBugs, PMD, Checkstyle)

```xml
<!-- pom.xml -->
<build>
  <plugins>
    <plugin>
      <groupId>com.github.spotbugs</groupId>
      <artifactId>spotbugs-maven-plugin</artifactId>
      <version>4.7.3.0</version>
      <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <failOnError>true</failOnError>
        <plugins>
          <plugin>
            <groupId>com.h3xstream.findsecbugs</groupId>
            <artifactId>findsecbugs-plugin</artifactId>
            <version>1.12.0</version>
          </plugin>
        </plugins>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>check</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
    
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-pmd-plugin</artifactId>
      <version>3.21.0</version>
      <configuration>
        <rulesets>
          <ruleset>/rulesets/java/quickstart.xml</ruleset>
          <ruleset>/category/java/bestpractices.xml</ruleset>
          <ruleset>/category/java/security.xml</ruleset>
        </rulesets>
        <failOnViolation>true</failOnViolation>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>check</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
    
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-checkstyle-plugin</artifactId>
      <version>3.3.0</version>
      <configuration>
        <configLocation>google_checks.xml</configLocation>
        <consoleOutput>true</consoleOutput>
        <failsOnError>true</failsOnError>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>check</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

#### Python (Bandit, Pylint, mypy)

```yaml
sast:python:
  stage: security
  image: python:3.11
  script:
    # Install tools
    - pip install bandit pylint mypy safety
    
    # Bandit security scanning
    - bandit -r src/ -f json -o bandit-report.json
    - bandit -r src/ -ll -ii
    
    # Pylint code quality
    - pylint src/ --fail-under=8.0
    
    # mypy type checking
    - mypy src/ --strict
    
    # Safety dependency scanning
    - safety check --json --output safety-report.json
  artifacts:
    reports:
      sast: bandit-report.json
```

#### JavaScript/TypeScript (ESLint, OWASP)

```json
{
  "extends": [
    "eslint:recommended",
    "plugin:security/recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "plugins": ["security", "@typescript-eslint"],
  "rules": {
    "security/detect-object-injection": "error",
    "security/detect-non-literal-regexp": "error",
    "security/detect-unsafe-regex": "error",
    "security/detect-buffer-noassert": "error",
    "security/detect-child-process": "error",
    "security/detect-disable-mustache-escape": "error",
    "security/detect-eval-with-expression": "error",
    "security/detect-no-csrf-before-method-override": "error",
    "security/detect-non-literal-fs-filename": "error",
    "security/detect-non-literal-require": "error",
    "security/detect-possible-timing-attacks": "error",
    "security/detect-pseudoRandomBytes": "error"
  }
}
```

#### Go (Gosec, staticcheck)

```yaml
sast:golang:
  stage: security
  image: golang:1.21
  script:
    # Install tools
    - go install github.com/securego/gosec/v2/cmd/gosec@latest
    - go install honnef.co/go/tools/cmd/staticcheck@latest
    
    # Gosec security scanning
    - gosec -fmt=json -out=gosec-report.json ./...
    - gosec -severity medium ./...
    
    # staticcheck
    - staticcheck ./...
  artifacts:
    reports:
      sast: gosec-report.json
```

## Container Scanning

### Trivy Configuration

Comprehensive vulnerability scanning with Trivy:

```yaml
container:scan:trivy:
  stage: security
  image: aquasec/trivy:latest
  script:
    # Scan container image
    - trivy image --format json --output trivy-image.json $IMAGE
    
    # Check for HIGH and CRITICAL vulnerabilities
    - trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE
    
    # Scan for misconfigurations
    - trivy config --format json --output trivy-config.json .
    
    # Scan for secrets
    - trivy fs --scanners secret --format json --output trivy-secrets.json .
    
    # Generate SBOM
    - trivy image --format cyclonedx --output sbom-cyclonedx.json $IMAGE
    - trivy image --format spdx --output sbom-spdx.json $IMAGE
  artifacts:
    reports:
      container_scanning: trivy-image.json
      dependency_scanning: trivy-config.json
      secret_detection: trivy-secrets.json
    paths:
      - sbom-cyclonedx.json
      - sbom-spdx.json
```

### Grype Configuration

Alternative scanner for comprehensive coverage:

```yaml
container:scan:grype:
  stage: security
  image: anchore/grype:latest
  script:
    # Scan with Grype
    - grype $IMAGE --output json --file grype-report.json
    
    # Scan with specific severity threshold
    - grype $IMAGE --fail-on high
    
    # Compare against baseline
    - grype $IMAGE --base $BASE_IMAGE --output json
  artifacts:
    paths:
      - grype-report.json
```

### Snyk Configuration

Commercial scanner with extensive vulnerability database:

```yaml
container:scan:snyk:
  stage: security
  image: snyk/snyk:docker
  script:
    # Test container image
    - snyk container test $IMAGE --json-file-output=snyk-container.json
    
    # Monitor for ongoing tracking
    - snyk container monitor $IMAGE
    
    # Test dependencies
    - snyk test --json-file-output=snyk-deps.json
  artifacts:
    paths:
      - snyk-container.json
      - snyk-deps.json
```

### SBOM Generation and Management

```yaml
sbom:generate:
  stage: security
  image: anchore/syft:latest
  script:
    # Generate SBOM with Syft
    - syft $IMAGE -o cyclonedx-json > sbom-syft-cyclonedx.json
    - syft $IMAGE -o spdx-json > sbom-syft-spdx.json
    
    # Validate SBOM
    - cyclonedx validate --input-file sbom-syft-cyclonedx.json
    
    # Upload to dependency track
    - |
      curl -X POST "$DEPENDENCY_TRACK_URL/api/v1/bom" \
        -H "X-Api-Key: $DEPENDENCY_TRACK_KEY" \
        -H "Content-Type: multipart/form-data" \
        -F "project=$PROJECT_UUID" \
        -F "bom=@sbom-syft-cyclonedx.json"
  artifacts:
    paths:
      - sbom-syft-cyclonedx.json
      - sbom-syft-spdx.json
```

## Image Signing

### Cosign Keyless Signing (OIDC)

Recommended approach for CI/CD:

```yaml
image:sign:cosign:
  stage: sign
  image: gcr.io/projectsigstore/cosign:latest
  variables:
    COSIGN_EXPERIMENTAL: "true"
  script:
    # Sign with keyless method (OIDC)
    - cosign sign --yes $IMAGE
    
    # Generate and attach SBOM attestation
    - cosign attest --yes --predicate sbom-cyclonedx.json --type cyclonedx $IMAGE
    
    # Generate and attach SLSA provenance
    - cosign attest --yes --predicate provenance.json --type slsaprovenance $IMAGE
    
    # Verify signature
    - cosign verify --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" $IMAGE
```

### Cosign Key-Based Signing

For environments without OIDC:

```yaml
image:sign:keybased:
  stage: sign
  image: gcr.io/projectsigstore/cosign:latest
  before_script:
    # Load signing key from secrets
    - echo "$COSIGN_PRIVATE_KEY" > cosign.key
    - echo "$COSIGN_PASSWORD" > cosign.password
  script:
    # Sign with private key
    - cosign sign --key cosign.key --password-file cosign.password $IMAGE
    
    # Generate attestation
    - cosign attest --key cosign.key --predicate sbom.json --type cyclonedx $IMAGE
  after_script:
    # Clean up secrets
    - rm -f cosign.key cosign.password
```

### Notary Signing

Traditional signing method:

```yaml
image:sign:notary:
  stage: sign
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - apk add --no-cache notary
    - export NOTARY_DELEGATION_PASSPHRASE=$NOTARY_PASSPHRASE
  script:
    # Initialize trust
    - notary init $IMAGE
    
    # Add delegation key
    - notary delegation add $IMAGE targets/releases $NOTARY_CERT --all-paths
    
    # Sign and push
    - notary publish $IMAGE
```

### Signature Verification

```yaml
verify:signatures:
  stage: deploy
  before_script:
    - apk add --no-cache cosign
  script:
    # Verify Cosign signature
    - cosign verify --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" $IMAGE
    
    # Verify attestations
    - cosign verify-attestation --type cyclonedx --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" $IMAGE
    - cosign verify-attestation --type slsaprovenance --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" $IMAGE
    
    # Fail if verification fails
    - echo "✓ All signatures and attestations verified"
```

## Supply Chain Security

### SLSA Framework Implementation

Implement Supply Chain Levels for Software Artifacts:

```yaml
slsa:provenance:
  stage: security
  script:
    # Generate SLSA provenance
    - |
      cat > provenance.json << EOF
      {
        "_type": "https://in-toto.io/Statement/v0.1",
        "predicateType": "https://slsa.dev/provenance/v0.2",
        "subject": [
          {
            "name": "$IMAGE",
            "digest": {
              "sha256": "$(docker inspect --format='{{.Id}}' $IMAGE | cut -d: -f2)"
            }
          }
        ],
        "predicate": {
          "builder": {
            "id": "Drone CI Builder"
          },
          "buildType": "Drone CI Pipeline",
          "invocation": {
            "configSource": {
              "uri": "$CI_REPOSITORY_URL",
              "digest": {
                "sha256": "$CI_COMMIT_SHA"
              },
              "entryPoint": ".drone.yml"
            }
          },
          "metadata": {
            "buildStartedOn": "$BUILD_START_TIME",
            "buildFinishedOn": "$BUILD_END_TIME"
          },
          "materials": [
            {
              "uri": "$CI_REPOSITORY_URL",
              "digest": {
                "sha256": "$CI_COMMIT_SHA"
              }
            }
          ]
        }
      }
      EOF
    
    # Attach provenance to image
    - cosign attest --yes --predicate provenance.json --type slsaprovenance $IMAGE
```

### in-toto Attestations

```yaml
intoto:attestation:
  stage: security
  script:
    # Generate link metadata for each step
    - in-toto-run --step-name build --products target/*.jar -- mvn clean package
    - in-toto-run --step-name test --products target/surefire-reports/* -- mvn test
    - in-toto-run --step-name scan --products trivy-report.json -- trivy image $IMAGE
    
    # Sign attestations
    - in-toto-sign --key intoto.key build.link test.link scan.link
```

## Secrets Management

### HashiCorp Vault Integration

```yaml
secrets:vault:
  stage: build
  before_script:
    - apk add --no-cache vault
    
    # Authenticate with Vault
    - export VAULT_ADDR=$VAULT_URL
    - export VAULT_TOKEN=$(vault write -field=token auth/jwt/login role=$VAULT_ROLE jwt=$CI_JOB_JWT)
  script:
    # Retrieve secrets
    - export DB_PASSWORD=$(vault kv get -field=password secret/database)
    - export API_KEY=$(vault kv get -field=key secret/api)
    
    # Use secrets in build
    - echo "Using secrets from Vault"
```

### AWS Secrets Manager

```yaml
secrets:aws:
  stage: build
  image: amazon/aws-cli:latest
  script:
    # Retrieve secrets
    - export DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id prod/db/password --query SecretString --output text | jq -r .password)
    
    # Use in deployment
    - echo "Using AWS Secrets Manager"
```

### Secret Scanning

```yaml
secrets:scan:
  stage: security
  image: trufflesecurity/trufflehog:latest
  script:
    # Scan git history
    - trufflehog git file://. --json --output trufflehog-report.json
    
    # Scan filesystem
    - trufflehog filesystem . --json >> trufflehog-report.json
    
    # Fail if secrets found
    - |
      if [ $(jq '.verified == true' trufflehog-report.json | grep -c true) -gt 0 ]; then
        echo "ERROR: Verified secrets found!"
        exit 1
      fi
```

## Network Security

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: pipeline-network-policy
spec:
  podSelector:
    matchLabels:
      app: ci-pipeline
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: ci-cd
  egress:
    - to:
      - namespaceSelector:
          matchLabels:
            name: production
    - to:
      - podSelector:
          matchLabels:
            app: registry
```

### TLS Configuration

```yaml
tls:
  minVersion: VersionTLS13
  cipherSuites:
    - TLS_AES_256_GCM_SHA384
    - TLS_CHACHA20_POLY1305_SHA256
  certificates:
    - cert: /etc/ssl/certs/ci-cert.pem
      key: /etc/ssl/private/ci-key.pem
```

## Access Control

### RBAC Configuration

```yaml
roles:
  - name: developer
    permissions:
      pipelines:
        - read
        - write
      artifacts:
        - read
      secrets:
        - read
  
  - name: security
    permissions:
      pipelines:
        - read
      security-scans:
        - read
        - write
      policies:
        - write
  
  - name: operations
    permissions:
      pipelines:
        - read
      deployments:
        - read
        - write
      environments:
        - manage
```

### Service Accounts

```yaml
serviceAccounts:
  - name: ci-pipeline
    roles:
      - developer
      - deployer
    tokens:
      - name: ci-token
        scopes:
          - read:repository
          - write:artifacts
          - read:secrets
```

## Audit Logging

### Comprehensive Audit Logging

```yaml
audit:
  enabled: true
  destinations:
    - type: file
      path: /var/log/ci-audit.log
      rotation:
        maxSize: 100MB
        maxAge: 90d
    
    - type: syslog
      server: syslog.example.com:514
      protocol: tcp
      format: json
    
    - type: elasticsearch
      url: https://elasticsearch.example.com
      index: ci-audit
  
  events:
    - pipeline.start
    - pipeline.complete
    - pipeline.failed
    - deployment.start
    - deployment.complete
    - secret.access
    - rbac.change
    - user.login
    - user.logout
```

### Security Event Monitoring

```yaml
monitoring:security:
  stage: verify
  script:
    # Check for suspicious activities
    - |
      cat > security-check.sh << 'EOF'
      #!/bin/bash
      
      # Check for failed login attempts
      FAILED_LOGINS=$(grep "login failed" /var/log/ci-audit.log | wc -l)
      if [ $FAILED_LOGINS -gt 10 ]; then
        echo "ALERT: Multiple failed login attempts detected"
        exit 1
      fi
      
      # Check for privilege escalation
      PRIVESC=$(grep "privilege escalation" /var/log/ci-audit.log | wc -l)
      if [ $PRIVESC -gt 0 ]; then
        echo "ALERT: Privilege escalation detected"
        exit 1
      fi
      
      # Check for secret access anomalies
      SECRET_ACCESS=$(grep "secret.access" /var/log/ci-audit.log | wc -l)
      if [ $SECRET_ACCESS -gt 100 ]; then
        echo "WARNING: High number of secret access events"
      fi
      EOF
      
      chmod +x security-check.sh
      ./security-check.sh
```

## Compliance

### SOC 2 Compliance

```yaml
compliance:soc2:
  stage: verify
  script:
    # Verify encryption in transit
    - |
      if ! grep -q "TLS" config.yaml; then
        echo "ERROR: TLS not configured"
        exit 1
      fi
    
    # Verify access controls
    - |
      if ! grep -q "rbac" config.yaml; then
        echo "ERROR: RBAC not configured"
        exit 1
      fi
    
    # Verify audit logging
    - |
      if ! grep -q "audit.enabled: true" config.yaml; then
        echo "ERROR: Audit logging not enabled"
        exit 1
      fi
    
    # Generate compliance report
    - ./scripts/generate-soc2-report.sh > soc2-report.pdf
  artifacts:
    paths:
      - soc2-report.pdf
    expire_in: 7 years
```

### HIPAA Compliance

```yaml
compliance:hipaa:
  stage: verify
  script:
    # Verify data encryption
    - test -f /etc/encryption-config.yaml
    
    # Verify audit controls
    - test -f /etc/audit-policy.yaml
    
    # Verify access controls
    - kubectl get networkpolicies --all-namespaces
    
    # Generate HIPAA report
    - ./scripts/generate-hipaa-report.sh > hipaa-report.pdf
  artifacts:
    paths:
      - hipaa-report.pdf
    expire_in: 7 years
```

### PCI DSS Compliance

```yaml
compliance:pci:
  stage: verify
  script:
    # Verify network segmentation
    - kubectl get networkpolicies -n payment-processing
    
    # Verify encryption
    - openssl s_client -connect api.example.com:443 -tls1_3
    
    # Verify logging
    - test -d /var/log/pci-audit
    
    # Generate PCI report
    - ./scripts/generate-pci-report.sh > pci-report.pdf
  artifacts:
    paths:
      - pci-report.pdf
    expire_in: 7 years
```

## Best Practices Summary

1. **Always scan code with multiple SAST tools**
2. **Scan all container images before deployment**
3. **Sign all artifacts with Cosign**
4. **Verify signatures before deployment**
5. **Generate and maintain SBOMs**
6. **Implement SLSA provenance tracking**
7. **Use secrets management systems**
8. **Enable comprehensive audit logging**
9. **Implement RBAC with least privilege**
10. **Regular security updates and patching**
11. **Monitor and alert on security events**
12. **Maintain compliance with regulations**
13. **Regular security audits and assessments**
14. **Incident response planning**
15. **Security training for all team members**

## Conclusion

Security hardening is an ongoing process that requires continuous vigilance,
regular updates, and adaptation to new threats. Follow these guidelines to
maintain a robust security posture for your Drone CI pipelines.

For additional security resources and updates, refer to:
- Drone CI Security Documentation
- OWASP CI/CD Security Guidelines
- CNCF Security Best Practices
- NIST Cybersecurity Framework

---
**Last Updated**: 2024
**Version**: 2.0
**Compliance**: SOC 2, HIPAA, PCI DSS
