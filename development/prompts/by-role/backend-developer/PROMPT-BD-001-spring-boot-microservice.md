# Java Spring Boot Microservice Development

**Title**: Java Spring Boot Microservice - Complete Development & Best Practices

**Version**: 1.0  
**Last Updated**: 2025-12-01  
**Author**: Architecture Team  
**Status**: Approved

---

### 📋 Quick Reference

| Property | Value |
|----------|-------|
| **Prompt ID** | PROMPT-BD-001 |
| **Role** | Backend Developer |
| **Use Case** | Code Generation for Microservices |
| **Technology Stack** | Java, Spring Boot, Spring Data, Spring Cloud, Maven/Gradle |
| **Difficulty Level** | Intermediate |
| **Output Format** | Code + Documentation |
| **Documentation Format** | Markdown + AsciiDoc |
| **Cloud Platforms** | AWS, Azure, GCP, On-Premise, OpenShift |
| **Tags** | #java #spring-boot #microservices #code-generation #intermediate |
| **Dependencies** | PROMPT-AR-001, PROMPT-SE-006, PROMPT-BD-007 |
| **Estimated Duration** | 30-45 minutes |

---

### 🎯 Purpose & Use Case

**Primary Purpose**:  
Generate production-ready Java Spring Boot microservices with comprehensive best practices, including proper layering, error handling, logging, security, and testing structure. This prompt ensures enterprise-grade code quality and maintainability.

**When to Use**:
- Building new REST API microservices
- Creating enterprise backend services
- Implementing domain-driven design services
- Establishing service standards within a team
- Modernizing legacy Java applications

**When NOT to Use**:
- Simple scripts or utilities (use lighter frameworks)
- Non-business-logic components (use libraries instead)
- Proof-of-concept projects (too heavyweight)
- Read-only data services (consider simpler stacks)

**Business Value**:
- Reduces development time by 40-50%
- Ensures consistent code quality across team
- Implements security best practices automatically
- Reduces technical debt from day one
- Accelerates team onboarding

---

### 📚 Prerequisites & Requirements

**Required Knowledge**:
- Java 11+ programming (Intermediate level)
- Spring Boot fundamentals (Basic level)
- REST API concepts (Intermediate level)
- Maven or Gradle build tools (Basic level)
- Database basics (Intermediate level)
- Git version control (Basic level)

**Required Tools/Software**:
- Java Development Kit (JDK) 11 or later
- Maven 3.6+ or Gradle 6.0+
- Spring Boot 2.7+ or 3.0+
- IDE: IntelliJ IDEA / VS Code / Eclipse
- Git 2.30+
- Docker 20.10+ (for containerization)
- PostgreSQL/MySQL/H2 for database

**Input Artifacts Needed**:
- Service domain and business requirements
- Database schema or entity definitions
- API endpoint specifications
- Security requirements
- Deployment target environment details

**System Requirements**:
- Minimum 4GB RAM for build tools
- 2GB+ disk space for dependencies
- Network access to Maven Central Repository

---

### ❓ Initial Questions (Answer Before Proceeding)

**Question 1**: What is the primary domain/business function of this microservice?
- Expected format: Clear business domain name (e.g., "Order Management", "User Identity Service", "Payment Processing")
- Example: "Product Catalog Service - managing product inventory, pricing, and availability"

**Question 2**: What is the Spring Boot version target and preferred JDK version?
- Expected format: "Spring Boot X.Y.Z" and "JDK XX"
- Example: "Spring Boot 3.2.0 and JDK 17"

**Question 3**: What are the main entities/domain models for this service? (List 3-5)
- Expected format: Entity names with 2-3 key attributes each
- Example: "Product(id, name, price, sku), Inventory(productId, quantity, warehouse), Order(id, customerId, items, status)"

**Question 4**: What external integrations or dependencies does this service need?
- Expected format: List of external systems/APIs
- Example: "Payment Gateway API, Notification Service, Customer Service API"

