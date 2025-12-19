# Jenkins - Complete Enterprise-Grade CI/CD Guide

## Overview

Jenkins is the leading open-source automation server with extensive plugin ecosystem for CI/CD. It supports distributed builds, complex pipelines, and integrations with virtually every tool in the DevOps ecosystem.

### Key Capabilities
- **Open-Source**: Free, self-hosted, fully customizable
- **Pipeline as Code**: Declarative and Scripted pipelines
- **Distributed**: Master-agent architecture for scalability
- **Plugin Ecosystem**: 1000+ plugins for integrations
- **Security**: Role-based access, credential management, audit logs
- **Kubernetes**: Native Kubernetes plugin for container orchestration
- **Docker**: Docker plugin, Docker pipeline, Docker agents
- **Declarative Pipeline**: Simple, readable pipeline syntax
- **High Availability**: Clustering support for resilience
- **Backup & Restore**: Job configuration versioning

## Prerequisites

- Java 11+ installed
- Linux, Windows, or macOS for master
- For agents: Linux, Windows, macOS, Docker, Kubernetes
- Git installed
- For plugins: access to Jenkins Update Center

## System Requirements

### Master Server
- **Minimum**: 2 GB RAM, 2 CPU cores, 50GB disk
- **Recommended**: 8+ GB RAM, 4+ cores, 200GB+ disk for production
- **OS**: Linux (Ubuntu 20.04+), Windows Server 2019+, macOS 10.14+
- **Java**: OpenJDK 11 or later

### Agent Nodes
- **Minimum**: 1 GB RAM, 1 CPU core
- **Network**: Outbound TCP to master on agent port

## Installation & Setup

### Step 1: Install Jenkins

**Ubuntu/Debian:**
```bash
# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install
sudo apt-get update
sudo apt-get install jenkins

# Start service
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

**Docker:**
```bash
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  --name jenkins \
  jenkins/jenkins:lts
```

### Step 2: Initial Configuration

1. Go to http://localhost:8080
2. Unlock Jenkins with initial admin password
3. Install suggested plugins
4. Create first admin user
5. Configure Jenkins URL

### Step 3: Create Pipeline Job

```groovy
pipeline {
    agent any
    
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        NODE_ENV = 'production'
        BUILD_TIMESTAMP = sh(script: "date '+%Y%m%d_%H%M%S'", returnStdout: true).trim()
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building application..."
                    sh 'npm ci'
                    sh 'npm run build'
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit -- --coverage'
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
            }
        }
        
        stage('Code Quality') {
            steps {
                sh 'npm run lint'
                publishHTML([
                    reportDir: 'coverage',
                    reportFiles: 'index.html',
                    reportName: 'Code Coverage'
                ])
            }
        }
        
        stage('Security') {
            steps {
                sh 'npm audit --audit-level=moderate || true'
            }
        }
        
        stage('Deploy Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Deploying to staging..."
                    sh './scripts/deploy.sh staging'
                }
            }
        }
        
        stage('Deploy Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
            }
            steps {
                script {
                    echo "Deploying to production..."
                    sh './scripts/deploy.sh production'
                }
            }
        }
    }
    
    post {
        always {
            junit 'test-results.xml'
            archive 'dist/**'
        }
        
        failure {
            emailext(
                subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed. Log: ${env.BUILD_URL}console",
                to: '${DEFAULT_RECIPIENTS}'
            )
        }
        
        success {
            script {
                if (env.BRANCH_NAME == 'main') {
                    build job: 'Post-Deploy-Smoke-Tests',
                        parameters: [
                            string(name: 'BUILD_NUMBER', value: "${env.BUILD_NUMBER}")
                        ]
                }
            }
        }
    }
}
```

## Advanced Features

### Shared Libraries

Create Jenkins shared library for reusable pipeline code:

```groovy
// vars/deployApp.groovy
def call(String environment) {
    echo "Deploying to ${environment}..."
    sh "./scripts/deploy.sh ${environment}"
}
```

Use in pipeline:
```groovy
@Library('shared-library') _

pipeline {
    stages {
        stage('Deploy') {
            steps {
                script {
                    deployApp('production')
                }
            }
        }
    }
}
```

### Kubernetes Plugin

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
              apiVersion: v1
              kind: Pod
              spec:
                serviceAccountName: jenkins
                containers:
                - name: node
                  image: node:18-alpine
                  command:
                  - cat
                  tty: true
                - name: docker
                  image: docker:latest
                  securityContext:
                    privileged: true
            '''
        }
    }
    
    stages {
        stage('Build') {
            steps {
                container('node') {
                    sh 'npm ci && npm run build'
                }
            }
        }
        
        stage('Docker') {
            steps {
                container('docker') {
                    sh 'docker build -t myapp:$BUILD_NUMBER .'
                }
            }
        }
    }
}
```

### Docker Pipeline

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build("myapp:${env.BUILD_ID}")
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    docker.image("myapp:${env.BUILD_ID}").inside {
                        sh 'npm test'
                    }
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    docker.withRegistry('https://registry.example.com', 'docker-credentials') {
                        docker.image("myapp:${env.BUILD_ID}").push('latest')
                    }
                }
            }
        }
    }
}
```

## Security

### Credential Management

```groovy
pipeline {
    agent any
    
    environment {
        // Use Jenkins credentials
        DB_PASSWORD = credentials('db-password')
        DOCKER_CREDS = credentials('docker-registry')
    }
    
    stages {
        stage('Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'api-token', variable: 'API_TOKEN'),
                    file(credentialsId: 'ssh-key', variable: 'SSH_KEY')
                ]) {
                    sh '''
                        export API_TOKEN=$API_TOKEN
                        chmod 600 $SSH_KEY
                        ./deploy.sh
                    '''
                }
            }
        }
    }
}
```

### RBAC

In Jenkins UI:
1. Manage Jenkins → Configure Global Security
2. Enable Matrix Authorization
3. Add users and assign roles

## FAQ

**Q: How do I scale Jenkins?**
A: Use master-agent architecture or Kubernetes plugin.

**Q: What's the difference between Declarative and Scripted pipelines?**
A: Declarative is simpler and recommended; Scripted offers more flexibility.

**Q: How do I backup Jenkins?**
A: Backup $JENKINS_HOME directory and use plugins for config versioning.

**Q: Can I use Jenkins without plugins?**
A: Yes, but plugins are essential for modern CI/CD workflows.

## Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/)
- [Plugin Index](https://plugins.jenkins.io/)
- [Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)
