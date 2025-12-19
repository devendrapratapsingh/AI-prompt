# Node.js Express CI/CD Pipeline - GitLab CI Example

## Overview
This example demonstrates a complete CI/CD pipeline for a Node.js Express microservice using GitLab CI/CD with Docker, MongoDB, Redis, and Kubernetes deployment.

## Complete Pipeline Configuration

```yaml
# .gitlab-ci.yml
variables:
  NODE_VERSION: "18"
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  MONGODB_VERSION: "6.0"
  REDIS_VERSION: "7"

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
  image: node:$NODE_VERSION
  before_script:
    - node --version
    - npm --version
  script:
    - npm ci
    - npm run build
    - echo "Build completed successfully"
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - node_modules/
      - .npm/
  artifacts:
    paths:
      - dist/
      - node_modules/
      - package.json
      - package-lock.json
    expire_in: 1 hour

# Unit tests
test:unit:
  stage: test
  image: node:$NODE_VERSION
  services:
    - name: mongo:$MONGODB_VERSION
      alias: mongodb
    - name: redis:$REDIS_VERSION
      alias: redis
  variables:
    MONGODB_URI: mongodb://mongodb:27017/testdb
    REDIS_URL: redis://redis:6379
  before_script:
    - npm ci
  script:
    - npm run test:unit -- --coverage --ci --reporters=default --reporters=jest-junit
    - npm run test:coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
    paths:
      - coverage/
      - junit.xml
    expire_in: 1 week
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - node_modules/
      - .npm/

# Integration tests
test:integration:
  stage: test
  image: node:$NODE_VERSION
  services:
    - name: mongo:$MONGODB_VERSION
      alias: mongodb
    - name: redis:$REDIS_VERSION
      alias: redis
  variables:
    MONGODB_URI: mongodb://mongodb:27017/testdb
    REDIS_URL: redis://redis:6379
    NODE_ENV: test
  before_script:
    - npm ci
  script:
    - npm run test:integration -- --ci
    - echo "Integration tests passed"
  artifacts:
    when: always
    paths:
      - test-results/
    expire_in: 1 week
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - node_modules/

# E2E tests
test:e2e:
  stage: test
  image: node:$NODE_VERSION
  services:
    - name: mongo:$MONGODB_VERSION
      alias: mongodb
    - name: redis:$REDIS_VERSION
      alias: redis
  variables:
    MONGODB_URI: mongodb://mongodb:27017/testdb
    REDIS_URL: redis://redis:6379
    NODE_ENV: test
  before_script:
    - npm ci
  script:
    - npm start &
    - sleep 10
    - npm run test:e2e
    - kill %1 || true
  artifacts:
    when: always
    paths:
      - e2e-results/
    expire_in: 1 week

# Code quality - ESLint
quality:eslint:
  stage: quality
  image: node:$NODE_VERSION
  before_script:
    - npm ci
  script:
    - npm run lint
    - npm run lint:report || true
  artifacts:
    reports:
      codequality: eslint-report.json
    paths:
      - eslint-report.json
    expire_in: 1 week
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - node_modules/
  allow_failure: true

# Code quality - Prettier
quality:prettier:
  stage: quality
  image: node:$NODE_VERSION
  before_script:
    - npm ci
  script:
    - npm run format:check
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - node_modules/
  allow_failure: true

# Code quality - TypeScript
quality:typescript:
  stage: quality
  image: node:$NODE_VERSION
  before_script:
    - npm ci
  script:
    - npm run type-check
  cache:
    key: ${CI_COMMIT_REF_SLUG}-node
    paths:
      - node_modules/
  allow_failure: true

# Security - Dependency audit
security:dependencies:
  stage: security
  image: node:$NODE_VERSION
  before_script:
    - npm ci
  script:
    - npm audit --audit-level=high || true
    - npm audit --json > npm-audit.json || true
  artifacts:
    paths:
      - npm-audit.json
    reports:
      dependency_scanning: npm-audit.json
    expire_in: 1 week
  allow_failure: true

# Security - SAST
security:sast:
  stage: security
  image: node:$NODE_VERSION
  before_script:
    - npm install -g snyk eslint-plugin-security
    - npm ci
  script:
    - snyk test --json > snyk-report.json || true
    - eslint . --ext .js,.ts --format json -o eslint-security.json || true
  artifacts:
    paths:
      - snyk-report.json
      - eslint-security.json
    reports:
      sast: snyk-report.json
    expire_in: 1 week
  allow_failure: true

# Security - Secret detection
security:secrets:
  stage: security
  image: node:$NODE_VERSION
  before_script:
    - npm install -g detect-secrets
  script:
    - detect-secrets scan . || true
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
    - kubectl create namespace express-dev || true
    - |
      cat <<EOF | kubectl apply -f -
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: express-app
        namespace: express-dev
      spec:
        replicas: 2
        selector:
          matchLabels:
            app: express
        template:
          metadata:
            labels:
              app: express
          spec:
            containers:
            - name: express
              image: $IMAGE_TAG
              ports:
              - containerPort: 3000
              env:
              - name: NODE_ENV
                value: "development"
              - name: MONGODB_URI
                valueFrom:
                  secretKeyRef:
                    name: express-secrets
                    key: mongodb-uri
              - name: REDIS_URL
                valueFrom:
                  secretKeyRef:
                    name: express-secrets
                    key: redis-url
              livenessProbe:
                httpGet:
                  path: /health
                  port: 3000
                initialDelaySeconds: 30
                periodSeconds: 10
              readinessProbe:
                httpGet:
                  path: /ready
                  port: 3000
                initialDelaySeconds: 5
                periodSeconds: 5
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: express-service
        namespace: express-dev
      spec:
        selector:
          app: express
        ports:
        - port: 80
          targetPort: 3000
        type: LoadBalancer
      EOF
    - kubectl rollout status deployment/express-app -n express-dev
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
    - kubectl create namespace express-staging || true
    - kubectl apply -f k8s/staging/ -n express-staging
    - kubectl set image deployment/express-app express=$IMAGE_TAG -n express-staging
    - kubectl rollout status deployment/express-app -n express-staging
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
    - kubectl create namespace express-prod || true
    - kubectl apply -f k8s/production/ -n express-prod
    - kubectl set image deployment/express-app express=$IMAGE_TAG -n express-prod
    - kubectl rollout status deployment/express-app -n express-prod
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
    - kubectl delete namespace express-dev --ignore-not-found=true
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
    - kubectl delete namespace express-staging --ignore-not-found=true
  when: manual
```

