# Google Cloud Build - Complete Enterprise-Grade CI/CD Guide

## Overview

Google Cloud Build is a serverless CI/CD platform on Google Cloud Platform that executes builds on Google-managed infrastructure. It integrates with Cloud Source Repositories, GitHub, Bitbucket, and supports deployment to GKE, Cloud Run, and other GCP services.

### Key Capabilities
- **Serverless**: No infrastructure to manage or provision
- **Multi-Language Support**: Java, Python, Node.js, Go, Docker, and more
- **GCP Integration**: Tight integration with Cloud Run, GKE, Cloud Deploy
- **Flexible Triggers**: GitHub, Bitbucket, Cloud Source, manual, scheduled
- **Private Pools**: Dedicated build capacity for security-sensitive workloads
- **Build Caching**: Automatic caching of build steps and layers
- **Security**: VPC-SC integration, service account isolation, secret management
- **Parallel Execution**: Multiple build steps in parallel
- **Cost Optimization**: Pay per build minute, free tier available

## Prerequisites

- Google Cloud Project with billing enabled
- Source repository (GitHub, Bitbucket, or Cloud Source)
- gcloud CLI installed and configured
- kubectl (for Kubernetes deployments)

## System Requirements

### GCP Resources
- Cloud Build API enabled
- Compute quotas available
- Service account with appropriate permissions
- Cloud Storage bucket for artifacts

### Build Environment
- Docker-based executors
- Build timeout: 24 hours maximum
- Memory: 2-100 GB (standard: 4 GB)
- vCPU: 0.6-8 cores

## Installation & Setup

### Step 1: Enable APIs

```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable container.googleapis.com
```

### Step 2: Create Service Account

```bash
# Create service account
gcloud iam service-accounts create cloud-build-sa \
  --display-name="Cloud Build Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:cloud-build-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/cloudbuild.builds.editor

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:cloud-build-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/container.developer
```

### Step 3: Create cloudbuild.yaml

```yaml
steps:
  # Build step
  - name: 'gcr.io/cloud-builders/npm'
    args: ['ci']

  # Test step
  - name: 'gcr.io/cloud-builders/npm'
    args: ['run', 'test']

  # Build Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA', '.']

  # Push to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA']

# Artifact storage
artifacts:
  objects:
    location: gs://my-artifacts/$COMMIT_SHA
    paths: ['dist/**/*']

# Build images
images:
  - 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
  - 'gcr.io/$PROJECT_ID/myapp:latest'

# Build options
options:
  machineType: 'N1_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY
  pool:
    name: 'projects/$PROJECT_ID/locations/us-central1/workerPools/private-pool'

# Build timeout
timeout: '1800s'

# Substitutions
substitutions:
  _REGION: 'us-central1'
  _SERVICE_NAME: 'myapp'
```

### Step 4: Create Build Trigger

```bash
gcloud builds connect github \
  --repository-owner=myorg \
  --repository-name=myrepo \
  --branch-pattern='^main$'
```

## Configuration Walkthrough

### cloudbuild.yaml Structure

```yaml
# Define build steps
steps:
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args:
      - run
      - --filename=k8s/
      - --image=gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA
      - --location=us-central1
      - --cluster=my-cluster

# Define images to build
images:
  - gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA
  - gcr.io/$PROJECT_ID/myapp:latest

# Build options
options:
  machineType: 'N1_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY
  substitutionOption: 'ALLOW_LOOSE'

# Substitutions
substitutions:
  _SLACK_CHANNEL: '#deployments'
  _NOTIFICATION_EMAIL: 'ops@example.com'

# Build timeout
timeout: '3600s'
```

### Cloud Build Substitutions

```yaml
substitutions:
  _REGION: us-central1
  _SERVICE: myapp

steps:
  - name: gcr.io/cloud-builders/gke-deploy
    env:
      - 'CLOUDSDK_COMPUTE_ZONE=${_REGION}'
      - 'CLOUDSDK_CONTAINER_CLUSTER=${_SERVICE}-cluster'
```

## CI/CD Pipeline Stages

### Basic Pipeline

```yaml
steps:
  # Stage 1: Build
  - name: 'gcr.io/cloud-builders/npm'
    id: 'build'
    args: ['run', 'build']

  # Stage 2: Test
  - name: 'gcr.io/cloud-builders/npm'
    id: 'test'
    waitFor: ['build']
    args: ['run', 'test', '--', '--coverage']

  # Stage 3: Quality
  - name: 'gcr.io/cloud-builders/npm'
    id: 'quality'
    waitFor: ['build']
    args: ['run', 'lint']

  # Stage 4: Security
  - name: 'gcr.io/cloud-builders/npm'
    id: 'security'
    waitFor: ['build']
    args: ['audit', '--audit-level=moderate']

  # Stage 5: Build Docker
  - name: 'gcr.io/cloud-builders/docker'
    id: 'docker-build'
    args:
      - 'build'
      - '-t'
      - 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
      - '-t'
      - 'gcr.io/$PROJECT_ID/myapp:latest'
      - '.'

  # Stage 6: Push to Registry
  - name: 'gcr.io/cloud-builders/docker'
    id: 'docker-push'
    waitFor: ['docker-build']
    args:
      - 'push'
      - 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'

  # Stage 7: Deploy to Cloud Run
  - name: 'gcr.io/cloud-builders/run'
    id: 'deploy-run'
    waitFor: ['docker-push']
    args:
      - deploy
      - myapp
      - '--image=gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
      - '--region=us-central1'
      - '--platform=managed'
      - '--allow-unauthenticated'

  # Stage 8: Deploy to GKE
  - name: 'gcr.io/cloud-builders/gke-deploy'
    id: 'deploy-gke'
    waitFor: ['docker-push']
    args:
      - run
      - '--filename=k8s/'
      - '--image=gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
      - '--location=us-central1'
      - '--cluster=my-cluster'

images:
  - 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
  - 'gcr.io/$PROJECT_ID/myapp:latest'

timeout: '3600s'
```

