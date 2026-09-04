# Terraform AWS OIDC Pipeline

A Terraform + GitHub Actions pipeline that provisions AWS infrastructure across isolated **dev** and **prod** environments, using OIDC federation instead of static AWS credentials.

## Features

### Secure Authentication (OIDC)
- Eliminated static, long-lived AWS access keys by configuring OpenID Connect (OIDC) federation between GitHub Actions and AWS IAM.
- GitHub Actions assumes a scoped IAM role at runtime via `sts:AssumeRoleWithWebIdentity`; no AWS credentials are stored as GitHub secrets.
- The IAM role's trust policy is scoped to the specific repository and restricted to defined subjects (pull requests, and the `dev` / `main` branches), so only workflows from this repo can assume it.

### Environment Isolation (Dev / Prod)
- `environment/dev` and `environment/prod` are independent Terraform root modules, each with its own S3 backend state file (distinct state keys), so the two environments never share or affect each other's resources.
- Native S3 state locking (`use_lockfile`) prevents concurrent runs from corrupting state, without requiring a separate DynamoDB lock table.

### Reusable Terraform Modules
- Shared infrastructure logic lives in a single `aws/` module (with a nested `web` submodule), instead of being duplicated per environment.
- Each environment calls the shared module with its own input variables, so a fix or improvement made once in `aws/` automatically applies to every environment that consumes it.

### CI/CD Workflows (GitHub Actions)
- **Plan on pull request**: automatically runs `terraform plan` when a PR targeting `dev` or `main` touches relevant paths, so changes can be reviewed before merging.
- **Apply on merge**: automatically runs `terraform apply` when a PR is merged into `dev` or `main`, keeping the live infrastructure in sync with the codebase.
- **Format check**: enforces consistent code style with `terraform fmt -check`.
- Workflow triggers are scoped with `paths` filters covering both the shared module (`aws/**`) and the environment-specific directory, so changes to either correctly trigger the pipeline.
- Optional manual approval gate on production deploys via a protected GitHub Environment.

### Infrastructure Provisioned
- VPC with a public subnet
- Internet Gateway
- EC2 instance (web server) with an attached security group
- Instance bootstrap via a `user_data` provisioning script

## Branching Model

```
feature branch → dev (PR + plan/apply) → main (PR + plan/apply, production)
```

Changes are validated in `dev` before being promoted to `main`, with each stage independently planned, reviewed, and applied.

## Tech Stack

- **Terraform** (>= 1.11)
- **AWS**: IAM (OIDC), S3 (remote state), VPC, EC2
- **GitHub Actions**: OIDC-based CI/CD