## Project Structure

```
express-project/
├── src/
│   ├── index.ts
│   ├── app.ts
│   ├── config/
│   │   ├── database.ts
│   │   └── redis.ts
│   ├── controllers/
│   │   └── userController.ts
│   ├── models/
│   │   └── User.ts
│   ├── routes/
│   │   ├── index.ts
│   │   ├── users.ts
│   │   └── health.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── errorHandler.ts
│   │   └── logger.ts
│   └── services/
│       └── userService.ts
├── tests/
│   ├── unit/
│   │   └── services.test.ts
│   ├── integration/
│   │   └── database.test.ts
│   └── e2e/
│       └── api.test.ts
├── k8s/
│   ├── staging/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── production/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
├── dist/
├── Dockerfile
├── package.json
├── tsconfig.json
├── .gitlab-ci.yml
├── .eslintrc.js
└── README.md
```

## Dockerfile

```dockerfile
FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production image
FROM node:18-alpine

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

# Copy built application
COPY --from=builder --chown=appuser:appuser /app/dist ./dist
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser package*.json ./

USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Run application with dumb-init
CMD ["dumb-init", "node", "dist/index.js"]
```

## Application Code

### src/app.ts

```typescript
import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import routes from './routes';
import { errorHandler } from './middleware/errorHandler';
import { connectDatabase } from './config/database';
import { connectRedis } from './config/redis';

const app: Application = express();

// Security middleware
app.use(helmet());
app.use(cors());

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Compression
app.use(compression());

// Logging
app.use(morgan('combined'));

// Routes
app.use('/api/v1', routes);

// Error handling
app.use(errorHandler);

// Initialize connections
export const initializeApp = async (): Promise<void> => {
  await connectDatabase();
  await connectRedis();
};

export default app;
```

### src/index.ts

```typescript
import app, { initializeApp } from './app';

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await initializeApp();
    
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
```

### src/routes/health.ts

```typescript
import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { redisClient } from '../config/redis';

const router = Router();

router.get('/health', async (req: Request, res: Response) => {
  try {
    // Check MongoDB
    const dbState = mongoose.connection.readyState;
    const dbStatus = dbState === 1 ? 'connected' : 'disconnected';
    
    // Check Redis
    const redisStatus = redisClient.isReady ? 'connected' : 'disconnected';
    
    if (dbState === 1 && redisClient.isReady) {
      res.status(200).json({
        status: 'healthy',
        database: dbStatus,
        cache: redisStatus,
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(503).json({
        status: 'unhealthy',
        database: dbStatus,
        cache: redisStatus,
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

router.get('/ready', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'ready',
    timestamp: new Date().toISOString()
  });
});

export default router;
```

## package.json

```json
{
  "name": "express-api",
  "version": "1.0.0",
  "description": "Production-ready Express API",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node-dev --respawn src/index.ts",
    "test": "jest",
    "test:unit": "jest --testPathPattern=tests/unit",
    "test:integration": "jest --testPathPattern=tests/integration",
    "test:e2e": "jest --testPathPattern=tests/e2e",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:report": "eslint src/**/*.ts --format json -o eslint-report.json",
    "format": "prettier --write \"src/**/*.ts\"",
    "format:check": "prettier --check \"src/**/*.ts\"",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "morgan": "^1.10.0",
    "mongoose": "^8.0.3",
    "redis": "^4.6.12",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^20.10.6",
    "@types/jest": "^29.5.11",
    "typescript": "^5.3.3",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "eslint": "^8.56.0",
    "prettier": "^3.1.1",
    "@typescript-eslint/eslint-plugin": "^6.17.0",
    "@typescript-eslint/parser": "^6.17.0",
    "eslint-plugin-security": "^2.1.0"
  }
}
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
- Unit tests with Jest
- Integration tests for database
- E2E API tests
- Code coverage reporting

### 2. Code Quality
- ESLint for linting
- Prettier for formatting
- TypeScript type checking
- Security plugins

### 3. Security
- Dependency auditing
- SAST with Snyk
- Secret detection
- Container scanning with Trivy

### 4. Multi-Environment
- Development auto-deploy
- Staging manual deploy
- Production manual deploy with approval

### 5. Container Orchestration
- Kubernetes deployment
- Health and readiness probes
- Load balancing
- Service discovery

## Running Locally

```bash
# Install dependencies
npm install

# Run tests
npm test
npm run test:coverage

# Start development server
npm run dev

# Build for production
npm run build

# Lint code
npm run lint

# Format code
npm run format
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
