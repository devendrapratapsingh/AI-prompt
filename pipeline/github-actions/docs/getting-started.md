# GitHub Actions - Getting Started Guide

## Quick Start (5-10 minutes)

### Step 1: Create Your First Workflow File (2 min)

1. In your repository, create `.github/workflows/` directory:
```bash
mkdir -p .github/workflows
```

2. Create `hello-world.yml`:
```yaml
name: Hello World

on: push

jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - name: Say Hello
        run: echo "Hello, GitHub Actions!"
```

3. Commit and push:
```bash
git add .github/workflows/hello-world.yml
git commit -m "Add hello world workflow"
git push origin main
```

### Step 2: View Your Workflow (1 min)

1. Go to your GitHub repository
2. Click "Actions" tab
3. Click on the workflow run
4. Expand "Say Hello" to see the output

### Step 3: Add Checkout Step (1 min)

```yaml
name: Build and Test

on: 
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      # Check out repository code
      - uses: actions/checkout@v4
      
      # Run a simple script
      - name: Display file structure
        run: ls -la
```

### Step 4: Set Up Your Language (2 min)

**For Node.js:**
```yaml
- name: Set up Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18'
    cache: 'npm'

- name: Install dependencies
  run: npm ci

- name: Run tests
  run: npm test
```

**For Python:**
```yaml
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.11'
    cache: 'pip'

- name: Install dependencies
  run: pip install -r requirements.txt

- name: Run tests
  run: pytest
```

**For Go:**
```yaml
- name: Set up Go
  uses: actions/setup-go@v4
  with:
    go-version: '1.21'

- name: Build
  run: go build ./...

- name: Test
  run: go test -v ./...
```

**For Java:**
```yaml
- name: Set up JDK
  uses: actions/setup-java@v4
  with:
    java-version: '17'
    distribution: 'temurin'
    cache: maven

- name: Build with Maven
  run: mvn -B verify
```

## First Pipeline Creation

### Basic 3-Stage Pipeline

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # Stage 1: Build
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up environment
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Build
        run: |
          npm ci
          npm run build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/

  # Stage 2: Test
  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up environment
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Run tests
        run: |
          npm ci
          npm test

  # Stage 3: Deploy
  deploy:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: build
      
      - name: Deploy
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          echo "Deploying to production..."
          # Add your deployment commands here
```

## Testing Locally

### Using act (recommended)

Install act to run workflows locally:

**macOS:**
```bash
brew install act
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
```

Run a workflow locally:
```bash
# Run all workflows
act

# Run specific workflow
act -j test

# Run with specific OS
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:full-latest

# See what would run without executing
act -l
```

### Using Docker (alternative)

```bash
# Run workflow in Docker
docker run --rm -v $(pwd):/workspace -w /workspace ghcr.io/catthehacker/ubuntu:full-latest bash .github/workflows/build.yml
```

## Testing Secrets Locally

Create `.env.local`:
```
SECRET_KEY=your-secret-value
DATABASE_URL=postgresql://localhost/test
```

Then in your workflow test:
```yaml
- name: Test with secrets
  env:
    SECRET_KEY: ${{ secrets.SECRET_KEY }}
  run: npm test
```

### Using Nektos Act with Secrets

```bash
act -s SECRET_KEY=value -s DATABASE_URL=postgresql://localhost/test
```

## Troubleshooting Common Issues

### Issue 1: Workflow not triggering

**Symptoms:** Workflow file created but doesn't run

**Solutions:**
1. Verify YAML syntax (GitHub will show errors in UI)
2. Check branch name matches trigger conditions
3. Ensure file is in `.github/workflows/` directory
4. Check that workflow name doesn't use special characters

**Debug:**
```bash
# Validate YAML
cat .github/workflows/ci.yml | yq eval '.' -
```

### Issue 2: Permission denied errors

**Symptoms:** `Error: Process completed with exit code 1`

**Solutions:**
1. Check `permissions` field in workflow
2. Ensure GITHUB_TOKEN has correct scopes
3. Use `actions/setup-` actions to configure tools

**Example fix:**
```yaml
permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
```

### Issue 3: Cache not working

**Symptoms:** Dependencies downloaded every time

**Solutions:**
1. Verify cache key matches your dependency file
2. Check cache path is correct
3. Clear cache manually if needed (GitHub Actions settings)

**Example fix:**
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

### Issue 4: Job timeout

**Symptoms:** `The operation timed out.`

**Solutions:**
1. Set `timeout-minutes` on job
2. Optimize slow steps
3. Use parallelization with strategy.matrix

**Example fix:**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    strategy:
      matrix:
        test-suite: [unit, integration, e2e]
    steps:
      - run: npm run test:${{ matrix.test-suite }}
```

### Issue 5: Out of disk space

**Symptoms:** `No space left on device`

**Solutions:**
1. Remove unnecessary files in steps
2. Use `docker system prune`
3. Upload artifacts only when needed

**Example fix:**
```yaml
- name: Free disk space
  run: |
    sudo rm -rf /usr/local/lib/android
    sudo rm -rf /usr/share/dotnet
    sudo docker image prune -a --force
```

## Debugging Tips

### Enable Debug Logging

```yaml
env:
  RUNNER_DEBUG: 1
```

This shows all shell commands executed and their output.

### Print Environment Variables

```yaml
- name: Print env vars
  run: env | sort
```

### Add Step Output Variables

```yaml
- name: Set output
  id: version
  run: echo "version=1.0.0" >> $GITHUB_OUTPUT

- name: Use output
  run: echo ${{ steps.version.outputs.version }}
```

### Use Step Conditions

```yaml
- name: Only on failure
  if: failure()
  run: echo "Previous step failed"

- name: Only on success
  if: success()
  run: echo "All previous steps succeeded"

- name: Always run
  if: always()
  run: echo "This always runs"
```

## Next Steps

1. **Add code quality checks**: Lint, format, test coverage
2. **Add security scanning**: Dependency checks, SAST
3. **Add deployment**: Push to Docker registry, deploy to cloud
4. **Add notifications**: Slack, email on failures
5. **Add performance monitoring**: Track build times, test results

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [act - Local Workflow Runner](https://github.com/nektos/act)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/guides)