### Deployment to GKE

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA', '.']

  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA']

  - name: 'gcr.io/cloud-builders/kubectl'
    env:
      - 'CLOUDSDK_COMPUTE_ZONE=us-central1-a'
      - 'CLOUDSDK_CONTAINER_CLUSTER=my-cluster'
    args:
      - 'set'
      - 'image'
      - 'deployment'
      - 'myapp'
      - 'myapp=gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
      - '-n'
      - 'production'

  - name: 'gcr.io/cloud-builders/kubectl'
    env:
      - 'CLOUDSDK_COMPUTE_ZONE=us-central1-a'
      - 'CLOUDSDK_CONTAINER_CLUSTER=my-cluster'
    args:
      - 'rollout'
      - 'status'
      - 'deployment'
      - 'myapp'
      - '-n'
      - 'production'

images:
  - 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
```

### Deployment to Cloud Run

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA', '.']

  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA']

  - name: 'gcr.io/cloud-builders/run'
    args:
      - 'deploy'
      - 'myapp'
      - '--image=gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
      - '--region=us-central1'
      - '--platform=managed'
      - '--allow-unauthenticated'
      - '--port=8080'
      - '--memory=512Mi'
      - '--cpu=1'
```

## Advanced Features

### Private Pools

```bash
# Create private pool
gcloud builds worker-pools create my-private-pool \
  --project=PROJECT_ID \
  --region=us-central1 \
  --peered-network=projects/myproject/global/networks/default
```

### Build Caching

```yaml
steps:
  - name: 'gcr.io/cloud-builders/npm'
    args: ['ci']
    volumes:
      - name: 'npm_cache'
        path: '/root/.npm'

volumes:
  - name: 'npm_cache'
    path: '/workspace/npm-cache'
```

### Secret Management

```bash
# Create secret
echo "my-secret-value" | gcloud secrets create my-secret --data-file=-

# Grant build service account access
gcloud secrets add-iam-policy-binding my-secret \
  --member=serviceAccount:PROJECT_ID@cloudbuild.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor
```

Use in build:
```yaml
steps:
  - name: 'gcr.io/cloud-builders/npm'
    secretEnv: ['MY_SECRET']
    args: ['run', 'deploy']

secrets:
  - kmsKeyName: projects/PROJECT_ID/locations/us/keyRings/my-ring/cryptoKeys/my-key
    secretEnv:
      MY_SECRET:
        ciphertext: |
          CiQ...==
```

## Monitoring and Notifications

### Cloud Build Insights

```bash
# View build history
gcloud builds list --project=PROJECT_ID

# View build details
gcloud builds log BUILD_ID --stream

# View build metrics
gcloud builds describe BUILD_ID
```

### Slack Notifications

```yaml
steps:
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: bash
    args:
      - -c
      - |
        SLACK_URL="${_SLACK_WEBHOOK}"
        BUILD_STATUS="${BUILD_STATUS}"
        curl -X POST "$SLACK_URL" \
          -H 'Content-Type: application/json' \
          -d '{"text":"Build '"$BUILD_ID"' status: '"$BUILD_STATUS"'"}'
```

## Security Best Practices

### VPC-SC Integration

```yaml
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'N1_HIGHCPU_8'

steps:
  - name: 'gcr.io/cloud-builders/gke-deploy'
    env:
      - 'VPC_SC_PERIMETER=projects/PROJECT_ID/locations/global/accessContextManagers/ACCESS_CONTEXT_MANAGER_ID/accessLevels/my_level'
```

## Troubleshooting

### Build Failures

```bash
# Check build logs
gcloud builds log BUILD_ID --stream

# View build details
gcloud builds describe BUILD_ID

# Check service account permissions
gcloud projects get-iam-policy PROJECT_ID --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:*@cloudbuild.gserviceaccount.com"
```

## FAQ

**Q: How do I use custom builders?**
A: Push custom Docker images to Container Registry and reference in steps.

**Q: Can I run builds in parallel?**
A: Yes, use waitFor field to control step dependencies.

**Q: What's the maximum build timeout?**
A: 24 hours (86400 seconds).

**Q: How do I cache dependencies?**
A: Use volumes or custom caching strategies.

## Resources

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Build Configuration](https://cloud.google.com/build/docs/build-config)
- [Cloud Build Quickstart](https://cloud.google.com/build/docs/quickstart-build)
- [Cloud Deploy Guide](https://cloud.google.com/deploy/docs)
