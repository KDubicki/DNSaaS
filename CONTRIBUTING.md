# Contributing to DNSaaS

Thank you for your interest in contributing to DNSaaS! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in [GitHub Issues](https://github.com/KDubicki/DNSaaS/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Detailed description of the problem/suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Environment details (OS, Docker version, etc.)
   - Relevant logs or screenshots

### Suggesting Features

We welcome feature suggestions! Please:

1. Check the [CHANGELOG.md](CHANGELOG.md) for planned features
2. Open an issue with the "enhancement" label
3. Describe the use case and benefit
4. Provide examples if possible

### Pull Requests

#### Before You Start

1. Fork the repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly

#### Code Guidelines

**Shell Scripts:**
- Use bash shebang: `#!/bin/bash`
- Include error handling: `set -e`
- Add comments for complex logic
- Use descriptive variable names
- Follow existing code style

**Docker/Compose:**
- Use latest stable images
- Include health checks
- Document port mappings
- Use read-only mounts where appropriate

**Documentation:**
- Update README.md for user-facing changes
- Update DEPLOYMENT.md for deployment scenarios
- Add entries to CHANGELOG.md
- Include code examples
- Use clear, concise language

**Zone Files:**
- Follow RFC 1035 format
- Include comments for sections
- Use consistent spacing
- Increment serial numbers (YYYYMMDDNN format)

#### Testing Your Changes

Before submitting:

```bash
# 1. Validate Docker Compose configuration
docker compose config

# 2. Test deployment
docker compose up -d

# 3. Run tests
./test.sh

# 4. Check logs for errors
docker compose logs

# 5. Test DNS resolution
dig @localhost nas.homelab.local

# 6. Clean up
docker compose down
```

#### Submitting Pull Requests

1. Ensure your code follows the guidelines
2. Update documentation
3. Add changelog entry
4. Commit with clear messages:
   ```
   Add feature: description
   
   - Detail 1
   - Detail 2
   ```

5. Push to your fork
6. Create a pull request with:
   - Clear title
   - Description of changes
   - Related issue numbers
   - Testing performed

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/DNSaaS.git
cd DNSaaS

# Add upstream remote
git remote add upstream https://github.com/KDubicki/DNSaaS.git

# Create feature branch
git checkout -b feature/my-feature

# Make changes and test
# ...

# Commit and push
git add .
git commit -m "Add feature: description"
git push origin feature/my-feature
```

## Code Review Process

1. All PRs require review before merging
2. Address review feedback
3. Keep PRs focused and small
4. Squash commits if requested

## Project Structure

```
DNSaaS/
├── zones/              # DNS zone files
│   └── homelab.local.zone
├── Corefile           # CoreDNS configuration
├── docker-compose.yml # Docker Compose setup
├── manage.sh          # Management script
├── test.sh            # Testing script
├── README.md          # Main documentation
├── QUICKSTART.md      # Quick start guide
├── DEPLOYMENT.md      # Deployment guide
├── CHANGELOG.md       # Version history
└── LICENSE            # MIT License
```

## Areas for Contribution

We especially welcome contributions in:

### Documentation
- Tutorials and how-to guides
- Translation to other languages
- Video guides
- Troubleshooting tips
- Real-world examples

### Features
- Additional DNS plugins
- Web UI for management
- Automated backup solutions
- Integration guides
- Monitoring dashboards

### Testing
- Automated test suite
- Performance benchmarks
- Compatibility testing
- Security audits

### Bug Fixes
- Fix reported issues
- Improve error handling
- Performance improvements
- Security enhancements

## Community Guidelines

### Be Respectful
- Be kind and courteous
- Accept constructive criticism
- Focus on what's best for the project
- Show empathy

### Be Collaborative
- Help others learn
- Share knowledge
- Review others' contributions
- Celebrate achievements

### Be Professional
- Keep discussions on-topic
- Provide constructive feedback
- Document your work
- Follow through on commitments

## Getting Help

If you need help:

1. Check the documentation
2. Search existing issues
3. Ask in GitHub Discussions
4. Tag maintainers in issues

## Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Credited in release notes
- Mentioned in documentation where applicable

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue with the "question" label!

Thank you for contributing to DNSaaS! 🎉
