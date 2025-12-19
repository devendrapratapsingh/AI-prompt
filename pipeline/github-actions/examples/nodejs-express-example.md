# Node.js Express CI/CD Pipeline - GitHub Actions Example

## Overview
This example demonstrates a complete CI/CD pipeline for a Node.js Express application using GitHub Actions.

## Complete Pipeline Configuration

```yaml
name: Node.js CI/CD

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
        node-version: [16.x, 18.x, 20.x]
    
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
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4
      
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint code
        run: npm run lint
      
      - name: Check formatting
        run: npm run format:check

  test:
    runs-on: ubuntu-latest
    needs: build
    
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
      
      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4
      
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
          REDIS_URL: redis://localhost:6379
        run: npm run test:unit -- --coverage
      
      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
          REDIS_URL: redis://localhost:6379
        run: npm run test:integration
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  security:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - uses: actions/checkout@v4
      
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: npm audit
        run: npm audit --production --audit-level=moderate || true
      
      - name: Run SNYK security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

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
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["node", "index.js"]
```

## Express Application Structure

### index.js
```javascript
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const logger = require('pino')();

const app = express();
app.use(express.json());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://localhost/myapp'
});

// Redis connection
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

// Middleware
app.use((req, res, next) => {
  req.id = Math.random().toString(36).substr(2, 9);
  logger.info({ requestId: req.id, method: req.method, path: req.path });
  next();
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy' });
  } catch (err) {
    logger.error({ error: err.message });
    res.status(503).json({ status: 'unhealthy' });
  }
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  try {
    const result = await pool.query('SELECT COUNT(*) FROM users');
    res.json({ users: result.rows[0].count });
  } catch (err) {
    logger.error({ error: err.message });
    res.status(500).json({ error: 'Failed to fetch metrics' });
  }
});

// Error handling
app.use((err, req, res, next) => {
  logger.error({ error: err.message, requestId: req.id });
  res.status(err.status || 500).json({ error: err.message });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  await pool.end();
  redisClient.quit();
  process.exit(0);
});
```

## Package.json

```json
{
  "name": "express-app",
  "version": "1.0.0",
  "description": "Express CI/CD Example",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test:unit": "jest tests/unit --detectOpenHandles",
    "test:integration": "jest tests/integration --detectOpenHandles",
    "test": "npm run test:unit && npm run test:integration",
    "lint": "eslint .",
    "format:check": "prettier --check .",
    "format": "prettier --write ."
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.10.0",
    "redis": "^4.6.10",
    "pino": "^8.16.1",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.53.0",
    "prettier": "^3.1.0",
    "nodemon": "^3.0.1"
  }
}
```

## Test Structure

### tests/unit/app.test.js
```javascript
const request = require('supertest');
const app = require('../../index');

describe('Health Check', () => {
  test('GET /health returns 200', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'healthy');
  });
});

describe('Metrics', () => {
  test('GET /metrics returns user count', async () => {
    const response = await request(app).get('/metrics');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('users');
  });
});
```

## ESLint Configuration

### .eslintrc.json
```json
{
  "env": {
    "node": true,
    "es2021": true,
    "jest": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "no-console": ["warn"]
  }
}
```

## Environment Variables (.env.example)

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp
REDIS_URL=redis://localhost:6379
NODE_ENV=development
PORT=3000
LOG_LEVEL=info
```

## CI/CD Best Practices Implemented

- **Matrix testing** across multiple Node versions
- **Comprehensive test suite** (unit + integration)
- **Code linting** with ESLint
- **Code formatting** with Prettier
- **Dependency vulnerability** scanning
- **Coverage reporting** to Codecov
- **Docker optimization** with multi-stage builds
- **Health checks** for deployment verification
- **Graceful shutdown** handling
- **Structured logging** with Pino
