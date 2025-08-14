# Contributing to K8mpatible GitHub Action

Thank you for your interest in contributing to the K8mpatible GitHub Action! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and considerate of others when contributing to this project.

## How to Contribute

1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Make your changes
4. Test your changes locally
5. Submit a pull request

## Development Setup

### Prerequisites

- Docker
- Git
- GitHub CLI (optional)

### Local Development

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/action-k8mpatible-check.git
   cd action-k8mpatible-check
   ```

2. Build the Docker image:
   ```bash
   docker build -t k8mpatible-action .
   ```

3. Test the Docker image:
   ```bash
   docker run --rm k8mpatible-action "1.28.0" "" "true" "table" "false"
   ```

## Testing

Before submitting a pull request, make sure your changes pass the existing tests:

```bash
# Build and test the Docker image
docker build -t k8mpatible-action .
docker run --rm k8mpatible-action "1.28.0" "" "true" "table" "false"
```

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the examples if necessary
3. The PR should work with the existing CI/CD workflow
4. Once approved, a maintainer will merge your PR

## Release Process

Releases are managed by the maintainers. The process is:

1. Update version numbers in relevant files
2. Create a new GitHub release with appropriate tag
3. The CI/CD workflow will automatically publish the action to the GitHub Marketplace

## Questions?

If you have any questions or need help, please open an issue in the repository.
