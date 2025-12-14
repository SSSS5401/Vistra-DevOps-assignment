# Items API Lambda

This Lambda implements a minimal CRUD API for `items` using Node.js 22 (ES Modules).

Endpoints (API Gateway proxy integration):
- POST /items - Create item (returns 201 with created item)
- GET /items - List items (returns 200 with array)
- GET /items/{id} - Get single item (returns 200)
- PUT /items/{id} - Update item (returns 200)
- DELETE /items/{id} - Delete item (returns 204)

Notes:
- The function uses structured JSON logging to CloudWatch (log lines are JSON objects with `level` and `message`).
- Input validation and error handling are implemented; the current function returns mocked responses and does not persist to DynamoDB (per assignment guidance).
- Uses AWS SDK v3 modular imports (`@aws-sdk/client-dynamodb` and `@aws-sdk/lib-dynamodb`).

Build & package:

```bash
cd functions/items-api
npm ci
npm run build
```

This creates `items-api.zip` in the parent folder which the Terraform `aws_s3_object` can upload.

Testing locally:
- You can call the handler with a simulated event (e.g., using `sam local invoke` or a simple node script that imports the handler and calls it with an event object).

Logging:
- Example log line: `{"level":"INFO","message":"Request received","method":"GET","path":"/items"}`

If you want, I can add unit tests and simple request/response examples next.
