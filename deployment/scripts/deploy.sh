#!/bin/bash

# VedantaTrade Deployment Script
# Automated deployment for production and staging environments

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
ENVIRONMENT="${1:-staging}"
VERSION="${2:-latest}"
REGION="${AWS_REGION:-us-east-1}"
BACKUP_ENABLED=true
ROLLBACK_ENABLED=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if required tools are installed
    local required_tools=("aws" "docker" "kubectl" "helm" "jq" "curl")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed or not in PATH"
            exit 1
        fi
    done
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        exit 1
    fi
    
    # Check Docker daemon
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check kubectl connection
    if ! kubectl cluster-info &> /dev/null; then
        log_warning "kubectl cannot connect to cluster (continuing anyway)"
    fi
    
    log_success "Prerequisites check passed"
}

# Function to validate environment
validate_environment() {
    log_info "Validating environment: $ENVIRONMENT"
    
    case "$ENVIRONMENT" in
        "staging"|"production")
            ;;
        *)
            log_error "Invalid environment: $ENVIRONMENT. Must be 'staging' or 'production'"
            exit 1
            ;;
    esac
    
    # Validate version format
    if [[ "$VERSION" != "latest" && ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid version format: $VERSION. Must be 'latest' or 'vX.Y.Z'"
        exit 1
    fi
    
    log_success "Environment validation passed"
}

# Function to build Docker image
build_docker_image() {
    log_info "Building Docker image..."
    
    local image_name="vedantatrade"
    local image_tag="$ENVIRONMENT-$VERSION"
    local full_image_name="$image_name:$image_tag"
    
    cd "$PROJECT_ROOT"
    
    # Build Docker image
    docker build \
        --tag "$full_image_name" \
        --build-arg ENVIRONMENT="$ENVIRONMENT" \
        --build-arg VERSION="$VERSION" \
        -f deployment/docker/Dockerfile \
        .
    
    log_success "Docker image built: $full_image_name"
    echo "$full_image_name"
}

# Function to push Docker image to registry
push_docker_image() {
    local image_name="$1"
    log_info "Pushing Docker image to registry..."
    
    # Get AWS ECR login
    aws ecr get-login-password --region "$REGION" | \
        docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
    
    # Tag and push to ECR
    local ecr_repository="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$image_name"
    docker tag "$image_name" "$ecr_repository:$image_tag"
    docker push "$ecr_repository:$image_tag"
    
    log_success "Docker image pushed to ECR: $ecr_repository:$image_tag"
}

# Function to create backup
create_backup() {
    if [ "$BACKUP_ENABLED" != "true" ]; then
        log_info "Backup is disabled, skipping"
        return 0
    fi
    
    log_info "Creating backup..."
    
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    local s3_bucket="${ENVIRONMENT}-backups"
    
    # Backup database (if applicable)
    if [ "$ENVIRONMENT" = "production" ]; then
        # Backup production database
        aws rds create-db-snapshot \
            --db-instance-identifier "vedantatrade-$ENVIRONMENT" \
            --db-snapshot-identifier "$backup_name-db" \
            --region "$REGION"
    fi
    
    # Backup S3 bucket
    aws s3 sync "s3://${ENVIRONMENT}-vedantatrade" "s3://$s3_bucket/$backup_name/" --delete
    
    log_success "Backup created: $backup_name"
    echo "$backup_name"
}

# Function to deploy to Kubernetes
deploy_kubernetes() {
    local image_name="$1"
    log_info "Deploying to Kubernetes..."
    
    local namespace="vedantatrade-$ENVIRONMENT"
    local helm_release="vedantatrade-$ENVIRONMENT"
    
    # Create namespace if it doesn't exist
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # Update Helm values
    cat > "deployment/helm/values-$ENVIRONMENT.yaml" << EOF
image:
  repository: $image_name
  tag: $VERSION
  pullPolicy: IfNotPresent

environment: $ENVIRONMENT
replicaCount: 3

service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: ${ENVIRONMENT}.vedantatrade.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

monitoring:
  enabled: true
  serviceMonitor:
    enabled: true

secrets:
  awsAccessKeyId: ${AWS_ACCESS_KEY_ID}
  awsSecretAccessKey: ${AWS_SECRET_ACCESS_KEY}
  databaseUrl: ${DATABASE_URL}
  jwtSecret: ${JWT_SECRET}
EOF
    
    # Deploy with Helm
    helm upgrade --install "$helm_release" \
        deployment/helm/ \
        --namespace "$namespace" \
        --values "deployment/helm/values-$ENVIRONMENT.yaml" \
        --wait \
        --timeout 10m
    
    log_success "Kubernetes deployment completed"
}

# Function to deploy to AWS ECS
deploy_ecs() {
    local image_name="$1"
    log_info "Deploying to AWS ECS..."
    
    local cluster_name="vedantatrade-$ENVIRONMENT"
    local service_name="vedantatrade-$ENVIRONMENT"
    local task_definition_name="vedantatrade-$ENVIRONMENT"
    
    # Update task definition
    aws ecs register-task-definition \
        --cli-input-json "$(cat << EOF
{
    "family": "$task_definition_name",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::$AWS_ACCOUNT_ID:role/ecsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::$AWS_ACCOUNT_ID:role/ecsTaskRole",
    "containerDefinitions": [
        {
            "name": "vedantatrade",
            "image": "$image_name",
            "portMappings": [
                {
                    "containerPort": 8080,
                    "protocol": "tcp"
                }
            ],
            "environment": [
                {
                    "name": "ENVIRONMENT",
                    "value": "$ENVIRONMENT"
                },
                {
                    "name": "VERSION",
                    "value": "$VERSION"
                }
            ],
            "secrets": [
                {
                    "name": "AWS_ACCESS_KEY_ID",
                    "valueFrom": "arn:aws:secretsmanager:$REGION:$AWS_ACCOUNT_ID:secret:vedantatrade/aws-access-key-id"
                },
                {
                    "name": "AWS_SECRET_ACCESS_KEY",
                    "valueFrom": "arn:aws:secretsmanager:$REGION:$AWS_ACCOUNT_ID:secret:vedantatrade/aws-secret-access-key"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/vedantatrade-$ENVIRONMENT",
                    "awslogs-region": "$REGION",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "healthCheck": {
                "command": ["CMD-SHELL", "/usr/local/bin/health-check.sh health"],
                "interval": 30,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 60
            }
        }
    ]
}
EOF
)"
    
    # Update service
    aws ecs update-service \
        --cluster "$cluster_name" \
        --service "$service_name" \
        --force-new-deployment
    
    # Wait for deployment to complete
    aws ecs wait services-stable \
        --cluster "$cluster_name" \
        --services "$service_name"
    
    log_success "ECS deployment completed"
}

# Function to deploy static assets to S3
deploy_static_assets() {
    log_info "Deploying static assets to S3..."
    
    local s3_bucket="${ENVIRONMENT}-vedantatrade"
    local distribution_id="${ENVIRONMENT}_CLOUDFRONT_DISTRIBUTION_ID"
    
    # Sync build files to S3
    aws s3 sync "$PROJECT_ROOT/build/web/" "s3://$s3_bucket/" \
        --delete \
        --exclude "*.DS_Store" \
        --exclude "*.git*" \
        --content-type "text/html" \
        --cache-control "max-age=0,no-cache,no-store,must-revalidate"
    
    # Set cache headers for static assets
    aws s3 sync "$PROJECT_ROOT/build/web/" "s3://$s3_bucket/" \
        --exclude "*.html" \
        --exclude "flutter_service_worker.js" \
        --cache-control "max-age=31536000,public,immutable"
    
    # Invalidate CloudFront cache
    if [ -n "${!distribution_id}" ]; then
        aws cloudfront create-invalidation \
            --distribution-id "${!distribution_id}" \
            --paths "/*"
    fi
    
    log_success "Static assets deployed to S3"
}

# Function to run health checks
run_health_checks() {
    log_info "Running health checks..."
    
    local base_url="https://${ENVIRONMENT}.vedantatrade.com"
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Health check attempt $attempt/$max_attempts"
        
        if curl -f "$base_url/health" > /dev/null 2>&1; then
            log_success "Health check passed"
            return 0
        fi
        
        log_warning "Health check failed, retrying in 10 seconds..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    log_error "Health check failed after $max_attempts attempts"
    return 1
}

# Function to rollback deployment
rollback_deployment() {
    if [ "$ROLLBACK_ENABLED" != "true" ]; then
        log_info "Rollback is disabled, skipping"
        return 0
    fi
    
    log_warning "Rolling back deployment..."
    
    # Get previous deployment
    local previous_revision=$(helm history "vedantatrade-$ENVIRONMENT" -n "vedantatrade-$ENVIRONMENT" -o json | \
        jq -r '.[] | select(.status != "failed") | .revision' | tail -n 1)
    
    if [ -n "$previous_revision" ]; then
        helm rollback "vedantatrade-$ENVIRONMENT" "$previous_revision" -n "vedantatrade-$ENVIRONMENT"
        log_success "Rollback completed to revision $previous_revision"
    else
        log_error "No previous revision found for rollback"
        return 1
    fi
}

# Function to send deployment notification
send_notification() {
    local status="$1"
    local message="$2"
    
    log_info "Sending deployment notification..."
    
    # Send Slack notification
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        local color="good"
        if [ "$status" = "failure" ]; then
            color="danger"
        elif [ "$status" = "warning" ]; then
            color="warning"
        fi
        
        curl -X POST -H 'Content-type: application/json' \
            --data "$(cat << EOF
{
    "text": "VedantaTrade Deployment: $status",
    "attachments": [
        {
            "color": "$color",
            "fields": [
                {
                    "title": "Environment",
                    "value": "$ENVIRONMENT",
                    "short": true
                },
                {
                    "title": "Version",
                    "value": "$VERSION",
                    "short": true
                },
                {
                    "title": "Message",
                    "value": "$message",
                    "short": false
                }
            ]
        }
    ]
}
EOF
)" \
            "$SLACK_WEBHOOK_URL"
    fi
    
    log_success "Notification sent"
}

# Main deployment function
main() {
    log_info "Starting VedantaTrade deployment..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Version: $VERSION"
    log_info "Region: $REGION"
    
    # Check prerequisites
    check_prerequisites
    
    # Validate environment
    validate_environment
    
    # Create backup
    local backup_name
    backup_name=$(create_backup)
    
    # Build Docker image
    local image_name
    image_name=$(build_docker_image)
    
    # Push Docker image
    push_docker_image "$image_name"
    
    # Deploy based on environment
    case "$ENVIRONMENT" in
        "production")
            deploy_kubernetes "$image_name"
            ;;
        "staging")
            deploy_static_assets
            ;;
    esac
    
    # Run health checks
    if run_health_checks; then
        send_notification "success" "Deployment completed successfully"
        log_success "Deployment completed successfully! 🎉"
    else
        send_notification "failure" "Deployment failed health checks"
        log_error "Deployment failed health checks"
        
        # Attempt rollback
        if rollback_deployment; then
            send_notification "warning" "Deployment rolled back"
            log_warning "Deployment rolled back"
        else
            send_notification "failure" "Rollback failed"
            log_error "Rollback failed"
        fi
        
        exit 1
    fi
}

# Handle script arguments
case "${1:-help}" in
    "staging"|"production")
        main "$@"
        ;;
    "rollback")
        rollback_deployment
        ;;
    "health")
        run_health_checks
        ;;
    "backup")
        create_backup
        ;;
    "help")
        echo "Usage: $0 {staging|production|rollback|health|backup} [version]"
        echo "  staging    - Deploy to staging environment"
        echo "  production - Deploy to production environment"
        echo "  rollback   - Rollback current deployment"
        echo "  health     - Run health checks"
        echo "  backup     - Create backup"
        exit 0
        ;;
    *)
        log_error "Invalid command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
