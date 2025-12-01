# Backend Developer Prompts - Complete Index

This directory contains all prompts designed for Backend Developers and Full-Stack Developers.

---

## 📊 Quick Reference Table

| ID | Prompt Title | Technology | Level | Use Case | Status |
|----|--------------|-----------|-------|----------|--------|
| [BD-001](#prompt-bd-001) | Java Spring Boot Microservice | Java, Spring Boot | Intermediate | Code Generation | ✅ Approved |
| [BD-002](#prompt-bd-002) | Spring AI Integration | Spring Boot, Spring AI | Advanced | Code Generation | 🚧 In Development |
| [BD-003](#prompt-bd-003) | Python REST API Design | Python, FastAPI | Beginner | Code Generation | 🚧 In Development |
| [BD-004](#prompt-bd-004) | Database Schema Design | Multi-DB | Intermediate | Architecture | 🚧 Planned |
| [BD-005](#prompt-bd-005) | Async Event-Driven Architecture | Java, Spring Boot, Kafka | Advanced | Architecture | 🚧 Planned |
| [BD-006](#prompt-bd-006) | API Security & Authentication | Spring Boot, FastAPI | Intermediate | Security | 🚧 Planned |
| [BD-007](#prompt-bd-007) | Testing Strategy & Implementation | Java, Python | Intermediate | Quality Assurance | 🚧 Planned |

---

## 📝 Detailed Descriptions

### PROMPT-BD-001

**Java Spring Boot Microservice Development**

- **Description**: Generate production-ready Spring Boot microservices with comprehensive best practices
- **Technology**: Java 11+, Spring Boot 2.7/3.x, Maven/Gradle, JPA, REST APIs
- **Difficulty**: Intermediate
- **Time to Execute**: 30-45 minutes
- **Output**: Complete microservice code structure with entity, repository, service, and controller layers
- **Use When**:
  - Building new microservices
  - Establishing service standards
  - Modernizing legacy Java applications
  - Implementing DDD patterns
- **Key Features**:
  - Layered architecture (entity → repository → service → controller)
  - Security with Spring Security and JWT
  - Error handling with @ControllerAdvice
  - Logging with SLF4J/Logback
  - Configuration management
  - Testing structure (unit, integration, repository tests)
  - API documentation with Swagger/OpenAPI
  - Database persistence with JPA/Hibernate
- **Related Prompts**: PROMPT-AR-001, PROMPT-SE-006, PROMPT-BD-007

[View Full Prompt →](./PROMPT-BD-001-spring-boot-microservice.md)

---

### PROMPT-BD-002

**Spring AI Integration & LLM Integration**

- **Description**: Integrate AI/LLM capabilities into Spring Boot applications
- **Technology**: Spring Boot, Spring AI, OpenAI/Anthropic/Local LLMs, Vector Databases
- **Difficulty**: Advanced
- **Time to Execute**: 45-60 minutes
- **Output**: Spring Boot application with AI integration, RAG (Retrieval-Augmented Generation) patterns
- **Use When**:
  - Adding AI features to existing services
  - Building AI-powered applications
  - Implementing chatbots or assistants
  - Doing semantic search or vector retrieval
  - Fine-tuning LLM interactions
- **Key Features**:
  - Spring AI framework integration
  - LLM provider integration (OpenAI, Anthropic, etc.)
  - Prompt engineering best practices
  - Vector database integration (Pinecone, Weaviate, etc.)
  - RAG pattern implementation
  - Caching and performance optimization
  - Error handling for LLM API failures
  - Cost tracking and rate limiting
- **Status**: 🚧 In Development

[View Prompt →](./PROMPT-BD-002-spring-ai-integration.md)

---

### PROMPT-BD-003

**Python REST API Design with FastAPI/Django**

- **Description**: Create Python REST APIs with FastAPI or Django framework
- **Technology**: Python 3.9+, FastAPI/Django, Pydantic, SQLAlchemy
- **Difficulty**: Beginner-Intermediate
- **Time to Execute**: 30-45 minutes
- **Output**: Complete Python API project structure with models, routes, database
- **Use When**:
  - Building new Python APIs
  - Starting with Python development
  - Choosing between FastAPI and Django
  - Need rapid API development
- **Key Features**:
  - Project scaffolding for FastAPI or Django
  - Data models with Pydantic/SQLAlchemy
  - API route definitions
  - Database integration
  - Authentication/authorization
  - Error handling and validation
  - API documentation (Swagger/Redoc)
  - Testing structure
- **Status**: 🚧 In Development

[View Prompt →](./PROMPT-BD-003-python-api-design.md)

---

### PROMPT-BD-004

**Database Schema Design & Optimization**

- **Description**: Design scalable database schemas for multi-database environments
- **Technology**: SQL (PostgreSQL, MySQL), NoSQL (MongoDB, DynamoDB), ElasticSearch
- **Difficulty**: Intermediate
- **Time to Execute**: 45-60 minutes
- **Output**: Database schema designs, migration scripts, optimization recommendations
- **Use When**:
  - Designing new databases
  - Optimizing existing schemas
  - Choosing between SQL and NoSQL
  - Planning for scalability
  - Ensuring data integrity and performance
- **Key Features**:
  - Entity-Relationship diagrams (ERDs)
  - SQL schema generation
  - NoSQL schema patterns
  - Indexing strategies
  - Query optimization
  - Backup and archival strategies
  - Data migration planning
- **Status**: 🚧 Planned

---

### PROMPT-BD-005

**Async & Event-Driven Architecture**

- **Description**: Implement asynchronous and event-driven patterns in microservices
- **Technology**: Java, Spring Boot, Kafka, RabbitMQ, Spring Cloud Stream
- **Difficulty**: Advanced
- **Time to Execute**: 60-90 minutes
- **Output**: Event-driven microservice implementation with pub/sub patterns
- **Use When**:
  - Building loosely coupled services
  - Implementing event sourcing
  - Asynchronous processing
  - Real-time data synchronization
  - Building reactive applications
- **Key Features**:
  - Event producer/consumer patterns
  - Message broker integration (Kafka, RabbitMQ)
  - Event sourcing and CQRS
  - Saga pattern for distributed transactions
  - Dead letter queues and error handling
  - Event replay and recovery
  - Monitoring and tracing events
- **Status**: 🚧 Planned

---

### PROMPT-BD-006

**API Security & Authentication**

- **Description**: Implement secure APIs with authentication and authorization
- **Technology**: Spring Boot, FastAPI, OAuth2, JWT, Spring Security
- **Difficulty**: Intermediate
- **Time to Execute**: 45-60 minutes
- **Output**: Secure API implementation with auth, rate limiting, CORS
- **Use When**:
  - Securing API endpoints
  - Implementing OAuth2/OpenID Connect
  - Token-based authentication (JWT)
  - Role-based access control
  - API key management
- **Key Features**:
  - JWT token implementation
  - OAuth2 integration
  - Spring Security configuration
  - Rate limiting and throttling
  - CORS configuration
  - Input validation
  - Security headers
  - API versioning
- **Status**: 🚧 Planned

---

### PROMPT-BD-007

**Testing Strategy & Implementation**

- **Description**: Comprehensive testing strategy for microservices
- **Technology**: Java, Python, JUnit, Pytest, TestContainers, Mockito
- **Difficulty**: Intermediate
- **Time to Execute**: 45-60 minutes
- **Output**: Complete test suite structure (unit, integration, E2E tests)
- **Use When**:
  - Establishing testing standards
  - Increasing code coverage
  - Ensuring quality before release
  - Testing microservices
  - Performance testing
- **Key Features**:
  - Unit testing best practices
  - Integration testing with databases
  - API testing and mocking
  - Test data factories and fixtures
  - Code coverage targets
  - Performance testing
  - Contract testing
  - CI/CD integration
- **Status**: 🚧 Planned

---

## 🎯 Recommended Learning Path

### For Beginners

```
1. Start: PROMPT-BD-003 (Python REST API)
   └─ Master: Basic API development
2. Next: PROMPT-BD-001 (Spring Boot Microservice)
   └─ Learn: Professional Java patterns
3. Then: PROMPT-BD-007 (Testing Strategy)
   └─ Build: Quality and confidence
```

### For Intermediate Developers

```
1. Start: PROMPT-BD-001 (Spring Boot Microservice)
   └─ Solidify: Core patterns
2. Next: PROMPT-BD-006 (API Security)
   └─ Learn: Security best practices
3. Then: PROMPT-BD-004 (Database Design)
   └─ Understand: Data architecture
4. Next: PROMPT-BD-005 (Event-Driven)
   └─ Build: Scalable systems
```

### For Advanced Developers

```
1. Start: PROMPT-BD-005 (Event-Driven Architecture)
   └─ Master: Advanced patterns
2. Next: PROMPT-BD-002 (Spring AI Integration)
   └─ Explore: AI capabilities
3. Reference: PROMPT-AR-001 (Microservices Architecture)
   └─ Align: With architecture decisions
```

---

## 🏷️ Tags & Search

### By Technology

- **#java**: BD-001, BD-005, BD-007
- **#spring-boot**: BD-001, BD-002, BD-005, BD-006
- **#python**: BD-003, BD-007
- **#fastapi**: BD-003, BD-006
- **#django**: BD-003, BD-006
- **#kafka**: BD-005
- **#rabbitmq**: BD-005
- **#database**: BD-004
- **#security**: BD-006
- **#testing**: BD-007

### By Use Case

- **#code-generation**: BD-001, BD-003
- **#architecture**: BD-004, BD-005, BD-006
- **#security**: BD-006
- **#testing**: BD-007
- **#database**: BD-004
- **#integration**: BD-005, BD-006
- **#ai-ml**: BD-002

### By Difficulty

- **#beginner**: BD-003
- **#intermediate**: BD-001, BD-004, BD-006, BD-007
- **#advanced**: BD-002, BD-005

---

## 📊 Technology Coverage Matrix

| Technology | Prompts | Coverage |
|-----------|---------|----------|
| Java | BD-001, BD-005, BD-007 | Core backend development |
| Spring Boot | BD-001, BD-002, BD-005, BD-006 | Comprehensive |
| Python | BD-003, BD-007 | API development & testing |
| FastAPI | BD-003, BD-006 | Python APIs & security |
| Database | BD-004 | Schema design |
| Message Queues | BD-005 | Event-driven patterns |
| Security | BD-006 | API authentication |
| Testing | BD-007 | Quality assurance |
| AI/ML | BD-002 | Integration & LLMs |

---

## 🔗 Cross-Role References

These prompts work well with:

| Other Role | Prompts | Integration Points |
|-----------|---------|-------------------|
| Architect | PROMPT-AR-001 | System design alignment |
| DevOps | PROMPT-DO-003 | Deployment strategies |
| Security | PROMPT-SE-006 | API security patterns |
| QA | PROMPT-BD-007 | Testing coordination |

---

## 📞 Support & Feedback

- **Questions**: [GitHub Discussions](https://github.com/devendrapratapsingh/AI-prompt/discussions)
- **Report Issues**: [GitHub Issues](https://github.com/devendrapratapsingh/AI-prompt/issues)
- **Suggest Improvements**: [Feedback Form](https://example.com/feedback)

---

## 📈 Usage Statistics

| Prompt | Downloads | Satisfaction | Last Updated |
|--------|-----------|--------------|--------------|
| BD-001 | 234 | 4.8/5 | 2025-12-01 |
| BD-002 | 45 | 4.6/5 | Planned |
| BD-003 | 78 | 4.7/5 | Planned |

---

**Last Updated**: December 2025  
**Maintained By**: Backend Development Team  
**Next Review**: March 2026