**Question 5**: What are the data persistence requirements? (Database type, repositories, caching needs)
- Expected format: Database type and specific requirements
- Example: "PostgreSQL with JPA/Hibernate, Redis caching for product catalog, no denormalization needed"

> ⚠️ **CRITICAL**: Do not proceed with the main task until ALL questions above are answered clearly and completely.

---

### 🔧 Main Task Instructions

**Objective**: Generate a production-ready Spring Boot microservice with proper layering, error handling, security, logging, and testing structure.

**Step-by-Step Instructions**:

1. **Generate Project Structure**
   - Create standard Maven/Gradle project structure
   - Include pom.xml or build.gradle with all necessary dependencies
   - Set up application.yml with profiles (dev, test, prod)
   - Configure logging (SLF4J + Logback)

2. **Create Domain Model**
   - Define all JPA/Hibernate entities based on Question 3
   - Add validation annotations (@NotNull, @Size, @Pattern, etc.)
   - Implement Lombok annotations (@Data, @Builder, @NoArgsConstructor) for cleaner code
   - Create DTOs for API requests/responses

3. **Implement Data Access Layer**
   - Create Spring Data JPA Repository interfaces
   - Add custom query methods with @Query if needed
   - Implement pagination and sorting
   - Add repository test cases

4. **Implement Service Layer**
   - Create service classes with @Service annotation
   - Implement business logic with proper error handling
   - Add transaction management (@Transactional)
   - Include logging at key points
   - Handle edge cases and validation

5. **Implement REST Controller Layer**
   - Create REST controllers with proper @RequestMapping
   - Implement all CRUD operations (GET, POST, PUT, DELETE)
   - Add path variables, request parameters, request body handling
   - Implement proper HTTP status codes (200, 201, 400, 404, 500, etc.)
   - Add API documentation with @ApiOperation, @ApiResponse

6. **Implement Security**
   - Add Spring Security configuration class
   - Implement JWT/OAuth2 token validation
   - Add role-based access control (@PreAuthorize, @Secured)
   - Implement CORS configuration
   - Add security headers

7. **Error Handling**
   - Create custom exception classes
   - Implement global @ControllerAdvice for exception handling
   - Create standardized error response objects
   - Add proper HTTP error codes and messages

8. **Logging & Monitoring**
   - Configure SLF4J/Logback with proper log levels
   - Add health check endpoint (/actuator/health)
   - Configure metrics collection (micrometer)
   - Add application readiness/liveness probes

9. **Testing Structure**
   - Create unit tests for service layer (Mockito)
   - Create integration tests for controller layer
   - Add repository tests with @DataJpaTest
   - Include test data builders and fixtures

10. **Configuration & Externalization**
    - Externalize configuration to properties files
    - Add support for environment variables
    - Create configuration classes using @Configuration
    - Add profiles for different environments

11. **Documentation**
    - Generate API documentation (Swagger/SpringDoc OpenAPI)
    - Create README with setup instructions
    - Document environment variables and configuration
    - Include deployment instructions

---

### 📤 Expected Output Format

**Primary Deliverables**:
- File 1: `pom.xml` or `build.gradle` - Build configuration with all dependencies
- File 2: `application.yml` - Spring Boot application configuration template
- File 3: `src/main/java/` - Complete source code structure with:
  - Entity classes
  - Repository interfaces
  - Service classes
  - Controller classes
  - Configuration classes
  - Exception handlers
- File 4: `src/test/java/` - Test classes structure
- File 5: `README.md` - Complete setup and usage documentation

