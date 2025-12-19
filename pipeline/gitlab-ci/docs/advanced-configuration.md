# GitLab CI/CD - Advanced Configuration Guide

## Table of Contents
- [Pipeline Architecture](#pipeline-architecture)
- [Advanced Job Configuration](#advanced-job-configuration)
- [Caching Strategies](#caching-strategies)
- [Artifact Management](#artifact-management)
- [Multi-Project Pipelines](#multi-project-pipelines)
- [Dynamic Pipelines](#dynamic-pipelines)
- [Performance Optimization](#performance-optimization)
- [Security Best Practices](#security-best-practices)

## Pipeline Architecture

### Parent-Child Pipelines

Use parent-child pipelines for complex workflows:

```yaml
# Parent pipeline (.gitlab-ci.yml)
stages:
  - trigger

trigger_child_pipeline:
  stage: trigger
  trigger:
    include:
      - local: '.gitlab-ci-child.yml'
    strategy: depend

# Child pipeline (.gitlab-ci-child.yml)
stages:
  - build
  - test

build:
  stage: build
  script:
    - echo "Building in child pipeline"

test:
  stage: test
  script:
    - echo "Testing in child pipeline"
```

### Multi-Project Pipelines

Trigger pipelines in other projects:

```yaml
trigger_downstream:
  stage: deploy
  trigger:
    project: group/downstream-project
    branch: main
    strategy: depend
  only:
    - main
```

### Dynamic Child Pipelines

Generate pipeline configuration dynamically:

```yaml
generate_pipeline:
  stage: generate
  script:
    - python generate_pipeline.py > generated-pipeline.yml
  artifacts:
    paths:
      - generated-pipeline.yml

trigger_dynamic:
  stage: trigger
  trigger:
    include:
      - artifact: generated-pipeline.yml
        job: generate_pipeline
```

## Advanced Job Configuration

### Job Templates (DRY)

```yaml
.build_template:
  image: node:18
  before_script:
    - npm ci
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
  tags:
    - docker

.test_template:
  extends: .build_template
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build:frontend:
  extends: .build_template
  script:
    - npm run build:frontend

test:unit:
  extends: .test_template
  script:
    - npm run test:unit
```

### Retry Configuration

```yaml
test:
  script:
    - npm test
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_or_timeout_failure
      - script_failure
```

### Resource Management

```yaml
heavy_job:
  script:
    - ./run_heavy_task.sh
  tags:
    - high-cpu
  resource_group: production
  timeout: 3h
```

### Interruptible Jobs

```yaml
test:
  script:
    - npm test
  interruptible: true  # Can be interrupted by newer pipeline
```

## Caching Strategies

### Cache Key Strategies

**File-based Cache:**
```yaml
cache:
  key:
    files:
      - package-lock.json
      - yarn.lock
  paths:
    - node_modules/
```

**Branch-based Cache:**
```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .m2/repository/
```

**Fallback Cache:**
```yaml
cache:
  key:
    files:
      - Gemfile.lock
  paths:
    - vendor/ruby
  fallback_keys:
    - ${CI_COMMIT_REF_SLUG}
    - default-cache
```

### Cache Policies

```yaml
build:
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
    policy: pull-push  # Default

test:
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
    policy: pull  # Read-only
```

### Distributed Cache

```yaml
.cache_template:
  cache:
    - key: ${CI_COMMIT_REF_SLUG}-vendor
      paths:
        - vendor/
    - key: ${CI_COMMIT_REF_SLUG}-build
      paths:
        - build/
```

## Artifact Management

### Advanced Artifact Configuration

```yaml
build:
  script:
    - npm run build
  artifacts:
    name: "build-${CI_COMMIT_REF_SLUG}-${CI_COMMIT_SHORT_SHA}"
    paths:
      - dist/
      - public/
    exclude:
      - dist/**/*.map
      - dist/**/*.spec.js
    expire_in: 1 week
    when: on_success
```

### Test Reports

```yaml
test:
  script:
    - npm run test
  artifacts:
    reports:
      junit:
        - reports/junit/*.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
      codequality: gl-code-quality-report.json
      sast: gl-sast-report.json
      dependency_scanning: gl-dependency-scanning-report.json
      container_scanning: gl-container-scanning-report.json
```

### Artifact Dependencies

```yaml
build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  dependencies:
    - build
  script:
    - npm run test

deploy:
  stage: deploy
  dependencies:
    - build
  needs:
    - job: build
      artifacts: true
  script:
    - ./deploy.sh dist/
```

## Multi-Stage Docker Builds

### Optimized Docker Build

```yaml
docker:build:
  stage: package
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
    DOCKER_BUILDKIT: 1
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - |
      docker build \
        --cache-from $CI_REGISTRY_IMAGE:latest \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA \
        --tag $CI_REGISTRY_IMAGE:latest \
        .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest
```

### Kaniko for Rootless Builds

```yaml
docker:kaniko:
  stage: package
  image:
    name: gcr.io/kaniko-project/executor:latest
    entrypoint: [""]
  script:
    - |
      /kaniko/executor \
        --context $CI_PROJECT_DIR \
        --dockerfile $CI_PROJECT_DIR/Dockerfile \
        --destination $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA \
        --destination $CI_REGISTRY_IMAGE:latest \
        --cache=true \
        --cache-ttl=24h
```

## Environment Management

### Dynamic Environments

```yaml
review:
  stage: deploy
  script:
    - ./deploy-review.sh
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.example.com
    on_stop: stop_review
    auto_stop_in: 1 week
  only:
    - branches
  except:
    - main

stop_review:
  stage: deploy
  script:
    - ./cleanup-review.sh
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
  when: manual
  only:
    - branches
  except:
    - main
```

### Deployment Strategy

```yaml
.deploy_template:
  before_script:
    - kubectl config set-cluster k8s --server=$KUBE_URL
    - kubectl config set-credentials admin --token=$KUBE_TOKEN
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default

deploy:canary:
  extends: .deploy_template
  stage: deploy
  environment:
    name: production
    deployment_tier: production
  script:
    - kubectl apply -f k8s/canary/
    - kubectl set image deployment/app app=$IMAGE_TAG
    - sleep 300  # Monitor canary for 5 minutes
  when: manual
  only:
    - main

deploy:production:
  extends: .deploy_template
  stage: deploy
  environment:
    name: production
    deployment_tier: production
  script:
    - kubectl apply -f k8s/production/
    - kubectl set image deployment/app app=$IMAGE_TAG
    - kubectl rollout status deployment/app
  needs:
    - deploy:canary
  when: manual
  only:
    - main
```

## Rules and Conditions

### Complex Rules

```yaml
build:
  script:
    - npm run build
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      changes:
        - src/**/*
        - package.json
      when: always
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: always
    - if: '$CI_COMMIT_TAG'
      when: always
    - when: never

test:integration:
  script:
    - npm run test:integration
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual
      allow_failure: true
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: always
    - when: never
```

### Workflow Rules

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS'
      when: never
    - if: '$CI_COMMIT_BRANCH'
```

## Parallel Execution

### Parallel Jobs

```yaml
test:
  script:
    - npm run test:shard -- --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
  parallel: 5
```

### Matrix Strategy

```yaml
test:matrix:
  parallel:
    matrix:
      - NODE_VERSION: ['16', '18', '20']
        OS: ['ubuntu', 'alpine']
  image: node:${NODE_VERSION}-${OS}
  script:
    - npm ci
    - npm test
```

### DAG (Directed Acyclic Graph)

```yaml
build:frontend:
  stage: build
  script:
    - npm run build:frontend
  artifacts:
    paths:
      - dist/frontend/

build:backend:
  stage: build
  script:
    - npm run build:backend
  artifacts:
    paths:
      - dist/backend/

test:frontend:
  stage: test
  needs:
    - build:frontend
  script:
    - npm run test:frontend

test:backend:
  stage: test
  needs:
    - build:backend
  script:
    - npm run test:backend

deploy:
  stage: deploy
  needs:
    - test:frontend
    - test:backend
  script:
    - ./deploy.sh
```

## Security Scanning Integration

### SAST (Static Application Security Testing)

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml

sast:
  variables:
    SAST_EXCLUDED_PATHS: "spec, test, tests, tmp"
```

### Dependency Scanning

```yaml
include:
  - template: Security/Dependency-Scanning.gitlab-ci.yml

dependency_scanning:
  variables:
    DS_EXCLUDED_PATHS: "spec, test, tests, tmp"
```

### Container Scanning

```yaml
include:
  - template: Security/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    CS_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
```

### Custom Security Scanning

```yaml
security:custom:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --format json --output trivy-report.json $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
    - trivy image --severity HIGH,CRITICAL --exit-code 1 $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  artifacts:
    reports:
      container_scanning: trivy-report.json
  allow_failure: true
```

## Performance Optimization

### Job Execution Time Reduction

1. **Use Smaller Base Images:**
```yaml
# Bad
image: node:latest

# Good
image: node:18-alpine
```

2. **Leverage Cache Effectively:**
```yaml
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
  policy: pull-push
```

3. **Minimize Artifact Size:**
```yaml
artifacts:
  paths:
    - dist/
  exclude:
    - '**/*.map'
    - '**/*.test.js'
```

### Pipeline Duration Optimization

**Before (Sequential):**
```yaml
stages:
  - build
  - test
  - deploy

# Total: 15 minutes (5+7+3)
```

**After (Parallel with DAG):**
```yaml
build:frontend:
  stage: build
  needs: []

build:backend:
  stage: build
  needs: []

test:frontend:
  needs: [build:frontend]

test:backend:
  needs: [build:backend]

deploy:
  needs: [test:frontend, test:backend]

# Total: 10 minutes (5+5 parallel, then 3)
```

## Monitoring and Debugging

### Debug Logging

```yaml
build:
  variables:
    CI_DEBUG_TRACE: "true"
  script:
    - npm run build
```

### Job Timeout

```yaml
long_running_job:
  script:
    - ./long-task.sh
  timeout: 2h
```

### Custom Metrics

```yaml
test:
  script:
    - npm test
    - echo "METRIC_NAME:metric_value" | tee metrics.txt
  artifacts:
    reports:
      metrics: metrics.txt
```

## Advanced Variables

### Project/Group Variables

Set in UI: Settings → CI/CD → Variables

### File Variables

```yaml
deploy:
  variables:
    KUBECONFIG_FILE:
      file: $KUBECONFIG
  script:
    - kubectl --kubeconfig=$KUBECONFIG_FILE apply -f k8s/
```

### Masked and Protected Variables

- **Masked**: Hidden in job logs
- **Protected**: Only available for protected branches/tags

## Include Templates

### Local Includes

```yaml
include:
  - local: '.gitlab-ci-build.yml'
  - local: '.gitlab-ci-test.yml'
  - local: '.gitlab-ci-deploy.yml'
```

### Remote Includes

```yaml
include:
  - remote: 'https://example.com/ci-templates/build.yml'
```

### Template Includes

```yaml
include:
  - template: Auto-DevOps.gitlab-ci.yml
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
```

### Project Includes

```yaml
include:
  - project: 'group/ci-templates'
    ref: main
    file: '/templates/build.yml'
```

## Best Practices

### 1. DRY (Don't Repeat Yourself)
Use templates and `extends` keyword

### 2. Fail Fast
Run quick validation jobs early

### 3. Parallel Execution
Use `needs` and `parallel` to speed up pipelines

### 4. Cache Wisely
Balance between cache size and build speed

### 5. Secure Pipelines
- Use protected variables
- Scan for vulnerabilities
- Validate inputs

### 6. Monitor Pipeline Performance
- Track pipeline duration
- Optimize slow jobs
- Use DAG visualization

### 7. Version Control
- Keep `.gitlab-ci.yml` in version control
- Use semantic versioning for pipeline templates
- Document changes

## Troubleshooting

### Common Issues

**Cache Not Working:**
```yaml
# Solution: Use consistent cache keys
cache:
  key:
    files:
      - package-lock.json
```

**Jobs Running Too Long:**
```yaml
# Solution: Add timeout
timeout: 30m
```

**Artifacts Not Available:**
```yaml
# Solution: Check dependencies and needs
dependencies:
  - build
needs:
  - job: build
    artifacts: true
```

## Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [.gitlab-ci.yml Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [CI/CD Examples](https://docs.gitlab.com/ee/ci/examples/)
- [GitLab Runner Advanced Configuration](https://docs.gitlab.com/runner/configuration/advanced-configuration.html)
