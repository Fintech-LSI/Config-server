# Config Server 🔧

A **Spring Cloud Config Server** that serves as the centralized configuration management service for our fintech microservices ecosystem. 🏢

## Overview

The **Config Server** is a critical infrastructure component that:
- 📐 Centralizes configuration management for all microservices
- 🔄 Provides dynamic configuration updates
- 🔐 Secures sensitive configuration data
- ⚡ Must be started first before other microservices

## Architecture

![Config Server Architecture](https://velog.velcdn.com/images/18k7102dy/post/05d13c7a-9f34-437d-be41-ded0ebac1d61/image.webp)

The diagram above illustrates how the Config Server centralizes configuration management for all microservices in our ecosystem.

## Project Structure

```
src/main/java/com/fintech/config_server/
├── ConfigServerApplication.java
└── resources/
    └── configurations/               # Configuration files for all services
        ├── auth-service.yaml
        ├── discovery-service.yaml
        ├── gateway-service.yaml
        ├── loans-service.yaml
        ├── notification-service.yaml
        ├── transaction-service.yaml
        ├── user-service.yaml
        └── wallet-service.yaml
```

## Tech Stack

- **Framework**: Spring Cloud Config Server
- **Build Tool**: Maven
- **Configuration Format**: YAML
- **Server Port**: 8889
- **Profile**: Native (File System Based)

## Features

- **Centralized Configuration**: Single source of truth for all microservice configurations
- **Profile Management**: Support for different environments (dev, prod, etc.)
- **Native Profile**: File system based configuration storage
- **Real-time Updates**: Configuration changes without service restarts
- **Security**: Encrypted sensitive properties

## Getting Started

1. **Prerequisites**
    - Java 17+
    - Maven
    - Git (for Git backend if used instead of native)

2. **Configuration**
   ```yaml
   server:
     port: 8889
   spring:
     profiles:
       active: native
     application:
       name: config-server
     cloud:
       config:
         server:
           native:
             search-locations: classpath:/configurations
   ```

3. **Local Development**
   ```bash
   # Build the project
   mvn clean package

   # Run the Config Server (MUST BE STARTED FIRST)
   mvn spring-boot:run
   ```

4. **Verify Setup**
   ```bash
   # Test configuration retrieval
   curl http://localhost:8889/{service-name}/{profile}
   ```

## Configuration Files

Each microservice has its dedicated configuration file:
- `auth-service.yaml`: Authentication service configurations
- `discovery-service.yaml`: Service discovery settings
- `gateway-service.yaml`: API Gateway routing rules
- `loans-service.yaml`: Loan service parameters
- And more...

## Important Notes

1. **Startup Order**
    - Config Server must be started FIRST
    - Other services should start AFTER Config Server is running
    - Services will fail to start if Config Server is unavailable

2. **Configuration Updates**
    - Changes to configuration files require either:
        - Service restart
        - Refresh scope trigger (`POST /actuator/refresh`)
    - Consider using Spring Cloud Bus for automated refreshes

3. **Security Considerations**
    - Secure sensitive properties using encryption
    - Implement authentication for Config Server access
    - Use secure protocols for configuration retrieval

## Monitoring

The Config Server exposes several endpoints for monitoring:
- `/actuator/health`: Health check endpoint
- `/actuator/info`: Information about the Config Server
- `/actuator/metrics`: Metrics data

## Troubleshooting

Common issues and solutions:

1. **Services Can't Connect**
    - Verify Config Server is running
    - Check service bootstrap configuration
    - Ensure correct port configuration (8889)

2. **Configuration Not Found**
    - Verify file exists in correct location
    - Check file naming convention
    - Confirm profile settings

## 👥 Team

| Avatar                                                                                                  | Name | Role | GitHub |
|---------------------------------------------------------------------------------------------------------|------|------|--------|
| <img src="https://github.com/zachary013.png" width="50" height="50" style="border-radius: 50%"/>        | Zakariae Azarkan | DevOps Engineer | [@zachary013](https://github.com/zachary013) |
| <img src="https://github.com/goalaphx.png" width="50" height="50" style="border-radius: 50%"/>          | El Mahdi Id Lahcen | Frontend Developer | [@goalaphx](https://github.com/goalaphx) |
| <img src="https://github.com/hodaifa-ech.png" width="50" height="50" style="border-radius: 50%"/>       | Hodaifa | Cloud Architect | [@hodaifa-ech](https://github.com/hodaifa-ech) |
| <img src="https://github.com/khalilh2002.png" width="50" height="50" style="border-radius: 50%"/>       | Khalil El Houssine | Backend Developer | [@khalilh2002](https://github.com/khalilh2002) |
| <img src="https://github.com/Medamine-Bahassou.png" width="50" height="50" style="border-radius: 50%"/> | Mohamed Amine BAHASSOU | ML Engineer | [@Medamine-Bahassou](https://github.com/Medamine-Bahassou) |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/config-enhancement`)
3. Commit your changes (`git commit -m 'Add new configuration feature'`)
4. Push to the branch (`git push origin feature/config-enhancement`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
