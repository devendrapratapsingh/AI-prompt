# Go Application CI/CD Pipeline - GitLab CI Example

## Overview
This example demonstrates a complete CI/CD pipeline for a Go microservice using GitLab CI/CD with Docker, PostgreSQL, and Kubernetes deployment.

## Complete Pipeline Configuration

```yaml
# .gitlab-ci.yml
variables:
  GO_VERSION: "1.21"
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  POSTGRES_VERSION: "15"
  CGO_ENABLED: "0"
  GOOS: linux
  GOARCH: amd64

stages:
  - build
  - test
  - quality
  - security
  - package
  - deploy

# Build stage
build:
  stage: build
  image: golang:$GO_VERSION
  before_script:
    - go version
    - mkdir -p $GOPATH/src/$(dirname $CI_PROJECT_PATH)
    - ln -svf $CI_PROJECT_DIR $GOPATH/src/$CI_PROJECT_PATH
    - cd $GOPATH/src/$CI_PROJECT_PATH
  script:
    - go mod download
    - go mod verify
    - go build -v -o app ./cmd/api
    - echo "Build completed successfully"
  cache:
    key: ${CI_COMMIT_REF_SLUG}-go
    paths:
      - .go/pkg/mod/
  artifacts:
    paths:
      - app
      - go.mod
      - go.sum
    expire_in: 1 hour

# Unit tests
test:unit:
  stage: test
  image: golang:$GO_VERSION
  services:
    - name: postgres:$POSTGRES_VERSION
      alias: postgres
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
    POSTGRES_HOST: postgres
    DATABASE_URL: postgres://testuser:testpass@postgres:5432/testdb?sslmode=disable
  before_script:
    - go mod download
  script:
    - go test -v -race -coverprofile=coverage.out -covermode=atomic ./...
    - go tool cover -func=coverage.out
    - go tool cover -html=coverage.out -o coverage.html
  coverage: '/total:.*?(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
    paths:
      - coverage.out
      - coverage.html
    expire_in: 1 week
  cache:
    key: ${CI_COMMIT_REF_SLUG}-go
    paths:
      - .go/pkg/mod/

# Integration tests
test:integration:
  stage: test
  image: golang:$GO_VERSION
  services:
    - name: postgres:$POSTGRES_VERSION
      alias: postgres
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
    DATABASE_URL: postgres://testuser:testpass@postgres:5432/testdb?sslmode=disable
  before_script:
    - go mod download
  script:
    - go test -v -tags=integration ./tests/integration/...
  artifacts:
    when: always
    paths:
      - test-results/
    expire_in: 1 week

# Benchmark tests
test:benchmark:
  stage: test
  image: golang:$GO_VERSION
  before_script:
    - go mod download
  script:
    - go test -bench=. -benchmem ./... | tee benchmark.txt
  artifacts:
    paths:
      - benchmark.txt
    expire_in: 1 week
  allow_failure: true

# Code quality - gofmt
quality:format:
  stage: quality
  image: golang:$GO_VERSION
  script:
    - gofmt -l . | tee gofmt-report.txt
    - test -z "$(gofmt -l .)"
  artifacts:
    paths:
      - gofmt-report.txt
    expire_in: 1 week
  allow_failure: true

# Code quality - golint
quality:lint:
  stage: quality
  image: golangci/golangci-lint:latest
  script:
    - golangci-lint run --out-format=json > golangci-lint-report.json || true
    - golangci-lint run
  artifacts:
    reports:
      codequality: golangci-lint-report.json
    paths:
      - golangci-lint-report.json
    expire_in: 1 week
  allow_failure: true

# Code quality - go vet
quality:vet:
  stage: quality
  image: golang:$GO_VERSION
  before_script:
    - go mod download
  script:
    - go vet ./...
  allow_failure: true

# Code quality - staticcheck
quality:staticcheck:
  stage: quality
  image: golang:$GO_VERSION
  before_script:
    - go install honnef.co/go/tools/cmd/staticcheck@latest
    - go mod download
  script:
    - staticcheck ./...
  allow_failure: true

# Security - gosec
security:gosec:
  stage: security
  image: securego/gosec:latest
  script:
    - gosec -fmt=json -out=gosec-report.json ./... || true
    - gosec ./...
  artifacts:
    reports:
      sast: gosec-report.json
    paths:
      - gosec-report.json
    expire_in: 1 week
  allow_failure: true

# Security - dependency check
security:dependencies:
  stage: security
  image: golang:$GO_VERSION
  before_script:
    - go install golang.org/x/vuln/cmd/govulncheck@latest
    - go mod download
  script:
    - govulncheck ./... || true
  allow_failure: true

# Security - nancy
security:nancy:
  stage: security
  image: golang:$GO_VERSION
  before_script:
    - go install github.com/sonatype-nexus-community/nancy@latest
  script:
    - go list -json -deps ./... | nancy sleuth || true
  allow_failure: true

# Docker image building
package:docker:
  stage: package
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $IMAGE_TAG -t $CI_REGISTRY_IMAGE:latest .
    - docker push $IMAGE_TAG
    - docker push $CI_REGISTRY_IMAGE:latest
    - echo "IMAGE_TAG=$IMAGE_TAG" >> build.env
  artifacts:
    reports:
      dotenv: build.env
    expire_in: 1 week
  only:
    - main
    - develop

# Container scanning
package:scan:
  stage: package
  image: aquasec/trivy:latest
  dependencies:
    - package:docker
  script:
    - trivy image --severity HIGH,CRITICAL --exit-code 0 --format json -o trivy-report.json $IMAGE_TAG
    - trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE_TAG
  artifacts:
    reports:
      container_scanning: trivy-report.json
    paths:
      - trivy-report.json
    expire_in: 1 week
  allow_failure: true
  only:
    - main
    - develop

# Deploy to development
deploy:dev:
  stage: deploy
  image: bitnami/kubectl:latest
  dependencies:
    - package:docker
  environment:
    name: development
    url: https://dev-api.example.com
    on_stop: cleanup:dev
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl create namespace go-app-dev || true
    - |
      cat <<EOF | kubectl apply -f -
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: go-app
        namespace: go-app-dev
      spec:
        replicas: 2
        selector:
          matchLabels:
            app: go-app
        template:
          metadata:
            labels:
              app: go-app
          spec:
            containers:
            - name: go-app
              image: $IMAGE_TAG
              ports:
              - containerPort: 8080
              env:
              - name: DATABASE_URL
                valueFrom:
                  secretKeyRef:
                    name: go-app-secrets
                    key: database-url
              livenessProbe:
                httpGet:
                  path: /health
                  port: 8080
                initialDelaySeconds: 30
                periodSeconds: 10
              readinessProbe:
                httpGet:
                  path: /ready
                  port: 8080
                initialDelaySeconds: 5
                periodSeconds: 5
              resources:
                requests:
                  memory: "64Mi"
                  cpu: "100m"
                limits:
                  memory: "256Mi"
                  cpu: "500m"
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: go-app-service
        namespace: go-app-dev
      spec:
        selector:
          app: go-app
        ports:
        - port: 80
          targetPort: 8080
        type: LoadBalancer
      EOF
    - kubectl rollout status deployment/go-app -n go-app-dev
  only:
    - develop

# Deploy to staging
deploy:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  dependencies:
    - package:docker
  environment:
    name: staging
    url: https://staging-api.example.com
    on_stop: cleanup:staging
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl create namespace go-app-staging || true
    - kubectl apply -f k8s/staging/ -n go-app-staging
    - kubectl set image deployment/go-app go-app=$IMAGE_TAG -n go-app-staging
    - kubectl rollout status deployment/go-app -n go-app-staging
  only:
    - main
  when: manual

# Deploy to production
deploy:production:
  stage: deploy
  image: bitnami/kubectl:latest
  dependencies:
    - package:docker
  environment:
    name: production
    url: https://api.example.com
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL_PROD" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN_PROD"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl create namespace go-app-prod || true
    - kubectl apply -f k8s/production/ -n go-app-prod
    - kubectl set image deployment/go-app go-app=$IMAGE_TAG -n go-app-prod
    - kubectl rollout status deployment/go-app -n go-app-prod
    - echo "Deployed to production successfully"
  only:
    - main
  when: manual
  allow_failure: false

# Cleanup development
cleanup:dev:
  stage: deploy
  image: bitnami/kubectl:latest
  environment:
    name: development
    action: stop
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl delete namespace go-app-dev --ignore-not-found=true
  when: manual

# Cleanup staging
cleanup:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  environment:
    name: staging
    action: stop
  before_script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
  script:
    - kubectl delete namespace go-app-staging --ignore-not-found=true
  when: manual
```

