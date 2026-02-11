# Changelog

All notable changes to DNSaaS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-02-11

### Added
- Initial release of DNSaaS for home lab environments
- CoreDNS-based DNS server implementation
- Docker Compose deployment configuration
- Example zone file for `homelab.local` domain
- Complete documentation suite:
  - README.md with comprehensive setup instructions
  - QUICKSTART.md for rapid deployment
  - DEPLOYMENT.md with advanced deployment scenarios
- Management scripts:
  - `manage.sh` - Service management (start/stop/restart/status/test/validate/update/clean)
  - `test.sh` - Automated testing of DNS functionality
- Configuration files:
  - `Corefile` - CoreDNS configuration with plugins
  - `docker-compose.yml` - Production-ready Docker Compose setup
  - `.env.example` - Environment configuration template
- Features implemented:
  - DNS forwarding to upstream servers (Google DNS, Cloudflare)
  - Local domain resolution for home lab services
  - DNS caching for improved performance
  - Prometheus metrics endpoint (port 9153)
  - Health check endpoint (port 8080)
  - Comprehensive logging
  - Automatic container restart policy
- Example service records in zone file:
  - Name server (ns1)
  - Router
  - NAS
  - Proxmox
  - Docker host
  - Kubernetes cluster nodes
  - CNAME aliases

### Documentation
- Network setup guides for router and per-device configuration
- Troubleshooting section for common issues
- Security considerations and best practices
- Monitoring and metrics integration guides
- Advanced configuration examples
- Deployment scenarios:
  - Basic setup
  - Raspberry Pi deployment
  - Proxmox LXC container
  - Docker Swarm
  - Kubernetes
  - Pi-hole integration

### Technical Details
- CoreDNS version: 1.14.1
- Docker Compose file format: Latest (no version required)
- Zone file format: Standard DNS zone file (RFC 1035)
- Supported platforms: Linux, macOS (with Docker)
- Network requirements: Port 53 (UDP/TCP), 9153 (TCP), 8080 (TCP)

### Security
- Read-only volume mounts for configuration files
- No root privileges required in container
- Firewall recommendations included
- Regular update guidance provided
- Isolated Docker network

## Planned Features

### [1.1.0] - Future
- [ ] DNSSEC support
- [ ] DNS over TLS (DoT)
- [ ] DNS over HTTPS (DoH)
- [ ] Multiple zone file support via configuration
- [ ] Web UI for zone file management
- [ ] Automatic zone file backup
- [ ] Email notifications for errors
- [ ] Integration with popular home automation platforms

### [1.2.0] - Future
- [ ] High availability setup with multiple CoreDNS instances
- [ ] Dynamic DNS update support (RFC 2136)
- [ ] IPv6 support and AAAA records
- [ ] Reverse DNS (PTR) records
- [ ] Split-horizon DNS
- [ ] Grafana dashboard templates
- [ ] Automated testing suite
- [ ] CI/CD pipeline for updates

---

[1.0.0]: https://github.com/KDubicki/DNSaaS/releases/tag/v1.0.0
