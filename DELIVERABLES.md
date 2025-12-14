# Deliverables Mapping

This file maps assignment requirements to files and features implemented in this
repository.

- Task 1: Project Setup & Infrastructure Foundation
  - S3 bucket for Lambda packages with versioning: `s3.tf`
  - DynamoDB table with encryption: `modules/dynamodb/main.tf`
  - IAM roles & least-privilege policies: `iam.tf`
  - CloudWatch Log group: `cloudwatch.tf`
  - Variables and validation rules: `variables.tf` and module definitions in
    `modules/*/variables.tf`
  - Outputs exposing important identifiers: `outputs.tf`

- Task 2: Serverless API with Lambda & API Gateway
  - Lambda (Node.js 22, ES Modules): `functions/items-api/index.js`
  - API Gateway REST API with proxy integration and CORS.
    See `modules/api-gateway/*` for implementation details.
  - DynamoDB integration (client present, mocked responses).
    See `functions/items-api/index.js` for implementation details.
  - IAM permissions for DynamoDB: `iam.tf`
  - Documentation for function: `functions/items-api/README.md`

- Task 3: CI/CD Pipeline with GitHub Actions
  - Terraform validation workflow: `.github/workflows/terraform.yml`
  - Node.js build & tests workflow: `.github/workflows/nodejs.yml`
  - Markdown linting: `.github/workflows/markdownlint.yml`

- Optional / Next steps:
  - Add CloudWatch dashboards and alarms for production readiness
  - Add EventBridge event processors and DLQ (see `EVENTBRIDGE.md`)