## Project Structure

```
go-project/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── config/
│   │   └── config.go
│   ├── database/
│   │   └── postgres.go
│   ├── handlers/
│   │   ├── health.go
│   │   └── users.go
│   ├── models/
│   │   └── user.go
│   ├── repository/
│   │   └── user_repository.go
│   └── service/
│       └── user_service.go
├── pkg/
│   └── middleware/
│       ├── auth.go
│       └── logger.go
├── tests/
│   ├── integration/
│   │   └── database_test.go
│   └── unit/
│       └── service_test.go
├── k8s/
│   ├── staging/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── production/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
├── Dockerfile
├── go.mod
├── go.sum
├── .gitlab-ci.yml
└── README.md
```

## Dockerfile

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api

# Runtime stage
FROM alpine:latest

WORKDIR /root/

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Copy binary from builder
COPY --from=builder --chown=appuser:appuser /app/main .

USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run application
CMD ["./main"]
```

## Application Code

### cmd/api/main.go

```go
package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/gorilla/mux"
    "myapp/internal/config"
    "myapp/internal/database"
    "myapp/internal/handlers"
)

func main() {
    // Load configuration
    cfg := config.Load()

    // Initialize database
    db, err := database.NewPostgresDB(cfg.DatabaseURL)
    if err != nil {
        log.Fatal("Failed to connect to database:", err)
    }
    defer db.Close()

    // Setup router
    router := mux.NewRouter()

    // Health endpoints
    router.HandleFunc("/health", handlers.HealthCheck(db)).Methods("GET")
    router.HandleFunc("/ready", handlers.ReadinessCheck).Methods("GET")

    // API endpoints
    api := router.PathPrefix("/api/v1").Subrouter()
    api.HandleFunc("/users", handlers.GetUsers(db)).Methods("GET")
    api.HandleFunc("/users/{id}", handlers.GetUser(db)).Methods("GET")
    api.HandleFunc("/users", handlers.CreateUser(db)).Methods("POST")

    // Create server
    srv := &http.Server{
        Addr:         ":" + cfg.Port,
        Handler:      router,
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // Start server in goroutine
    go func() {
        log.Printf("Server starting on port %s", cfg.Port)
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal("Server failed to start:", err)
        }
    }()

    // Graceful shutdown
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Println("Server shutting down...")

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal("Server forced to shutdown:", err)
    }

    log.Println("Server exited")
}
```

### internal/handlers/health.go

```go
package handlers

