#!/bin/sh

# VedantaTrade Health Check Script
# Used by Docker health check and monitoring systems

set -e

# Configuration
HEALTH_URL="http://localhost:8080/health"
API_HEALTH_URL="http://localhost:8080/api/health"
TIMEOUT=10
MAX_RETRIES=3

# Function to check URL
check_url() {
    local url="$1"
    local timeout="$2"
    
    if curl -f -s --max-time "$timeout" "$url" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if Nginx is running
check_nginx() {
    if pgrep nginx > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check disk space
check_disk_space() {
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$usage" -lt 90 ]; then
        return 0
    else
        return 1
    fi
}

# Function to check memory usage
check_memory() {
    local usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ "$usage" -lt 90 ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if application is ready
check_readiness() {
    local retry_count=0
    local max_retries=30
    
    while [ $retry_count -lt $max_retries ]; do
        if check_url "$HEALTH_URL" 5; then
            echo "Application is ready"
            return 0
        fi
        
        echo "Waiting for application to be ready... (attempt $((retry_count + 1))/$max_retries)"
        sleep 2
        retry_count=$((retry_count + 1))
    done
    
    echo "Application failed to become ready within timeout"
    return 1
}

# Main health check
main_health_check() {
    local failed_checks=0
    
    # Check if Nginx is running
    if ! check_nginx; then
        echo "❌ Nginx is not running"
        failed_checks=$((failed_checks + 1))
    else
        echo "✅ Nginx is running"
    fi
    
    # Check main health endpoint
    if check_url "$HEALTH_URL" "$TIMEOUT"; then
        echo "✅ Main health check passed"
    else
        echo "❌ Main health check failed"
        failed_checks=$((failed_checks + 1))
    fi
    
    # Check API health endpoint
    if check_url "$API_HEALTH_URL" "$TIMEOUT"; then
        echo "✅ API health check passed"
    else
        echo "❌ API health check failed"
        failed_checks=$((failed_checks + 1))
    fi
    
    # Check disk space
    if check_disk_space; then
        echo "✅ Disk space check passed"
    else
        echo "❌ Disk space check failed"
        failed_checks=$((failed_checks + 1))
    fi
    
    # Check memory usage
    if check_memory; then
        echo "✅ Memory usage check passed"
    else
        echo "❌ Memory usage check failed"
        failed_checks=$((failed_checks + 1))
    fi
    
    # Return overall health status
    if [ $failed_checks -eq 0 ]; then
        echo "🎉 All health checks passed"
        return 0
    else
        echo "💥 $failed_checks health check(s) failed"
        return 1
    fi
}

# Check command line arguments
case "${1:-health}" in
    "health")
        main_health_check
        ;;
    "ready")
        check_readiness
        ;;
    "nginx")
        check_nginx
        ;;
    "url")
        if [ -n "$2" ]; then
            check_url "$2" "$TIMEOUT"
        else
            echo "Usage: $0 url <url>"
            exit 1
        fi
        ;;
    "disk")
        check_disk_space
        ;;
    "memory")
        check_memory
        ;;
    *)
        echo "Usage: $0 {health|ready|nginx|url|disk|memory}"
        echo "  health  - Run comprehensive health check"
        echo "  ready   - Check if application is ready"
        echo "  nginx   - Check if Nginx is running"
        echo "  url     - Check specific URL"
        echo "  disk    - Check disk space"
        echo "  memory  - Check memory usage"
        exit 1
        ;;
esac
