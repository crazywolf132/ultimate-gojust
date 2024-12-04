# Ultimate Golang Justfile

A comprehensive, production-ready Justfile system for Go projects of any size. This Justfile provides a complete set of commands for development, testing, building, and deployment workflows while remaining flexible and customizable.

> **Note**: This is a [just](https://github.com/casey/just)-based alternative to [ultimate-gomake](https://github.com/crazywolf132/ultimate-gomake). Both provide identical functionality but use different build systems.

## 🚀 Features

- **Flexible Configuration**: Support for environment variables, .env files, and command-line overrides
- **Multi-Environment Support**: Development, staging, and production builds
- **Cross-Platform Building**: Support for multiple OS/Architecture combinations with optimized build flags
- **Advanced Testing**: Unit, integration, and end-to-end testing with coverage reports and benchmarking
- **Docker Integration**: Build, push, and run Docker containers
- **Database Operations**: Migration management and database utilities
- **Development Tools**: Hot reload, formatting, linting, and security scanning
- **CI/CD Ready**: Integrated pipeline support for common CI systems
- **Documentation**: Automatic API documentation generation
- **Monorepo Support**: Build and manage multiple services
- **Comprehensive Reporting**: Test coverage, benchmarks, and security reports
- **Version Control Integration**: Automatic version detection and build information embedding

## 📋 Prerequisites

- Go 1.21 or higher
- [just](https://github.com/casey/just)
- Docker (optional)
- Git

## 🛠 Installation

1. Install just if you haven't already:
```bash
# On macOS
brew install just

# On Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash

# On Windows
winget install just
```

2. Copy the justfile to your project root:
```bash
curl -O https://raw.githubusercontent.com/yourusername/ultimate-gojust/main/justfile
```

3. Initialize your project:
```bash
just init
```

This will:
- Create necessary directories
- Initialize Go modules
- Install required tools
- Create default configuration files

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in your project root to override default settings:

```env
# Project Configuration
PROJECT_NAME=myapp
ORGANIZATION=myorg
ENABLE_DOCKER=true
ENABLE_PROTO=false

# Build Settings
CGO_ENABLED=0
COVERAGE_THRESHOLD=80

# Docker Settings
DOCKER_REGISTRY=docker.io
DOCKER_REPO=myorg/myapp
```

### Project Structure

The Justfile assumes the following project structure:
```
.
├── main/
│   └── main.go
├── pkg/
├── internal/
├── api/
├── docs/
├── scripts/
├── build/
├── configs/
├── test/
│   ├── e2e/
│   └── integration/
└── justfile
```

## 🎯 Common Commands

### Development

```bash
# Start development with hot reload
just dev

# Run tests
just test

# Run tests with coverage
just test-coverage

# Format and lint code
just fmt lint

# Generate mocks and protobuf
just generate
```

### Building

```bash
# Build for current platform
just build

# Build for all platforms
just build-all

# Build with debug symbols
just build-debug

# Build with race detector
just build-race
```

### Docker Operations

```bash
# Build Docker image
just docker-build

# Push Docker image
just docker-push

# Run in Docker container
just docker-run
```

### Database Operations

```bash
# Run migrations
just db-migrate

# Rollback last migration
just db-rollback

# Reset database
just db-reset
```

### Maintenance

```bash
# Install/update dependencies
just deps
just deps-update

# Clean build artifacts
just clean

# Update tools
just tools
```

## 🎨 Customization

### Adding New Recipes

Add custom recipes at the end of the justfile:

```just
# Custom recipe description
custom-target:
    echo "Running custom target..."
    # Custom commands here
```

### Modifying Existing Recipes

Override existing recipes by redefining them in `config.just`:

```just
# config.just
# Custom test implementation
test:
    echo "Running custom tests..."
    # Custom test commands
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

Special thanks to the Go community and all contributors who have helped shape this Justfile system.