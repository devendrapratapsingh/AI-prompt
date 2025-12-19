# Tekton - Complete Kubernetes-Native CI/CD Guide

## Overview

Tekton is a cloud-native, open-source framework for creating CI/CD systems. It runs natively on Kubernetes and provides a flexible, powerful way to build, test, and deploy applications at scale.

### Key Capabilities
- **Kubernetes-Native**: Runs as Kubernetes Custom Resources
- **Cloud-Agnostic**: Works on any Kubernetes cluster
- **Serverless**: No dedicated infrastructure
- **Modular**: Reusable Tasks and Pipelines
- **Scalable**: Leverage Kubernetes for parallel execution
- **Type-Safe**: Full type validation
- **Open-Source**: Hosted on Cloud Native Computing Foundation
- **Community-Driven**: Large ecosystem of community tasks
- **Multi-Language**: Support for Java, Python, Node.js, Go, etc.

## Prerequisites

- Kubernetes cluster 1.17+
- kubectl configured
- Tekton CLI (tkn)
- Basic Kubernetes knowledge
- Container registry (Docker Hub, GCR, ECR)

## System Requirements

### Kubernetes Cluster
- Minimum: 2 nodes, 4 GB RAM per node
- Recommended: 3+ nodes, 8+ GB RAM for production
- Kubernetes 1.17 or later
- Container runtime (Docker, containerd, CRI-O)

## Installation & Setup

### Step 1: Install Tekton Pipeline

```bash
# Install Tekton Pipeline Controller
kubectl apply --filename \
  https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Install Tekton Triggers (optional)
kubectl apply --filename \
  https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Install Tekton Dashboard (optional)
kubectl apply --filename \
  https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml

# Verify installation
kubectl get pods -n tekton-pipelines
```

### Step 2: Create Tekton Tasks

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-app
spec:
  params:
    - name: image
      type: string
    - name: registry
      type: string
  steps:
    - name: npm-build
      image: node:18-alpine
      script: |
        #!/bin/sh
        set -e
        npm ci
        npm run build

    - name: docker-build
      image: docker:latest
      volumeMounts:
        - name: docker-socket
          mountPath: /var/run/docker.sock
      script: |
        #!/bin/sh
        docker build -t $(params.registry)/$(params.image):$BUILD_ID .
        docker push $(params.registry)/$(params.image):$BUILD_ID

  volumes:
    - name: docker-socket
      hostPath:
        path: /var/run/docker.sock
```

### Step 3: Create Tekton Pipeline

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: ci-cd-pipeline
spec:
  params:
    - name: repo-url
      type: string
    - name: repo-branch
      type: string
    - name: image-registry
      type: string

  workspaces:
    - name: workspace
    - name: docker-credentials

  tasks:
    # Clone repository
    - name: clone-repo
      taskRef:
        name: git-clone
      params:
        - name: url
          value: $(params.repo-url)
        - name: revision
          value: $(params.repo-branch)
      workspaces:
        - name: output
          workspace: workspace

    # Build
    - name: build
      taskRef:
        name: build-app
      params:
        - name: image
          value: myapp
        - name: registry
          value: $(params.image-registry)
      workspaces:
        - name: source
          workspace: workspace
      runAfter:
        - clone-repo

    # Test
    - name: test
      taskRef:
        name: run-tests
      workspaces:
        - name: source
          workspace: workspace
      runAfter:
        - build

    # Deploy
    - name: deploy
      taskRef:
        name: deploy-to-k8s
      workspaces:
        - name: source
          workspace: workspace
      runAfter:
        - test
```

### Step 4: Create Tekton EventListener

```yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-listener
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: github-push
      interceptors:
        - github:
            secretRef:
              secretKey: github-token
              secretName: github-secret
      bindings:
        - ref: github-binding
      template:
        ref: ci-pipeline-template

---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-binding
spec:
  params:
    - name: gitrepositoryurl
      value: $(body.repository.clone_url)
    - name: gitrevision
      value: $(body.after)

---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: ci-pipeline-template
spec:
  params:
    - name: gitrepositoryurl
    - name: gitrevision
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: ci-pipeline-run-
      spec:
        pipelineRef:
          name: ci-cd-pipeline
        params:
          - name: repo-url
            value: $(tt.params.gitrepositoryurl)
          - name: repo-branch
            value: $(tt.params.gitrevision)
        workspaces:
          - name: workspace
            volumeClaimTemplate:
              spec:
                accessModes:
                  - ReadWriteOnce
                resources:
                  requests:
                    storage: 1Gi
```

## Community Tasks

```bash
# Install community tasks from Tekton Hub
tkn hub install task git-clone
tkn hub install task npm
tkn hub install task docker-build
tkn hub install task kubernetes-deploy
```

## FAQ

**Q: How do I secure credentials in Tekton?**
A: Use Kubernetes Secrets and mount them in tasks

**Q: Can I run parallel tasks?**
A: Yes, use multiple tasks without dependencies

**Q: How do I debug a failed PipelineRun?**
A: Use `tkn pipelinerun logs` command

**Q: What's the maximum execution time?**
A: Configurable, default 1 hour

## Resources

- [Tekton Documentation](https://tekton.dev/docs/)
- [Tekton Catalog](https://hub.tekton.dev/)
- [Getting Started](https://tekton.dev/docs/getting-started/)
