# Go CI/CD Pipeline - GitHub Actions Example

## Overview
This example demonstrates a complete CI/CD pipeline for a Go microservice using GitHub Actions.

## Complete Pipeline Configuration

```yaml
name: Go CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: ['1.20', '1.21']
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go ${{ matrix.go-version }}
        uses: actions/setup-go@v4
        with:
          go-version: ${{ matrix.go-version }}
          cache: true
      
      - name: Download dependencies
        run: go mod download
      
      - name: Verify module integrity
        run: go mod verify
      
      - name: Format check
        run: |
          if [ -n "$(gofmt -l .)" ]; then
            echo "Code formatting issues found"
            gofmt -d .
            exit 1
          fi
      
      - name: Vet code
        run: go vet ./...
      
      - name: Build
        run: go build -v -o bin/app ./cmd/main.go

  test:
    runs-on: ubuntu-latest
    needs: build
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
          cache: true
      
      - name: Run unit tests
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable
        run: go test -v -race -coverprofile=coverage.out -covermode=atomic ./...
      
      - name: Run benchmarks
        run: go test -bench=. -benchmem ./... | tee benchmark-results.txt
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.out
          flags: go-coverage
          name: go

  security:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
          cache: true
      
      - name: Run Gosec security scanner
        uses: securego/gosec@master
        with:
          args: '-no-fail -fmt sarif -out gosec-results.sarif ./...'
      
      - name: Upload Gosec results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: gosec-results.sarif
      
      - name: Run golangci-lint
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
          args: --timeout=5m

  build-docker:
    runs-on: ubuntu-latest
    needs: [test, security]
    permissions:
      packages: write

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.sha }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Dockerfile

```dockerfile
# Multi-stage build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app ./cmd/main.go

# Runtime
FROM alpine:3.18
RUN apk --no-cache add ca-certificates curl
WORKDIR /root/
COPY --from=builder /app/app .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080
CMD ["./app"]
```

## Go Application Structure

### cmd/main.go
```go
package main

import (
    "context"
    "fmt"
    "log/slog"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "myapp/internal/app"
    "myapp/internal/config"
)

func main() {
    // Setup logger
    logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
    slog.SetDefault(logger)

    // Load configuration
    cfg := config.Load()

    // Initialize application
    application := app.New(cfg)

    // Setup HTTP server
    server := &http.Server{
        Addr:         fmt.Sprintf(":%d", cfg.Port),
        Handler:      application.Router(),
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // Start server in goroutine
    go func() {
        slog.Info("Server starting", "port", cfg.Port)
        if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            slog.Error("Server error", "error", err)
            os.Exit(1)
        }
    }()

    // Graceful shutdown
    sigChan := make(chan os.Signal, 1)
    signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
    <-sigChan

    slog.Info("Server shutting down gracefully")
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := server.Shutdown(ctx); err != nil {
        slog.Error("Shutdown error", "error", err)
        os.Exit(1)
    }

    slog.Info("Server stopped")
}
```

### internal/app/app.go
```go
package app

import (
    "net/http"

    "myapp/internal/config"
    "myapp/internal/handlers"
)

type App struct {
    config *config.Config
    router *http.ServeMux
}

func New(cfg *config.Config) *App {
    router := http.NewServeMux()

    // Health check
    router.HandleFunc("GET /health", handlers.HealthCheck)

    // Metrics
    router.HandleFunc("GET /metrics", handlers.Metrics)

    // API endpoints
    router.HandleFunc("GET /api/users", handlers.ListUsers)
    router.HandleFunc("POST /api/users", handlers.CreateUser)

    return &App{
        config: cfg,
        router: router,
    }
}

func (a *App) Router() http.Handler {
    return a.router
}
```

### internal/handlers/health.go
```go
package handlers

import (
    "encoding/json"
    "net/http"
)

type HealthResponse struct {
    Status string `json:"status"`
}

func HealthCheck(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(HealthResponse{Status: "healthy"})
}

func Metrics(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    metrics := map[string]int{"requests": 1000}
    json.NewEncoder(w).Encode(metrics)
}
```

## Go Module Configuration

### go.mod
```
module myapp

go 1.21

require (
    github.com/lib/pq v1.10.9
)

require (
    github.com/jackc/pgx/v5 v5.5.0
)
```

## Test Structure

### internal/handlers/health_test.go
```go
package handlers

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestHealthCheck(t *testing.T) {
    req := httptest.NewRequest("GET", "/health", nil)
    w := httptest.NewRecorder()

    HealthCheck(w, req)

    if w.Code != http.StatusOK {
        t.Errorf("expected status 200, got %d", w.Code)
    }

    var resp HealthResponse
    if err := json.NewDecoder(w.Body).Decode(&resp); err != nil {
        t.Fatalf("failed to decode response: %v", err)
    }

    if resp.Status != "healthy" {
        t.Errorf("expected status 'healthy', got '%s'", resp.Status)
    }
}

func BenchmarkHealthCheck(b *testing.B) {
    for i := 0; i < b.N; i++ {
        req := httptest.NewRequest("GET", "/health", nil)
        w := httptest.NewRecorder()
        HealthCheck(w, req)
    }
}
```

## Makefile

```makefile
.PHONY: build test lint clean docker

BINARY_NAME=app
VERSION=$(shell git describe --tags --always)

build:
	go build -ldflags "-X main.Version=$(VERSION)" -o bin/$(BINARY_NAME) ./cmd/main.go

test:
	go test -v -race -coverprofile=coverage.out ./...

test-coverage:
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

lint:
	golangci-lint run

fmt:
	gofmt -l -w .

vet:
	go vet ./...

clean:
	rm -rf bin/ coverage.* *.out

docker-build:
	docker build -t $(BINARY_NAME):$(VERSION) .

docker-run:
	docker run -p 8080:8080 $(BINARY_NAME):$(VERSION)

.DEFAULT_GOAL := build
```

## CI/CD Best Practices Implemented

- **Multi-version testing** across Go versions
- **Race condition detection** with `-race` flag
- **Code coverage** tracking and reporting
- **Security scanning** with Gosec
- **Linting** with golangci-lint
- **Format checking** with gofmt
- **Module integrity** verification
- **Benchmarking** for performance tracking
- **Docker optimization** with multi-stage builds
- **Health checks** for container readiness
- **Graceful shutdown** handling
- **Structured logging** with slog
- **Cross-compilation** support
