# AWS ECS Infrastructure with Terraform & CI/CD


<p align="center">
  <img src="Project.png" alt="Project Screenshot" width="800"/>
</p>


This project implements a highly available, scalable containerized application infrastructure on AWS using ECS (Elastic Container Service) with a focus on security, automation, and infrastructure as code, all orchestrated through a comprehensive GitLab CI/CD pipeline.

# CI/CD Pipeline (.gitlab-ci.yml)
The project uses a multi-stage GitLab CI/CD pipeline with Docker-in-Docker (dind) for container builds and deployments:

```yaml
Stages:
  ├── Test and Lint           # Code quality and validation
  ├── Build and Push          # Container image creation
  ├── Deploy                   # Infrastructure deployment
  └── Destroy                  # Manual infrastructure cleanup
```

### Pipeline Jobs

#### **Python Checker**
Runs Django tests and Flake8 linting:
- `python manage.py wait_for_db && python manage.py test` - Database readiness check and test execution
- `flake8` - Code style enforcement
- **Triggers on**: Merge requests to main/prod or direct commits to main/prod branches

#### **Terraform Checks**
Validates infrastructure code:
- Initializes Terraform without backend (`-backend=false`) for both SetUp and Deploy directories
- Runs `terraform validate` to check configuration syntax
- Runs `terraform fmt` and `fmt -check` to ensure code formatting standards
- Ensures code correctness before deployment

#### **Push to ECR**
Builds and pushes Docker images:
- Authenticates with AWS ECR using AWS CLI
- Builds **app** and **proxy** images with compression for smaller image sizes
- Tags images with both commit SHA (for versioning) and `latest` (for current)
- Pushes to respective ECR repositories for storage and deployment

#### **Terraform Apply**
Deploys infrastructure with workspace awareness:
- Dynamically selects workspace (`staging` for main branch, `prod` for prod branch)
- Injects ECR image URLs as Terraform variables for task definitions
- Initializes Terraform backend and applies infrastructure changes
- Automatically approves deployment for CI/CD automation

#### **Destroy**
Manual cleanup job:
- Selects appropriate workspace based on branch (staging/prod)
- Destroys all infrastructure resources
- **Requires manual trigger** - Protection against accidental deletion
- Useful for environment teardown and cost management













# Terraform Directory Structure:
The project uses a modular Terraform setup with two main directories:

```txt
Terraform/
├── SetUp/                    # Bootstrap infrastructure (run once)
│   ├── ECR.tf               # Elastic Container Registry repositories
│   ├── IAM.tf               # CI/CD user, roles, and policies
│   ├── main.tf              # Provider and backend config
│   ├── output.tf            # Outputs for Deploy directory
│   └── var.tf               # Variables for Setup
│
└── Deploy/                   # Main infrastructure (CI/CD pipeline)
    ├── ALB.tf               # Application Load Balancer config
    ├── Database.tf           # RDS database instances
    ├── dns.tf               # Route53 DNS records
    ├── ECS.tf               # ECS clusters, tasks, services
    ├── EFS.tf               # Elastic File System for shared storage
    ├── Network.tf           # VPC, subnets, route tables, endpoints
    ├── main.tf              # Provider and backend config
    ├── locals.tf            # Local variables
    ├── output.tf            # Output values
    ├── terraform.tf         # Terraform version/backend settings
    ├── var.tf               # Input variables
    └── templates/           # Task definition templates

```
## Key Components:

- **Container Orchestration:** ECS clusters running API services and proxy containers across private subnets

- **Infrastructure as Code**:
  - **SetUp directory**: One-time setup for ECR repositories and CI/CD IAM roles
  - **Deploy directory**: Main infrastructure deployed via CI/CD pipeline (VPC, ECS, EFS, ALB, RDS, DNS)
- **Storage**: EFS for shared persistent storage (NFS) across ECS tasks

- **Networking**: Private subnet architecture with VPC endpoints for secure AWS service access

- **CI/CD Integration**: GitLab CI/CD with workspace-aware deployments (staging/prod)

- **Security**:
  - ACM for TLS certificate management
  - SSH/SSM interface endpoints for secure instance access
  - Private network architecture with NAT gateways
  - IAM roles with least-privilege permissions
  - Docker Hub authentication for base images

- **Monitoring**: CloudWatch integration for logs and metrics

- **Container Registry**: ECR repositories with dual tagging (commit SHA + latest)

- **Load Balancing**: Application Load Balancer for traffic distribution

- **Database**: RDS instances in private subnets

- **DNS**: Route53 record management


# Key Components:
- Container Orchestration: ECS clusters running API services and proxy containers across private subnets

- Infrastructure as Code: Terraform with remote state management (S3) and state locking (DynamoDB)

- Storage: EFS for shared persistent storage (NFS) across ECS tasks

- Networking: Private subnet architecture with VPC endpoints for secure AWS service access

- CI/CD Integration: GitLab/GitHub pipelines for automated deployments

## Security:

- ACM for TLS certificate management

- SSH/SSM interface endpoints for secure instance access

- Private network architecture

- Monitoring: CloudWatch integration for logs and metrics

- Container Registry: ECR for Docker image storage

## Architecture Highlights:
- **Multi-environment support:** Automatic workspace selection (staging/prod) based on branch

- **Immutable deployments:** Each commit gets a unique image tag for versioning

- **Service-to-service communication:** Proxy layer for request routing

- **Secure AWS service access:** Interface endpoints (ECR, CloudWatch, EFS, SSM)

- **Separation of concerns:** Bootstrap infrastructure (SetUp) vs. application infrastructure (Deploy)

- **Complete CI/CD lifecycle:** Testing → Building → Deployment → Manual destruction

- **Quality gates:** Automated linting and validation before deployment

- **Docker-in-Docker:** Isolated container builds within CI/CD pipeline

This infrastructure provides a production-ready, secure, and scalable platform for running containerized applications with fully automated GitLab CI/CD pipelines, comprehensive testing, and a clean separation between bootstrap and application infrastructure.