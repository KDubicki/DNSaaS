# Quick Start Guide

Get DNSaaS running in under 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Static IP assigned to your DNS server (e.g., 192.168.1.10)
- Port 53 available (stop systemd-resolved if needed)

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/KDubicki/DNSaaS.git
cd DNSaaS

# 2. Edit zone file with your network details
nano zones/homelab.local.zone
# Update IP addresses to match your network

# 3. Start the service
docker compose up -d

# 4. Verify it's working
dig @localhost nas.homelab.local
```

## What's Included

- **CoreDNS** - Modern, fast DNS server
- **Local Domain** - homelab.local for your services
- **DNS Forwarding** - Queries forward to Google/Cloudflare DNS
- **Monitoring** - Prometheus metrics on port 9153
- **Health Checks** - Automatic health monitoring
- **Management Scripts** - Easy start/stop/test commands

## Next Steps

1. **Configure Your Router**
   - Set primary DNS to your server's IP (192.168.1.10)
   - This makes all devices use your DNS server

2. **Add Your Services**
   - Edit `zones/homelab.local.zone`
   - Add A records for your servers
   - Increment the serial number
   - Restart: `docker compose restart`

3. **Test Everything**
   ```bash
   ./test.sh
   ```

## Common Commands

```bash
# Start service
docker compose up -d

# Stop service
docker compose down

# View logs
docker compose logs -f

# Restart after changes
docker compose restart
```

## Troubleshooting

**Port 53 in use?**
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

**DNS not resolving?**
```bash
# Check container is running
docker compose ps

# Check logs
docker compose logs
```

## Examples

Add a new service to your zone file:
```dns
pihole      IN    A       192.168.1.20
grafana     IN    A       192.168.1.30
jenkins     IN    A       192.168.1.40
```

Then restart:
```bash
docker compose restart
```

Test it works:
```bash
dig @localhost pihole.homelab.local
```

## Full Documentation

- [README.md](README.md) - Complete documentation
- [DEPLOYMENT.md](DEPLOYMENT.md) - Advanced deployment scenarios

## Support

Open an issue on GitHub if you need help!