import (
    "encoding/json"
    "net/http"

    "github.com/jmoiron/sqlx"
)

type HealthResponse struct {
    Status   string `json:"status"`
    Database string `json:"database,omitempty"`
    Error    string `json:"error,omitempty"`
}

func HealthCheck(db *sqlx.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")

        // Check database connection
        if err := db.Ping(); err != nil {
            w.WriteStatus(http.StatusServiceUnavailable)
            json.NewEncoder(w).Encode(HealthResponse{
                Status:   "unhealthy",
                Database: "disconnected",
                Error:    err.Error(),
            })
            return
        }

        w.WriteHeader(http.StatusOK)
        json.NewEncoder(w).Encode(HealthResponse{
            Status:   "healthy",
            Database: "connected",
        })
    }
}

func ReadinessCheck(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]string{
        "status": "ready",
    })
}
```

## go.mod

```go
module myapp

go 1.21

require (
    github.com/gorilla/mux v1.8.1
    github.com/jmoiron/sqlx v1.3.5
    github.com/lib/pq v1.10.9
    github.com/joho/godotenv v1.5.1
)
```

## GitLab CI/CD Variables

Set these in GitLab project settings:

```
CI_REGISTRY_USER: GitLab username or deploy token
CI_REGISTRY_PASSWORD: GitLab password or deploy token
KUBE_URL: Kubernetes cluster URL
KUBE_TOKEN: Kubernetes service account token
KUBE_URL_PROD: Production Kubernetes cluster URL
KUBE_TOKEN_PROD: Production Kubernetes service account token
```

## Key Features

### 1. Comprehensive Testing
- Unit tests with race detector
- Integration tests with database
- Benchmark tests
- Code coverage reporting

### 2. Code Quality
- gofmt formatting checks
- golangci-lint comprehensive linting
- go vet static analysis
- staticcheck advanced checks

### 3. Security
- gosec security scanning
- govulncheck vulnerability detection
- nancy dependency scanning
- Container scanning with Trivy

### 4. Multi-Environment
- Development auto-deploy
- Staging manual deploy
- Production manual deploy with approval

### 5. Container Orchestration
- Kubernetes deployment
- Health and readiness probes
- Resource limits
- Load balancing

## Best Practices

1. **Static Binary**: CGO_ENABLED=0 for portable binaries
2. **Multi-stage Build**: Smaller final image
3. **Non-root User**: Enhanced security
4. **Graceful Shutdown**: Proper signal handling
5. **Health Checks**: Kubernetes-ready endpoints

## Running Locally

```bash
# Download dependencies
go mod download

# Run tests
go test -v ./...
go test -v -race ./...

# Run benchmarks
go test -bench=. -benchmem ./...

# Build application
go build -o app ./cmd/api

# Run application
./app

# Format code
gofmt -w .

# Lint code
golangci-lint run

# Security scan
gosec ./...
```

## Deployment

```bash
# Deploy to development
git push origin develop

# Deploy to staging
git push origin main
# Then manually trigger in GitLab UI

# Deploy to production
# Manually trigger in GitLab UI after staging validation
```
