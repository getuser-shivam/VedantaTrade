#!/bin/sh

# VedantaTrade Monitoring Script
# Provides comprehensive monitoring and alerting for the application

set -e

# Configuration
METRICS_URL="http://localhost:8080/metrics"
HEALTH_URL="http://localhost:8080/health"
LOG_FILE="/var/log/nginx/access.log"
ERROR_LOG_FILE="/var/log/nginx/error.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_DISK=90
ALERT_THRESHOLD_RESPONSE_TIME=2000

# Function to get system metrics
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
}

get_memory_usage() {
    free | awk 'NR==2{printf "%.0f", $3*100/$2}'
}

get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'
}

get_response_time() {
    local url="$1"
    curl -o /dev/null -s -w "%{time_total}" "$url" | awk '{printf "%.0f", $1*1000}'
}

get_request_count() {
    local minutes="${1:-5}"
    local timestamp=$(date -d "$minutes minutes ago" "+%d/%b/%Y:%H:%M")
    awk -v date="$timestamp" '$0 ~ date {count++} END {print count+0}' "$LOG_FILE"
}

get_error_count() {
    local minutes="${1:-5}"
    local timestamp=$(date -d "$minutes minutes ago" "+%d/%b/%Y:%H:%M")
    awk -v date="$timestamp" '$0 ~ date && $9 >= 400 {count++} END {print count+0}' "$LOG_FILE"
}

get_nginx_connections() {
    curl -s "$METRICS_URL" | grep "connections" | head -1 | awk '{print $2}'
}

# Function to check thresholds and send alerts
check_thresholds() {
    local metric_name="$1"
    local current_value="$2"
    local threshold="$3"
    local unit="$4"
    
    if [ "$current_value" -gt "$threshold" ]; then
        echo "🚨 ALERT: $metric_name is $current_value$unit (threshold: $threshold$unit)"
        return 1
    else
        echo "✅ OK: $metric_name is $current_value$unit (threshold: $threshold$unit)"
        return 0
    fi
}

# Function to generate performance report
generate_performance_report() {
    local report_file="/tmp/performance_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "📊 VedantaTrade Performance Report" > "$report_file"
    echo "Generated: $(date)" >> "$report_file"
    echo "=================================" >> "$report_file"
    echo "" >> "$report_file"
    
    # System metrics
    echo "🖥️  System Metrics:" >> "$report_file"
    echo "CPU Usage: $(get_cpu_usage)%" >> "$report_file"
    echo "Memory Usage: $(get_memory_usage)%" >> "$report_file"
    echo "Disk Usage: $(get_disk_usage)%" >> "$report_file"
    echo "Load Average: $(get_load_average)" >> "$report_file"
    echo "" >> "$report_file"
    
    # Application metrics
    echo "🚀 Application Metrics:" >> "$report_file"
    echo "Response Time: $(get_response_time "$HEALTH_URL")ms" >> "$report_file"
    echo "Nginx Connections: $(get_nginx_connections)" >> "$report_file"
    echo "Requests (last 5 min): $(get_request_count 5)" >> "$report_file"
    echo "Errors (last 5 min): $(get_error_count 5)" >> "$report_file"
    echo "" >> "$report_file"
    
    # Health status
    echo "🏥 Health Status:" >> "$report_file"
    if /usr/local/bin/health-check.sh health > /dev/null 2>&1; then
        echo "Overall Health: HEALTHY" >> "$report_file"
    else
        echo "Overall Health: UNHEALTHY" >> "$report_file"
    fi
    
    echo "Report saved to: $report_file"
    return 0
}

# Function to monitor real-time metrics
monitor_realtime() {
    local interval="${1:-30}"
    
    echo "🔍 Starting real-time monitoring (interval: ${interval}s)"
    echo "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        clear
        echo "📊 VedantaTrade Real-time Monitor"
        echo "Last updated: $(date)"
        echo "================================="
        echo ""
        
        # System metrics
        echo "🖥️  System Metrics:"
        echo "CPU Usage: $(get_cpu_usage)%"
        echo "Memory Usage: $(get_memory_usage)%"
        echo "Disk Usage: $(get_disk_usage)%"
        echo "Load Average: $(get_load_average)"
        echo ""
        
        # Application metrics
        echo "🚀 Application Metrics:"
        echo "Response Time: $(get_response_time "$HEALTH_URL")ms"
        echo "Nginx Connections: $(get_nginx_connections)"
        echo "Requests (last 5 min): $(get_request_count 5)"
        echo "Errors (last 5 min): $(get_error_count 5)"
        echo ""
        
        # Health status
        echo "🏥 Health Status:"
        if /usr/local/bin/health-check.sh health > /dev/null 2>&1; then
            echo "Overall Health: ✅ HEALTHY"
        else
            echo "Overall Health: ❌ UNHEALTHY"
        fi
        echo ""
        
        # Recent errors
        echo "🚨 Recent Errors (last 10):"
        tail -10 "$ERROR_LOG_FILE" | grep -E "(error|ERROR|fail|FAIL)" | tail -3
        echo ""
        
        sleep "$interval"
    done
}

