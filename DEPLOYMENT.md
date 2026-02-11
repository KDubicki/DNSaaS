# Deployment Guide for DNSaaS

This guide provides detailed instructions for deploying DNSaaS in different home lab scenarios.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Raspberry Pi Deployment](#raspberry-pi-deployment)
3. [Proxmox LXC Container](#proxmox-lxc-container)
4. [Docker Swarm Deployment](#docker-swarm-deployment)
5. [Kubernetes Deployment](#kubernetes-deployment)
6. [Integration with Pi-hole](#integration-with-pi-hole)

## Basic Setup

### Prerequisites Check

```bash
# Check Docker version
docker --version  # Should be 20.10+

# Check Docker Compose version
docker-compose --version  # Should be v2.0+

# Check available ports
sudo lsof -i :53
```

### Installation Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/KDubicki/DNSaaS.git
   cd DNSaaS
   ```

2. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   nano .env
   ```

3. **Customize Zone File**
   ```bash
   # Edit the zone file for your network
   nano zones/homelab.local.zone
   
   # Update these values:
   # - ns1 IP address (your server's IP)
   # - All service IP addresses
   # - SOA serial number when making changes
   ```

4. **Start Service**
   ```bash
   ./manage.sh start
   ```

5. **Verify**
   ```bash
   ./manage.sh test
   ```

## Raspberry Pi Deployment

Perfect for running a dedicated DNS server on a Raspberry Pi.

### Hardware Requirements

- Raspberry Pi 3B+ or newer
- microSD card (8GB minimum)
- Stable network connection (Ethernet recommended)

### Setup

1. **Install Raspberry Pi OS Lite**
   ```bash
   # Use Raspberry Pi Imager
   # Enable SSH in imager settings
   ```

2. **Update System**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Install Docker**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

4. **Install Docker Compose**
   ```bash
   sudo apt install docker-compose -y
   ```

5. **Set Static IP** (recommended)
   ```bash
   sudo nano /etc/dhcpcd.conf
   ```
   
   Add:
   ```
   interface eth0
   static ip_address=192.168.1.10/24
   static routers=192.168.1.1
   static domain_name_servers=8.8.8.8 8.8.4.4
   ```

6. **Deploy DNSaaS**
   ```bash
   git clone https://github.com/KDubicki/DNSaaS.git
   cd DNSaaS
   ./manage.sh start
   ```

7. **Enable Service on Boot**
   ```bash
   # Create systemd service
   sudo nano /etc/systemd/system/dnsaas.service
   ```
   
   Add:
   ```ini
   [Unit]
   Description=DNSaaS DNS Service
   Requires=docker.service
   After=docker.service

   [Service]
   Type=oneshot
   RemainAfterExit=yes
   WorkingDirectory=/home/pi/DNSaaS
   ExecStart=/usr/bin/docker-compose up -d
   ExecStop=/usr/bin/docker-compose down
   User=pi

   [Install]
   WantedBy=multi-user.target
   ```
   
   Enable:
   ```bash
   sudo systemctl enable dnsaas
   sudo systemctl start dnsaas
   ```

## Proxmox LXC Container

Deploy in a lightweight LXC container on Proxmox.

### Container Creation

1. **Create Ubuntu LXC Container**
   - Template: Ubuntu 22.04
   - Disk: 8GB
   - CPU: 1 core
   - RAM: 512MB
   - Network: Static IP (e.g., 192.168.1.10)

2. **Container Setup**
   ```bash
   # Inside container
   apt update && apt upgrade -y
   apt install docker.io docker-compose git -y
   ```

3. **Deploy DNSaaS**
   ```bash
   git clone https://github.com/KDubicki/DNSaaS.git
   cd DNSaaS
   ./manage.sh start
   ```

### Proxmox Firewall Rules

```bash
# Allow DNS traffic
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
```

## Docker Swarm Deployment

For high availability across multiple nodes.

### docker-compose.swarm.yml

```yaml
version: '3.8'

services:
  coredns:
    image: coredns/coredns:latest
    ports:
      - target: 53
        published: 53
        protocol: udp
        mode: host
      - target: 53
        published: 53
        protocol: tcp
        mode: host
      - target: 9153
        published: 9153
        protocol: tcp
        mode: host
    configs:
      - source: corefile
        target: /etc/coredns/Corefile
      - source: zonefile
        target: /etc/coredns/zones/homelab.local.zone
    command: -conf /etc/coredns/Corefile
    deploy:
      mode: replicated
      replicas: 2
      placement:
        constraints:
          - node.role == worker
      restart_policy:
        condition: on-failure
        delay: 5s

configs:
  corefile:
    file: ./Corefile
  zonefile:
    file: ./zones/homelab.local.zone

networks:
  default:
    driver: overlay
```

### Deploy to Swarm

```bash
docker stack deploy -c docker-compose.swarm.yml dnsaas
```

## Kubernetes Deployment

For Kubernetes home lab environments.

### kubernetes/

Create these files in a `kubernetes/` directory:

**configmap.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-config
  namespace: dns-system
data:
  Corefile: |
    . {
        forward . 8.8.8.8 8.8.4.4 1.1.1.1
        cache 30
        log
        errors
        health
        prometheus :9153
    }
    homelab.local {
        file /etc/coredns/zones/homelab.local.zone
        log
        errors
    }
  homelab.local.zone: |
    $ORIGIN homelab.local.
    $TTL 3600
    @       IN      SOA     ns1.homelab.local. admin.homelab.local. (
                            2026021101
                            3600
                            1800
                            604800
                            86400 )
    @       IN      NS      ns1.homelab.local.
    ns1     IN      A       192.168.1.10
```

**deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: dns-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: coredns
  template:
    metadata:
      labels:
        app: coredns
    spec:
      containers:
      - name: coredns
        image: coredns/coredns:latest
        args: [ "-conf", "/etc/coredns/Corefile" ]
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        volumeMounts:
        - name: config
          mountPath: /etc/coredns
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: coredns-config
```

**service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: coredns
  namespace: dns-system
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.1.10
  ports:
  - name: dns
    port: 53
    protocol: UDP
    targetPort: 53
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: 53
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: 9153
  selector:
    app: coredns
```

### Deploy to Kubernetes

```bash
kubectl create namespace dns-system
kubectl apply -f kubernetes/
```

## Integration with Pi-hole

Use DNSaaS as upstream DNS for Pi-hole.

### Pi-hole Configuration

1. **Access Pi-hole Admin**
   - Navigate to `http://pi.hole/admin`

2. **Settings → DNS**
   - Uncheck all upstream DNS servers
   - Add custom DNS server: `192.168.1.10#53`
   - Save settings

3. **Test Integration**
   ```bash
   # From a client using Pi-hole
   dig nas.homelab.local
   ```

### Benefits

- Pi-hole handles ad-blocking
- DNSaaS handles local name resolution
- Centralized DNS management

## Monitoring and Maintenance

### Prometheus Integration

**prometheus.yml**
```yaml
scrape_configs:
  - job_name: 'coredns'
    static_configs:
      - targets: ['192.168.1.10:9153']
```

### Grafana Dashboard

Import CoreDNS dashboard:
- Dashboard ID: 5926
- Or create custom dashboard using metrics from `/metrics`

### Log Rotation

```bash
# Add to /etc/logrotate.d/docker-container
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size 10M
    missingok
    delaycompress
    copytruncate
}
```

## Backup and Recovery

### Backup Configuration

```bash
#!/bin/bash
# backup.sh
tar -czf dnsaas-backup-$(date +%Y%m%d).tar.gz \
  Corefile \
  zones/ \
  docker-compose.yml \
  .env
```

### Restore

```bash
tar -xzf dnsaas-backup-20260211.tar.gz
./manage.sh restart
```

## Troubleshooting

### Common Issues

**Issue**: Port 53 already in use
```bash
# Stop systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Or change /etc/resolv.conf
sudo rm /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

**Issue**: Container won't start
```bash
# Check logs
docker-compose logs

# Check disk space
df -h

# Verify configuration
docker-compose config
```

**Issue**: DNS queries timeout
```bash
# Check firewall
sudo ufw allow 53/udp
sudo ufw allow 53/tcp

# Test from server
dig @localhost google.com

# Check routing
ip route
```

## Performance Tuning

### For High-Traffic Environments

Edit `Corefile`:
```dns
. {
    forward . 8.8.8.8 8.8.4.4 1.1.1.1 {
        max_concurrent 1000
    }
    cache 300  # Increase cache time
    log
    errors
}
```

### Resource Limits

Edit `docker-compose.yml`:
```yaml
services:
  coredns:
    # ... other config ...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
```

## Security Hardening

1. **Limit Access**
   ```bash
   # iptables rules
   sudo iptables -A INPUT -p udp --dport 53 -s 192.168.1.0/24 -j ACCEPT
   sudo iptables -A INPUT -p udp --dport 53 -j DROP
   ```

2. **Regular Updates**
   ```bash
   # Add to crontab
   0 2 * * 0 cd /path/to/DNSaaS && ./manage.sh update
   ```

3. **Monitor Queries**
   ```bash
   # Watch for unusual patterns
   docker-compose logs -f | grep -i "query"
   ```

## Next Steps

- Configure your router to use DNSaaS as primary DNS
- Add all your home lab services to the zone file
- Set up monitoring with Prometheus/Grafana
- Configure automatic backups
- Integrate with existing infrastructure (Pi-hole, etc.)

For additional help, see the main [README.md](README.md) or open an issue on GitHub.
