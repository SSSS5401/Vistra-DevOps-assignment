# Monitoring & Observability

This document explains the monitoring strategy and metric selection. It also
documents alarm thresholds and example CloudWatch Logs Insights queries used
for troubleshooting.

## Strategy

- Monitor Lambda functions for errors, high latency, and throttling.
- Monitor API Gateway for 5XX errors and elevated latency.
- Monitor DynamoDB for throttled requests and capacity consumption.
- Use structured JSON logs. Lambda emits JSON logs containing a `level` field;
  create metric filters for `ERROR` logs.
- Provide a consolidated CloudWatch Dashboard for quick operational view.

## Alarm Thresholds and Rationale

- Lambda Errors: threshold = 5 (sum over 1 minute) — noisy or persistent
  errors should be investigated quickly.
- Lambda Duration: threshold = 3000 ms (average over 1 minute) — high latency
  indicates downstream issues or inefficient code.
- Lambda Throttles: threshold = 1 (sum over 1 minute) — any throttle requires
  immediate attention to concurrency or scaling.
- API Gateway 5XX: threshold = 5 (sum over 1 minute) — backend or integration
  failures need prompt remediation.
- API Gateway Latency: threshold = 1000 ms (avg over 1 minute) — user-facing
  latency SLAs typically require < 1s responses.
- DynamoDB Throttles: threshold = 1 (sum over 1 minute) — throttling indicates
  insufficient throughput or hot keys.

These thresholds are conservative defaults suitable for a small production
service. Adjust thresholds based on traffic patterns and your SLOs.

## Logs & Metric Filters

- A metric filter is created for structured logs where `level = "ERROR"` and
  emits `LambdaLogs/ErrorsFromLogs`.
- Use this metric to triangulate between function-reported Errors and
  log-derived Errors.

## Example CloudWatch Logs Insights Queries

- Find recent ERROR logs from Lambda (structured JSON):

```text
fields @timestamp, @message
| filter level = "ERROR"
| sort @timestamp desc
| limit 50
```

- Find slow Lambda executions (if you log duration in your JSON logs):

```text
fields @timestamp, @message
| parse @message /"duration":\s*(?<duration>\d+)/
| filter duration > 1000
| sort duration desc
| limit 50
```

- API Gateway: find 5XX responses from access logs (if enabled):

```text
fields @timestamp, status, path
| filter status >= 500
| stats count() by status
| limit 20
```

Adjust queries based on the actual log format you configure for access logs.

## Dashboard

- The Terraform `aws_cloudwatch_dashboard` resource creates a dashboard
  named `${var.app_name}-dashboard`. The dashboard shows key Lambda, API
  Gateway, and DynamoDB metrics.

## Next steps / Improvements

- Add Slack or SNS alarm actions for on-call notifications.
- Create CloudWatch Contributor Insights rules for top error types or hot keys.
- Add more detailed Insights queries tuned to actual log structure in
  production.
