# Vistra-DevOps-assignment

Serverless Infrastructure Design with Terraform and AWS

## Project Overview

This repository implements a serverless REST API (items management) using AWS Lambda (Node.js 22), API Gateway REST API (proxy integration), DynamoDB, S3, IAM and CloudWatch. Terraform is used for all infrastructure as code and modularized for maintainability.

## Folder Structure

- `modules/` - Terraform modules for reusable components
  - `lambda/` - Lambda module
  - `api-gateway/` - API Gateway module
  - `dynamodb/` - DynamoDB module
- `functions/` - Lambda function source code (Node.js 22 ES Modules)
  - `items-api/` - handler, package.json and README
- Root Terraform files: provider, variables, outputs and top-level module wiring

## Key Implementations (mapped to assignment)

- S3 bucket with versioning for Lambda packages (`s3.tf`)
- DynamoDB table with server-side encryption (`modules/dynamodb`)
- Least-privilege IAM policies for Lambda (`iam.tf`)
- CloudWatch Log Group for Lambda (`cloudwatch.tf`)
- Lambda function implemented using Node.js 22 ES Modules (`functions/items-api/index.js`)
- API Gateway REST API with proxy integration and CORS configured (`modules/api-gateway`)
- Terraform variables include validation rules where appropriate
- Outputs expose key identifiers (`outputs.tf`): API endpoint, Lambda ARN, DynamoDB ARN, S3 bucket
- GitHub Actions workflows to validate Terraform and build Lambda (in `.github/workflows/`)

## How to deploy (local/manual)

Prerequisites:
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Node.js 22 (for building functions)

Build the Lambda package:

```bash
cd functions/items-api
npm ci
npm run build
```

This creates `items-api.zip` (used by Terraform `archive` or S3 upload flow).

Deploy with Terraform:

```bash
terraform init
terraform plan
terraform apply
```

After apply, view outputs:

```bash
terraform output api_endpoint
terraform output lambda_function_arn
terraform output dynamodb_table_arn
terraform output s3_bucket_name
```

## CI / CD

Workflows are provided to run on PRs and pushes:
- `terraform.yml` - runs `terraform fmt -check`, `terraform init -backend=false`, `terraform validate`, and `tfsec` security scans
- `nodejs.yml` - sets up Node.js 22, installs dependencies, and builds the Lambda package
- `markdownlint.yml` - validates Markdown formatting

These workflows run without AWS credentials.

## Lambda Implementation Notes

See `functions/items-api/README.md` for function-specific details, request/response samples, and how logging and validation are implemented.

## Assignment Checklist

- [x] Task 1: Terraform structure, S3, DynamoDB, IAM, CloudWatch
- [x] Task 2: Lambda (ES Modules) CRUD handlers (mocked responses), API Gateway, CORS, IAM
- [x] Task 3: GitHub Actions for validation and build (Terraform & Node.js)

## Next steps / optional

- Add Terraform tests (e.g., using Terratest)
- Add CloudWatch dashboards & alarms for observability
- Add EventBridge event-driven processors

If you'd like, I can now: add tests, implement CloudWatch dashboards and alarms, or prepare PR-ready commits. Which should I do next?
