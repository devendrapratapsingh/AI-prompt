# Spring Boot CI/CD Pipeline - GitHub Actions Example

## Overview
This example demonstrates a complete CI/CD pipeline for a Spring Boot microservice using GitHub Actions.

## Pipeline Stages

```yaml
name: Spring Boot CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
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
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Build with Maven
        run: |
          mvn clean verify \
            -DskipTests \
            -Drevision=${{ github.sha }} \
            -Dspotbugs.skip=false \
            -Dpmd.skip=false

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: spring-boot-jar
          path: target/*.jar
          retention-days: 5

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

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Run unit tests
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/test
          SPRING_DATASOURCE_PASSWORD: postgres
        run: |
          mvn test \
            -Drevision=${{ github.sha }} \
            --batch-mode

      - name: Run integration tests
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/test
          SPRING_DATASOURCE_PASSWORD: postgres
        run: |
          mvn verify \
            -Drevision=${{ github.sha }} \
            -DskipUnitTests \
            --batch-mode

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./target/site/jacoco/jacoco.xml
          flags: java-coverage

  security:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'SpringBootApp'
          path: '.'
          format: 'JSON'

      - name: Check for security vulnerabilities
        run: |
          mvn verify \
            -Dspotbugs.skip=false \
            -Dspotbugs.failOnError=true

  build-docker:
    runs-on: ubuntu-latest
    needs: [test, security]
    permissions:
      packages: write
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: spring-boot-jar
          path: target/

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.sha }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            JAR_FILE=target/*.jar

  deploy-staging:
    runs-on: ubuntu-latest
    needs: build-docker
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging-app.example.com

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to staging
        run: |
          kubectl set image deployment/spring-boot-app \
            spring-boot=ghcr.io/${{ github.repository }}:${{ github.sha }} \
            -n staging

  deploy-production:
    runs-on: ubuntu-latest
    needs: build-docker
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://app.example.com

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to production
        run: |
          kubectl set image deployment/spring-boot-app \
            spring-boot=ghcr.io/${{ github.repository }}:${{ github.sha }} \
            -n production
          kubectl rollout status deployment/spring-boot-app -n production
```

## POM Configuration for CI/CD

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>spring-boot-app</artifactId>
  <version>${revision}</version>

  <properties>
    <revision>1.0.0-SNAPSHOT</revision>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <spotbugs-maven-plugin.version>4.7.3.4</spotbugs-maven-plugin.version>
  </properties>

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
      </plugin>

      <!-- JaCoCo for code coverage -->
      <plugin>
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <version>0.8.10</version>
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

      <!-- SpotBugs for static analysis -->
      <plugin>
        <groupId>com.github.spotbugs</groupId>
        <artifactId>spotbugs-maven-plugin</artifactId>
        <version>${spotbugs-maven-plugin.version}</version>
      </plugin>

      <!-- PMD for code quality -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-pmd-plugin</artifactId>
        <version>3.20.0</version>
      </plugin>
    </plugins>
  </build>
</project>
```

## Dockerfile

```dockerfile
# Multi-stage build
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Spring Boot Application Properties

### application.yml
```yaml
spring:
  application:
    name: spring-boot-app
  
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:myapp}
    username: ${DB_USER:postgres}
    password: ${DB_PASSWORD:postgres}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
  
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
  
  jackson:
    serialization:
      write-dates-as-timestamps: false

server:
  port: 8080
  shutdown: graceful
  
  servlet:
    context-path: /api
  
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  
  metrics:
    export:
      prometheus:
        enabled: true
  
  endpoint:
    health:
      show-details: when-authorized

logging:
  level:
    root: INFO
    com.example: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
```

## Key Features

- **Multi-stage Docker builds** for optimized image size
- **Database services** in CI/CD for integration testing
- **Code coverage** tracking with Codecov
- **Static code analysis** with SpotBugs and PMD
- **Dependency vulnerability** scanning
- **Kubernetes deployment** with rolling updates
- **Health checks** before and after deployment
- **Environment-specific** configurations