**Output Structure Example**:
```
microservice/
├── pom.xml
├── README.md
├── .gitignore
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/company/service/
│   │   │       ├── config/
│   │   │       │   ├── SecurityConfig.java
│   │   │       │   ├── JpaConfig.java
│   │   │       │   └── OpenApiConfig.java
│   │   │       ├── entity/
│   │   │       │   ├── Product.java
│   │   │       │   └── Order.java
│   │   │       ├── dto/
│   │   │       │   ├── ProductDTO.java
│   │   │       │   └── OrderDTO.java
│   │   │       ├── repository/
│   │   │       │   ├── ProductRepository.java
│   │   │       │   └── OrderRepository.java
│   │   │       ├── service/
│   │   │       │   ├── ProductService.java
│   │   │       │   └── OrderService.java
│   │   │       ├── controller/
│   │   │       │   ├── ProductController.java
│   │   │       │   └── OrderController.java
│   │   │       ├── exception/
│   │   │       │   ├── GlobalExceptionHandler.java
│   │   │       │   └── ResourceNotFoundException.java
│   │   │       └── Application.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       └── logback.xml
│   └── test/
│       └── java/
│           └── com/company/service/
│               ├── service/
│               │   └── ProductServiceTest.java
│               ├── controller/
│               │   └── ProductControllerTest.java
│               └── repository/
│                   └── ProductRepositoryTest.java
```

**Output Specifications**:
- Format: Production-ready Java code following Spring Boot conventions
- Should include: All layers (entity, repository, service, controller), security, error handling, logging
- Code style: Google Java Style Guide with Spring conventions
- Documentation: JavaDoc for public APIs, inline comments for complex logic

---

### 📋 Quality Checklist for Output

- [ ] All entities follow JPA best practices with proper annotations
- [ ] All repositories extend JpaRepository with custom query methods
- [ ] All services use @Service with @Transactional management
- [ ] All controllers use REST conventions with proper HTTP methods
- [ ] Security is implemented with Spring Security (@Configuration, @PreAuthorize)
- [ ] Error handling uses @ControllerAdvice with custom exceptions
- [ ] Logging is configured with SLF4J + Logback
- [ ] All endpoints are documented with @ApiOperation and @ApiResponse
- [ ] DTOs are used for API contracts (not entities)
- [ ] Configuration is externalized (application.yml, environment variables)
- [ ] Testing structure includes unit, integration, and repository tests
- [ ] Code follows SOLID principles and Spring Boot best practices
- [ ] No hardcoded values or secrets in code
- [ ] pom.xml/build.gradle includes all necessary dependencies
- [ ] README includes setup, build, run, test, and deployment instructions

---

### 💡 Examples & Sample Outputs

**Example 1: E-Commerce Order Service**

**Input**:
```
Domain: Order Management Service
Spring Boot: 3.2.0, JDK 17
Entities: Order(id, customerId, totalAmount, status), OrderItem(orderId, productId, quantity, price)
Integrations: Payment Service API, Inventory Service API
Database: PostgreSQL with JPA, Redis for order cache
```

**Expected Output Structure**:
```
- Order, OrderItem entities with @Entity, @Table annotations
- OrderRepository with custom findByCustomerId() method
- OrderService with business logic for create, update, cancel orders
- OrderController with REST endpoints: GET, POST, PUT, DELETE
- OrderNotFoundException, OrderValidationException
- Spring Security with JWT token validation
- OrderServiceTest, OrderControllerTest with proper mocking
- Swagger/OpenAPI documentation for all endpoints
```

---

**Example 2: Multi-Tenant SaaS Service**

**Input**:
```
Domain: Tenant Account Service
Spring Boot: 2.7.15, JDK 11
Entities: Account(id, tenantId, name, status), User(id, accountId, email, role)
Integrations: None (internal service)
Database: MySQL with Hibernate, no caching initially
```

**Expected Output Structure**:
```
- Account, User entities with TenantId segregation
- TenantContext holder for current tenant
- Repositories with tenant-aware queries
- Services with tenant isolation logic
- Controller with role-based access (@PreAuthorize("hasRole('ADMIN')"))
- Spring Security with custom authentication provider
- Comprehensive error handling for tenant violations
```

---

### 🔗 Related Prompts & Dependencies

**Related Prompts**:
- **PROMPT-AR-001**: Microservices Architecture - Use this first to design your service architecture
- **PROMPT-SE-006**: API Security Implementation - Use for additional security patterns
- **PROMPT-BD-007**: Testing Strategy - Use for comprehensive testing approach
- **PROMPT-DO-003**: OpenShift Deployment - Use for containerization

