# Java Spring Boot CI/CD Pipeline for GitLab CI

## Complete Production-Ready Pipeline

This example demonstrates a comprehensive CI/CD pipeline for a Spring Boot application using GitLab CI/CD, including build, test, security scanning, and deployment stages.

### Prerequisites
- GitLab CI/CD Runner configured with Docker support
- Java 11+ installed on runner
- Maven 3.6+ installed
- Docker registry credentials
- Kubernetes cluster for deployment (optional)

### Application Structure
```
spring-boot-app/
├── src/
│   ├── main/java/
│   ├── main/resources/
│   └── test/java/
├── pom.xml
├── Dockerfile
├── .gitlab-ci.yml
└── k8s/
```

### Pipeline Configuration (.gitlab-ci.yml)

```yaml
stages:
  - build
  - test
  - quality
  - security
  - deploy

variables:
  REGISTRY: registry.gitlab.com
  IMAGE_NAME: $CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME
  JAVA_VERSION: "17"
  MAVEN_OPTS: "-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

cache:
  key:
    files:
      - pom.xml
  paths:
    - .m2/repository
    - target/

# Build Stage
build:
  stage: build
  image: maven:3.9-eclipse-temurin-17
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn clean compile
    - mvn package -DskipTests -Dmaven.test.skip=true -Dmaven.javadoc.skip=true
  artifacts:
    paths:
      - target/*.jar
      - target/classes/
    expire_in: 1 day

# Unit Test Stage
unit-test:
  stage: test
  image: maven:3.9-eclipse-temurin-17
  needs: ["build"]
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn test -Dmaven.javadoc.skip=true
  artifacts:
    when: always
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
    paths:
      - target/surefire-reports/
  coverage: '/Coverage: (\d+\.\d+)%/'

# Integration Test Stage
integration-test:
  stage: test
  image: maven:3.9-eclipse-temurin-17
  needs: ["build"]
  services:
    - postgres:14
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn verify -DskipUnitTests
  artifacts:
    when: always
    paths:
      - target/failsafe-reports/
  allow_failure: true

# Code Quality Analysis
sonarqube-analysis:
  stage: quality
  image: maven:3.9-eclipse-temurin-17
  needs: ["build", "unit-test"]
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn sonar:sonar
      -Dsonar.projectKey=$CI_PROJECT_NAME
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.login=$SONAR_TOKEN
      -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
  allow_failure: true

# Code Coverage with JaCoCo
code-coverage:
  stage: quality
  image: maven:3.9-eclipse-temurin-17
  needs: ["unit-test"]
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn clean test jacoco:report
    - echo "Code Coverage Report:"
    - cat target/site/jacoco/index.html | grep "Total"
  artifacts:
    paths:
      - target/site/jacoco/
  coverage: '/\d+%/'

# Static Analysis
spotbugs-analysis:
  stage: quality
  image: maven:3.9-eclipse-temurin-17
  needs: ["build"]
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn spotbugs:check
  allow_failure: true

pmd-analysis:
  stage: quality
  image: maven:3.9-eclipse-temurin-17
  needs: ["build"]
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn pmd:check
  allow_failure: true

# Dependency Vulnerability Scan
dependency-check:
  stage: security
  image: maven:3.9-eclipse-temurin-17
  needs: ["build"]
  script:
    - export MAVEN_USER_HOME=`pwd`/.m2
    - mvn org.owasp:dependency-check-maven:check
  artifacts:
    paths:
      - target/dependency-check-report.html
  allow_failure: true

# SAST Security Scan
sast-scan:
  stage: security
  image: returntocorp/semgrep:latest
  needs: ["build"]
  script:
    - semgrep --json --output=semgrep-report.json src/
  artifacts:
    reports:
      sast: semgrep-report.json
  allow_failure: true

# Docker Build and Push
build-docker:
  stage: security
  image: docker:24-dind
  needs: ["build"]
  services:
    - docker:24-dind
  variables:
    DOCKER_HOST: tcp://docker:2375
    DOCKER_TLS_CERTDIR: ""
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - |
      if [ "$CI_COMMIT_BRANCH" = "main" ]; then
        docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
        docker push $CI_REGISTRY_IMAGE:latest
      fi
  after_script:
    - docker logout

# Container Image Scanning
container-scan:
  stage: security
  image: aquasec/trivy:latest
  needs: ["build-docker"]
  script:
    - trivy image --exit-code 0 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  allow_failure: true

# Deploy to Staging
deploy-staging:
  stage: deploy
  image: bitnami/kubectl:latest
  needs: ["build", "unit-test", "code-quality", "sast-scan"]
  environment:
    name: staging
    url: https://staging.example.com
    deployment_tier: staging
    kubernetes:
      namespace: staging
  script:
    - kubectl config use-context $KUBE_CONTEXT_STAGING
    - kubectl set image deployment/spring-boot-app spring-boot-app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n staging
    - kubectl rollout status deployment/spring-boot-app -n staging --timeout=5m
  only:
    - develop
  when: manual

# Deploy to Production
deploy-production:
  stage: deploy
  image: bitnami/kubectl:latest
  needs: ["build", "unit-test", "integration-test", "code-quality", "sast-scan"]
  environment:
    name: production
    url: https://app.example.com
    deployment_tier: production
    kubernetes:
      namespace: production
  script:
    - kubectl config use-context $KUBE_CONTEXT_PROD
    - kubectl set image deployment/spring-boot-app spring-boot-app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n production
    - kubectl rollout status deployment/spring-boot-app -n production --timeout=10m
    - kubectl run smoke-test --image=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n production --restart=Never --rm -i -- bash -c "curl http://localhost:8080/actuator/health"
  only:
    - main
  when: manual
```

