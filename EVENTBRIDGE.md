# Event-Driven Architecture

This document describes the EventBridge-based event-driven design and error
handling. It also documents the DLQ and a small architecture diagram.

## Components

- **ScheduledWorker Lambda**: runs on a schedule (default `rate(5 minutes)`).
  It performs background processing and publishes custom events to EventBridge.
  It also writes a small record to DynamoDB.
- **EventBridge Rule (app-events)**: matches custom events with
  `source = "my.app"` and `detail-type = "app.event"`. Events are forwarded
  to the EventProcessor Lambda.
- **EventProcessor Lambda**: processes incoming events and persists them to
  DynamoDB.
- **SQS DLQ**: a dead-letter queue receives failed events from EventBridge
  targets when invocation fails.

## Error Handling

- Errors in `EventProcessor` are thrown and EventBridge will retry according to
  its retry policy. After retries fail, EventBridge sends the event to the
  configured DLQ (`${var.app_name}-events-dlq`).
- A CloudWatch alarm monitors the DLQ for visible messages. The alarm watches
  the metric `ApproximateNumberOfMessagesVisible` and triggers when it is >= 1.

## Example Event

```json
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
    EB[EventBridge Rule<br>(app-events)]
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
