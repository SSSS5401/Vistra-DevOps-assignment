# Event-Driven Architecture

This document describes the EventBridge-based event-driven design, error handling, DLQ, and an architecture diagram.

## Components

- **ScheduledWorker Lambda**: runs on a schedule (default `rate(5 minutes)`), performs background processing and publishes custom events to EventBridge and writes a small record to DynamoDB.
- **EventBridge Rule (app-events)**: matches custom events with `source = "my.app"` and `detail-type = "app.event"` and forwards them to the EventProcessor Lambda.
- **EventProcessor Lambda**: processes incoming events and persists them to DynamoDB.
- **SQS DLQ**: a dead-letter queue receives failed events from EventBridge targets when invocation fails.

## Error Handling

- Errors in `EventProcessor` are thrown and EventBridge will retry according to its retry policy; after retries fail, the event is sent to the configured DLQ (`${var.app_name}-events-dlq`).
- A CloudWatch alarm monitors the DLQ for visible messages (`ApproximateNumberOfMessagesVisible >= 1`).

## Example Event

```
{
  "Source": "my.app",
  "DetailType": "app.event",
  "Detail": "{ \"id\": \"bg-123\", \"type\": \"scheduled_processed\" }"
}
```

## Architecture Diagram (Mermaid)

```mermaid
flowchart LR
  subgraph AWS
    SW[ScheduledWorker Lambda]
    EB[EventBridge Rule \n(app-events)]
    EP[EventProcessor Lambda]
    DB[DynamoDB Table]
    DLQ[SQS DLQ]
  end

  SW -->|PutEvents| EB
  SW -->|PutItem| DB
  EB -->|invoke| EP
  EP -->|PutItem| DB
  EB -->|failed events| DLQ
```