### Maven pom.xml Configuration

Key plugins for CI/CD:

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>spring-boot-app</artifactId>
  <version>1.0.0</version>
  
  <properties>
    <java.version>17</java.version>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <spring-boot.version>3.1.0</spring-boot.version>
    <jacoco.version>0.8.10</jacoco.version>
  </properties>
  
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-dependencies</artifactId>
        <version>${spring-boot.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  
  <dependencies>
    <!-- Spring Boot Starters -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    
    <!-- Database -->
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>
    
    <!-- Testing -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <version>${spring-boot.version}</version>
      </plugin>
      
      <!-- JaCoCo for Code Coverage -->
      <plugin>
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <version>${jacoco.version}</version>
        <executions>
          <execution>
            <goals>
              <goal>prepare-agent</goal>
            </goals>
          </execution>
          <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
              <goal>report</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      
      <!-- SpotBugs for Bug Detection -->
      <plugin>
        <groupId>com.github.spotbugs</groupId>
        <artifactId>spotbugs-maven-plugin</artifactId>
        <version>4.7.3.4</version>
        <executions>
          <execution>
            <goals>
              <goal>check</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      
      <!-- PMD for Code Quality -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-pmd-plugin</artifactId>
        <version>3.20.0</version>
        <executions>
          <execution>
            <goals>
              <goal>check</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      
      <!-- Checkstyle -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-checkstyle-plugin</artifactId>
        <version>3.3.0</version>
        <executions>
          <execution>
            <goals>
              <goal>check</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      
      <!-- Dependency Check -->
      <plugin>
        <groupId>org.owasp</groupId>
        <artifactId>dependency-check-maven</artifactId>
        <version>8.2.1</version>
      </plugin>
    </plugins>
  </build>
</project>
```

### Dockerfile for Spring Boot

```dockerfile
# Multi-stage build for optimization
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

EXPOSE 8080

COPY --from=builder /app/target/*.jar /app/app.jar

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/app.jar"]
```

### Kubernetes Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-boot-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spring-boot-app
  template:
    metadata:
      labels:
        app: spring-boot-app
    spec:
      containers:
      - name: spring-boot-app
        image: registry.gitlab.com/myproject/spring-boot-app:latest
        ports:
        - containerPort: 8080
        
        env:
        - name: SPRING_DATASOURCE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      
      imagePullSecrets:
      - name: gitlab-registry-secret
```

### Example Spring Boot Application

```java
package com.example.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Application {
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

@RestController
public class HelloController {
    
    @GetMapping("/api/hello")
    public String hello() {
        return "Hello from Spring Boot!";
    }
    
    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
```

### Unit Test Example

```java
package com.example.app;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class HelloControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    public void testHelloEndpoint() throws Exception {
        mockMvc.perform(get("/api/hello"))
            .andExpect(status().isOk());
    }
}
```

## Complete End-to-End Workflow

1. **Developer pushes code** to GitLab repository
2. **Pipeline triggers automatically**:
   - Build stage compiles Spring Boot application
   - Unit tests execute with JaCoCo coverage
   - Integration tests run against test database
   - SonarQube analyzes code quality
   - SpotBugs detects potential bugs
   - PMD validates code standards
   - Checkstyle enforces code style
3. **Docker image** is built and pushed to registry
4. **Security scanning** validates dependencies and image
5. **Deployment** to staging (on develop branch)
6. **Deployment** to production (on main branch, requires approval)
7. **Smoke tests** verify deployment health

## Key Metrics

- Build time: ~3-5 minutes
- Test execution: ~2-3 minutes
- Code quality analysis: ~1-2 minutes
- Docker build: ~1-2 minutes
- Deployment: ~2-3 minutes
- **Total pipeline**: ~10-15 minutes

## Best Practices

✅ Always run unit tests before build  
✅ Use caching for Maven dependencies  
✅ Separate test databases for integration tests  
✅ Run security scans in parallel  
✅ Use multi-stage Docker build  
✅ Implement health checks  
✅ Use Kubernetes for production deployments  
✅ Monitor deployment with observability tools