# Function to check performance thresholds
check_performance() {
    local alerts=0
    
    echo "🔍 Checking performance thresholds..."
    
    # Check CPU usage
    cpu_usage=$(get_cpu_usage)
    if ! check_thresholds "CPU Usage" "$cpu_usage" "$ALERT_THRESHOLD_CPU" "%"; then
        alerts=$((alerts + 1))
    fi
    
    # Check memory usage
    memory_usage=$(get_memory_usage)
    if ! check_thresholds "Memory Usage" "$memory_usage" "$ALERT_THRESHOLD_MEMORY" "%"; then
        alerts=$((alerts + 1))
    fi
    
    # Check disk usage
    disk_usage=$(get_disk_usage)
    if ! check_thresholds "Disk Usage" "$disk_usage" "$ALERT_THRESHOLD_DISK" "%"; then
        alerts=$((alerts + 1))
    fi
    
    # Check response time
    response_time=$(get_response_time "$HEALTH_URL")
    if ! check_thresholds "Response Time" "$response_time" "$ALERT_THRESHOLD_RESPONSE_TIME" "ms"; then
        alerts=$((alerts + 1))
    fi
    
    # Check error rate
    total_requests=$(get_request_count 5)
    total_errors=$(get_error_count 5)
    if [ "$total_requests" -gt 0 ]; then
        error_rate=$((total_errors * 100 / total_requests))
        if [ "$error_rate" -gt 5 ]; then
            echo "🚨 ALERT: Error rate is ${error_rate}% (threshold: 5%)"
            alerts=$((alerts + 1))
        else
            echo "✅ OK: Error rate is ${error_rate}% (threshold: 5%)"
        fi
    fi
    
    if [ $alerts -eq 0 ]; then
        echo "🎉 All performance checks passed"
        return 0
    else
        echo "💥 $alerts performance alert(s) triggered"
        return 1
    fi
}

# Function to analyze logs
analyze_logs() {
    local minutes="${1:-60}"
    local timestamp=$(date -d "$minutes minutes ago" "+%d/%b/%Y:%H:%M")
    
    echo "📋 Log Analysis (last $minutes minutes)"
    echo "================================="
    echo ""
    
    # Request analysis
    echo "📊 Request Statistics:"
    local total_requests=$(awk -v date="$timestamp" '$0 ~ date {count++} END {print count+0}' "$LOG_FILE")
    echo "Total Requests: $total_requests"
    
    # Status code distribution
    echo "Status Code Distribution:"
    awk -v date="$timestamp" '$0 ~ date {count[$9]++} END {for (code in count) print code ": " count[code]}' "$LOG_FILE" | sort -k2 -nr
    
    # Top URLs
    echo ""
    echo "🔝 Top 10 URLs:"
    awk -v date="$timestamp" '$0 ~ date {count[$7]++} END {for (url in count) print count[url], url}' "$LOG_FILE" | sort -nr | head -10
    
    # Error analysis
    echo ""
    echo "🚨 Error Analysis:"
    local error_count=$(awk -v date="$timestamp" '$0 ~ date && $9 >= 400 {count++} END {print count+0}' "$LOG_FILE")
    echo "Total Errors: $error_count"
    
    if [ "$error_count" -gt 0 ]; then
        echo "Recent Errors:"
        awk -v date="$timestamp" '$0 ~ date && $9 >= 400 {print $0}' "$LOG_FILE" | tail -5
    fi
    
    # User agents
    echo ""
    echo "👥 Top User Agents:"
    awk -v date="$timestamp" '$0 ~ date {count[$12]++} END {for (ua in count) print count[ua], ua}' "$LOG_FILE" | sort -nr | head -5
}

# Function to send alerts (placeholder for real implementation)
send_alert() {
    local message="$1"
    local severity="$2"  # info, warning, critical
    
    echo "📢 ALERT: $message (Severity: $severity)"
    
    # In a real implementation, this would send to:
    # - Slack webhook
    # - Email notification
    # - PagerDuty
    # - Monitoring system
    
    # Example Slack webhook (commented out for demo)
    # curl -X POST -H 'Content-type: application/json' \
    #     --data "{\"text\":\"$message\"}" \
    #     "$SLACK_WEBHOOK_URL"
}

# Function to setup monitoring
setup_monitoring() {
    echo "🔧 Setting up monitoring..."
    
    # Create log directories
    mkdir -p /var/log/vedantatrade
    mkdir -p /tmp/vedantatrade
    
    # Setup log rotation
    cat > /etc/logrotate.d/vedantatrade << EOF
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 nginx nginx
    postrotate
        /usr/sbin/nginx -s reload
    endscript
}
EOF
    
    echo "✅ Monitoring setup complete"
}

# Main function
main() {
    case "${1:-help}" in
        "realtime")
            monitor_realtime "${2:-30}"
            ;;
        "performance")
            check_performance
            ;;
        "report")
            generate_performance_report
            ;;
        "logs")
            analyze_logs "${2:-60}"
            ;;
        "setup")
            setup_monitoring
            ;;
        "alert")
            send_alert "${2:-Test alert}" "${3:-info}"
            ;;
        "help")
            echo "Usage: $0 {realtime|performance|report|logs|setup|alert}"
            echo "  realtime [seconds]  - Real-time monitoring dashboard"
            echo "  performance         - Check performance thresholds"
            echo "  report             - Generate performance report"
            echo "  logs [minutes]      - Analyze recent logs"
            echo "  setup              - Setup monitoring infrastructure"
            echo "  alert <message>    - Send test alert"
            exit 0
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
