# DNSaaS - DNS as a Service for Home Lab

A lightweight, Docker-based DNS service designed for home lab environments. This project uses CoreDNS to provide a fast, flexible, and easy-to-configure DNS server perfect for managing local network services.

## Features

- 🚀 **Easy Deployment**: Single command Docker Compose setup
- 🔧 **Customizable**: Simple zone file configuration for your home lab
- 📊 **Monitoring**: Built-in Prometheus metrics endpoint
- 🔄 **Upstream Forwarding**: Automatic forwarding to public DNS servers (Google, Cloudflare)
- 💾 **Caching**: DNS response caching for improved performance
- 🏥 **Health Checks**: Built-in health monitoring
- 🔍 **Logging**: Comprehensive query and error logging

## Prerequisites

- Docker Engine 20.10 or higher
- Docker Compose v2.0 or higher
- A home lab network (typically 192.168.x.x or 10.x.x.x)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/KDubicki/DNSaaS.git
cd DNSaaS
```

### 2. Configure Your Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` to match your network configuration (optional - defaults work for most setups).

### 3. Customize Zone Files

Edit `zones/homelab.local.zone` to add your home lab services:

```bash
nano zones/homelab.local.zone
```

Update the IP addresses to match your network:
- Change `192.168.1.10` to your DNS server's IP
- Add/modify records for your services (NAS, Proxmox, etc.)

### 4. Start the DNS Service

```bash
docker-compose up -d
```

### 5. Verify the Service

Check that the service is running:

```bash
docker-compose ps
docker-compose logs -f
```

Test DNS resolution:

```bash
# Test local domain resolution
dig @localhost nas.homelab.local

# Test external DNS forwarding
dig @localhost google.com
```

## Configuration

### Corefile

The main CoreDNS configuration file. Key sections:

- **Root Zone (.)**: Forwards all queries to upstream DNS servers (Google DNS, Cloudflare)
- **Local Zone (homelab.local)**: Serves records from your zone file
- **Plugins**: Caching, logging, health checks, and metrics

### Zone Files

Located in the `zones/` directory. The example file `homelab.local.zone` includes:

- **SOA Record**: Start of Authority for your domain
- **NS Record**: Name server designation
- **A Records**: IPv4 address mappings for your services
- **CNAME Records**: Aliases for services

#### Example Zone File Entry

```dns
; Add a new service
pihole    IN    A    192.168.1.20

; Add an alias
dns       IN    CNAME    pihole.homelab.local.
```

### Docker Compose Configuration

The `docker-compose.yml` file configures:

- **Ports**: 53/UDP and 53/TCP for DNS, 9153/TCP for Prometheus metrics
- **Volumes**: Mounts Corefile and zone files as read-only
- **Health Checks**: Ensures the service is responsive
- **Restart Policy**: Automatically restarts on failure

## Network Setup

### Option 1: Use as Primary DNS (Recommended)

Configure your router to use this DNS server as the primary DNS for your network:

1. Access your router's admin panel
2. Navigate to DHCP/DNS settings
3. Set Primary DNS to your server's IP (e.g., 192.168.1.10)
4. Set Secondary DNS to 8.8.8.8 or 1.1.1.1 (fallback)

### Option 2: Per-Device Configuration

Configure individual devices to use the DNS server:

**Linux/macOS:**
```bash
sudo nano /etc/resolv.conf
```
Add: `nameserver 192.168.1.10`

**Windows:**
1. Network Settings → Change Adapter Options
2. Right-click your connection → Properties
3. IPv4 → Properties → Use the following DNS server
4. Preferred DNS: `192.168.1.10`

## Management

### View Logs

```bash
docker-compose logs -f
```

### Restart Service

```bash
docker-compose restart
```

### Stop Service

```bash
docker-compose down
```

### Update Zone Files

1. Edit the zone file: `nano zones/homelab.local.zone`
2. Increment the serial number in the SOA record
3. Restart the service: `docker-compose restart`

## Monitoring

### Prometheus Metrics

Access metrics at `http://<server-ip>:9153/metrics`

Example metrics:
- DNS query count
- Cache hit/miss rates
- Response times
- Query types

### Health Check

The service includes an automatic health check. View status:

```bash
docker inspect dnsaas-coredns | grep Health -A 10
```

## Troubleshooting

### DNS Not Resolving

1. Check if the container is running:
   ```bash
   docker-compose ps
   ```

2. Check logs for errors:
   ```bash
   docker-compose logs
   ```

3. Verify port 53 is not in use:
   ```bash
   sudo lsof -i :53
   ```

4. Test DNS from the container:
   ```bash
   docker exec dnsaas-coredns /coredns -version
   ```

### Port 53 Already in Use

Some systems run `systemd-resolved` on port 53. To disable:

```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

### Zone File Syntax Errors

Validate your zone file syntax:
```bash
# Install bind-tools
sudo apt-get install bind9-utils  # Debian/Ubuntu
sudo yum install bind-utils        # RHEL/CentOS

# Check zone file
named-checkzone homelab.local zones/homelab.local.zone
```

### Permissions Issues

Ensure zone files are readable:
```bash
chmod 644 zones/*.zone
```

## Advanced Configuration

### Custom Upstream DNS

Edit `Corefile` to change upstream DNS servers:

```dns
. {
    forward . 9.9.9.9 149.112.112.112  # Quad9 DNS
    cache 30
    log
    errors
}
```

### Multiple Zone Files

Add additional local domains by creating new zone files and updating `Corefile`:

```dns
internal.lan {
    file /etc/coredns/zones/internal.lan.zone
    log
    errors
}
```

### DNS over TLS (DoT)

For enhanced privacy, configure CoreDNS to use DNS over TLS for upstream queries. See [CoreDNS forward plugin documentation](https://coredns.io/plugins/forward/).

## Security Considerations

- **Firewall**: Limit access to port 53 to your local network only
- **Updates**: Regularly update the CoreDNS image: `docker-compose pull && docker-compose up -d`
- **Zone Files**: Keep zone files in version control but exclude sensitive data
- **Monitoring**: Monitor DNS query logs for unusual activity

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is provided as-is for home lab use. Modify and distribute freely.

## Resources

- [CoreDNS Documentation](https://coredns.io/)
- [CoreDNS Plugins](https://coredns.io/plugins/)
- [Docker Documentation](https://docs.docker.com/)
- [DNS Zone File Format](https://en.wikipedia.org/wiki/Zone_file)

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Happy Home Labbing! 🏠🧪**