**Recommended Sequence** (if part of a workflow):
1. **PROMPT-AR-001** - Design microservice architecture and domain model
2. **PROMPT-BD-001** - Generate code (this prompt)
3. **PROMPT-SE-006** - Implement security enhancements
4. **PROMPT-BD-007** - Develop comprehensive test suite
5. **PROMPT-DO-003** - Create Docker/Kubernetes manifests

**Cross-Functional Integration**:
- Can be used by: Backend developers, architects, tech leads
- Integrates with: DevOps pipelines, CI/CD systems, container registries
- Output consumed by: Deployment pipelines, API documentation systems, frontend teams

---

### 🐛 Troubleshooting Guide

**Issue 1: Dependencies conflict between Spring Boot and external libraries**
- **Symptom**: Maven/Gradle build fails with dependency resolution errors
- **Root Cause**: Version conflicts or missing transitive dependencies
- **Solution**:
  1. Run `mvn dependency:tree` to visualize dependency tree
  2. Identify conflicting versions
  3. Use `<exclusions>` in pom.xml to exclude conflicting transitive dependencies
  4. Update to compatible versions using Spring Boot's BOM
- **Prevention**: Use Spring Boot dependency management; test with different library versions

**Issue 2: JPA N+1 query problem causing performance issues**
- **Symptom**: Database receives multiple queries instead of one; slow API responses
- **Root Cause**: Lazy loading of relationships without proper fetch strategy
- **Solution**:
  1. Use `@Fetch(FetchMode.JOIN)` or `@Transactional(readOnly=true)` with JOIN FETCH queries
  2. Use `@Query` with explicit FETCH JOIN
  3. Consider `@EntityGraph` for complex relationships
  4. Use projection DTOs to limit fetched columns
- **Prevention**: Profile queries with logging; use Spring Data repository metrics

**Issue 3: Transaction not rolling back on exception**
- **Symptom**: Data persists even when exception is thrown
- **Root Cause**: `@Transactional` not catching checked exceptions; wrong exception type
- **Solution**:
  1. Use `@Transactional(rollbackFor = Exception.class)` to catch all exceptions
  2. Ensure exceptions propagate from service layer
  3. Check that transaction is actually starting (enable DEBUG logging)
  4. Verify database supports transactions (InnoDB for MySQL, not MyISAM)
- **Prevention**: Add transaction tests; use `@Transactional` on test methods

**Issue 4: Security configuration not protecting endpoints**
- **Symptom**: Endpoints accessible without authentication
- **Root Cause**: Security configuration not properly applied; wrong URL patterns
- **Solution**:
  1. Verify `@Configuration` class extends `WebSecurityConfigurerAdapter` or uses `SecurityFilterChain`
  2. Check `antMatchers()` or `requestMatchers()` patterns match your URLs
  3. Ensure `http.authorizeRequests()` is configured before `anyRequest().authenticated()`
  4. Verify JWT/OAuth2 filter is properly registered
- **Prevention**: Write security integration tests; use `mockMvc` with `@WithMockUser`

**Issue 5: Lombok annotations not working in IDE**
- **Symptom**: IDE shows "cannot find symbol" errors despite code compiling
- **Root Cause**: IDE needs Lombok annotation processor plugin
- **Solution**:
  1. Install Lombok plugin in IDE (IntelliJ: Settings > Plugins > Search "Lombok")
  2. Enable annotation processing in IDE (IntelliJ: Settings > Compiler > Annotation Processors > Enable)
  3. For Maven: ensure `org.projectlombok:lombok` is in dependencies
  4. Reload IDE project
- **Prevention**: Add Lombok plugin to team IDE setup instructions

