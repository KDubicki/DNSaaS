#!/bin/bash

# DNSaaS Management Script
# Simplifies common management tasks

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

show_help() {
    cat << EOF
DNSaaS Management Script

Usage: ./manage.sh [command]

Commands:
    start       Start the DNS service
    stop        Stop the DNS service
    restart     Restart the DNS service
    status      Show service status
    logs        Show service logs (follow mode)
    test        Run DNS tests
    validate    Validate zone files
    update      Pull latest image and restart
    clean       Stop and remove containers

Examples:
    ./manage.sh start
    ./manage.sh logs
    ./manage.sh test

EOF
}

start_service() {
    echo "Starting DNSaaS..."
    docker-compose up -d
    echo "✓ DNSaaS started"
    echo "Waiting for service to be ready..."
    sleep 3
    docker-compose ps
}

stop_service() {
    echo "Stopping DNSaaS..."
    docker-compose down
    echo "✓ DNSaaS stopped"
}

restart_service() {
    echo "Restarting DNSaaS..."
    docker-compose restart
    echo "✓ DNSaaS restarted"
}

show_status() {
    echo "DNSaaS Status:"
    echo "------------------------"
    docker-compose ps
    echo ""
    echo "Container Stats:"
    docker stats --no-stream dnsaas-coredns 2>/dev/null || echo "Container not running"
}

show_logs() {
    echo "Following DNSaaS logs (Ctrl+C to exit)..."
    docker-compose logs -f
}

run_tests() {
    if [ -f "./test.sh" ]; then
        bash ./test.sh
    else
        echo "Error: test.sh not found"
        exit 1
    fi
}

validate_zones() {
    echo "Validating zone files..."
    
    if ! command -v named-checkzone >/dev/null 2>&1; then
        echo "⚠ named-checkzone not found. Install bind-utils to validate zones."
        echo "  Debian/Ubuntu: sudo apt-get install bind9-utils"
        echo "  RHEL/CentOS: sudo yum install bind-utils"
        exit 1
    fi
    
    for zonefile in zones/*.zone; do
        if [ -f "$zonefile" ]; then
            zonename=$(basename "$zonefile" .zone)
            echo -n "Checking $zonename... "
            if named-checkzone "$zonename" "$zonefile" >/dev/null 2>&1; then
                echo "✓ Valid"
            else
                echo "✗ Invalid"
                named-checkzone "$zonename" "$zonefile"
            fi
        fi
    done
}

update_service() {
    echo "Updating DNSaaS..."
    docker-compose pull
    docker-compose up -d
    echo "✓ DNSaaS updated"
}

clean_service() {
    echo "Cleaning DNSaaS..."
    docker-compose down -v
    echo "✓ DNSaaS cleaned (containers and volumes removed)"
}

# Main command handling
case "${1:-help}" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    test)
        run_tests
        ;;
    validate)
        validate_zones
        ;;
    update)
        update_service
        ;;
    clean)
        clean_service
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac
