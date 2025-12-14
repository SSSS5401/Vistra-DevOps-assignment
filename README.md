# Vistra-DevOps-assignment

Serverless Infrastructure Design with Terraform and AWS

## Project Overview

This repository implements a serverless REST API for simple items management.
The solution uses AWS Lambda (Node.js 22), API Gateway REST API (proxy
integration), DynamoDB, S3, IAM, and CloudWatch. Terraform is used for all
infrastructure as code and is modularized for maintainability.

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
- Lambda function implemented using Node.js 22 ES Modules.
  See `functions/items-api/index.js` for the handler implementation.
- API Gateway REST API with proxy integration and CORS configured in
  `modules/api-gateway`
- Terraform variables include validation rules where appropriate.
- Outputs expose key identifiers in `outputs.tf`. Examples include the API
  endpoint, Lambda ARN, DynamoDB ARN, and S3 bucket.
- GitHub Actions workflows are provided to validate Terraform and build
  Lambda artifacts. See `.github/workflows/` for workflow definitions.

## How to deploy (local/manual)

Prerequisites:

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Node.js 22 (for building functions)

Build the Lambda package and run the lightweight handler tests:

```bash
cd functions/items-api
npm ci
npm test    # runs simple local handler tests
npm run build
```

This creates `items-api.zip`, which can be uploaded via Terraform `archive` or
an `aws_s3_object` resource.

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

- `terraform.yml` - runs `terraform fmt -check`.
  It runs `terraform init -backend=false` and `terraform validate`.
  The workflow also performs `tfsec` security scans.
- `nodejs.yml` - sets up Node.js 22, installs dependencies, and builds the
  Lambda package.
- `markdownlint.yml` - validates Markdown formatting.

## Local Validation

You can run a single, offline validation that checks formatting, Terraform
configuration, Node build/packaging and simple repository conventions without
needing AWS credentials.

- Install dev dependencies:

```bash
npm install
```

- Run the combined validation:

```bash
npm run validate
```

What `npm run validate` does:

- `terraform fmt -check -recursive` and `terraform init -backend=false && terraform validate` (no AWS access required)
- Builds the function package (`functions/items-api`) and verifies the produced ZIP contains `index.js`
- Runs a lightweight conventions checker (no tabs, no trailing whitespace, Markdown files start with `#`)

These checks are designed to be run locally and in CI (workflows can call `npm run validate`).

These workflows run without AWS credentials.

## Lambda Implementation Notes

See `functions/items-api/README.md` for function-specific details, simple
request/response examples, and an overview of logging and validation.

## Assignment Checklist

- [x] Task 1: Terraform structure, S3, DynamoDB, IAM, CloudWatch
- [x] Task 2: Lambda — CRUD handlers (mocked responses), API Gateway, CORS,
      and IAM
- [x] Task 3: GitHub Actions for validation and build (Terraform & Node.js)

## Next steps / optional

- Add Terraform tests (e.g., using Terratest)
- Add CloudWatch dashboards & alarms for observability (see `MONITORING.md`)
- Add EventBridge event-driven processors (see `EVENTBRIDGE.md`)
- Architecture diagram and design notes: `ARCHITECTURE.md`

If you'd like, I can now add tests, implement CloudWatch dashboards and alarms,
or prepare PR-ready commits. Which should I do next?