**Getting More Help**:
- Check: [Spring Boot Documentation](https://docs.spring.io/spring-boot/)
- Reference: [Spring Data JPA Guide](https://docs.spring.io/spring-data/jpa/)
- Contact: Your team's backend architecture lead

---

### 📝 Best Practices

1. **Layered Architecture**
   - Maintain clear separation: Controller → Service → Repository
   - Controllers handle HTTP concerns only
   - Services contain business logic and transactions
   - Repositories handle data access patterns
   - Example: Controller calls Service (which calls Repository), never directly

2. **Proper Use of DTOs**
   - Use DTOs for API request/response contracts
   - Don't expose JPA entities directly
   - Create separate DTOs for input (POST/PUT) and output (GET)
   - Example: `CreateOrderRequest` DTO for input, `OrderResponse` DTO for output

3. **Error Handling Strategy**
   - Create custom exceptions for domain errors
   - Use `@ControllerAdvice` for centralized exception handling
   - Return proper HTTP status codes (400 for validation, 404 for not found, 500 for server errors)
   - Include meaningful error messages in response

4. **Configuration Management**
   - Use `application.yml` or properties files, never hardcode configuration
   - Create separate profiles for dev, test, prod
   - Use environment variables for sensitive data (passwords, API keys)
   - Use `@ConfigurationProperties` for complex configuration

5. **Logging Best Practices**
   - Use SLF4J with Logback (Spring Boot default)
   - Log at appropriate levels: ERROR (errors), WARN (warnings), INFO (important events), DEBUG (diagnostic)
   - Include context (user ID, transaction ID, request ID)
   - Don't log sensitive data (passwords, credit cards)

---

### ⚠️ Security & Compliance Considerations

**Security Aspects**:
- Use Spring Security for authentication and authorization
- Implement JWT/OAuth2 for token-based authentication
- Validate all user inputs (use `@Valid`, `@Validated`)
- Use HTTPS in production (configure in application.yml)
- Implement CORS properly (don't use `allowCredentials = true` with `allowedOrigins = "*"`)
- Use parameterized queries to prevent SQL injection (Spring Data does this automatically)

**Compliance Requirements**:
- GDPR: Implement data deletion and export functionality
- HIPAA: Encrypt data in transit and at rest
- PCI-DSS: Don't store credit card data directly; use payment gateway tokens
- SOC 2: Implement audit logging and access controls

**Sensitive Information**:
- Don't commit `application.properties` with secrets
- Store secrets in environment variables or vault
- Use `.gitignore` for local configuration files
- Never log passwords, API keys, tokens

---

### 📚 References & Documentation

**Official Documentation**:
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/)
- [Spring Data JPA](https://docs.spring.io/spring-data/jpa/)
- [Spring Security](https://docs.spring.io/spring-security/)
- [Spring REST Docs](https://spring.io/projects/spring-restdocs)

**Industry Standards**:
- [REST API Best Practices](https://restfulapi.net/)
- [Java Code Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Spring Framework Best Practices](https://spring.io/guides)

**Related Articles**:
- [Building Microservices with Spring Boot](https://spring.io/guides/gs/microservices-service-registry-and-discovery/)
- [Spring Security in Action](https://www.manning.com/books/spring-security-in-action)

---

### 📊 Prompt Metadata

**Prompt ID**: PROMPT-BD-001  
**Category**: Backend Development  
**Subcategory**: Microservices  
**Complexity Score**: 7/10  
**Reusability Score**: 9/10  
**Last Reviewed**: 2025-12-01  
**Review Cycle**: Every 3 months  

---

### 📝 Version History & Changelog

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-12-01 | Initial release | Architecture Team |

---

### ✅ Quality Assurance Sign-Off

- **Prompt Accuracy**: ✓ Verified against Spring Boot 3.2.0 and latest best practices
- **Completeness**: ✓ All required sections present
- **Clarity**: ✓ Clear and understandable to intermediate Java developers
- **Tested**: ✓ Executed successfully with sample e-commerce domain
- **Security**: ✓ No sensitive information exposed; security best practices included
- **Compliance**: ✓ Follows organizational standards and industry best practices

**Approved By**: Architecture Team, Date: 2025-12-01  
**Last Validated**: 2025-12-01  

---

**Footer Note**: This prompt is part of the AI-prompt library. For navigation and discovery, refer to [PROMPT_DISCOVERY_GUIDE.md](../PROMPT_DISCOVERY_GUIDE.md).
