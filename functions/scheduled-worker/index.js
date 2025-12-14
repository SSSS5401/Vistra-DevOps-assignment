import { EventBridgeClient, PutEventsCommand } from "@aws-sdk/client-eventbridge";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";

const eb = new EventBridgeClient({});
const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async () => {
  console.log(JSON.stringify({ level: 'INFO', message: 'Scheduled worker running' }));

  const item = { id: `bg-${Date.now()}`, processedAt: new Date().toISOString() };

  // Write to DynamoDB (skip on local test)
  if (process.env.LOCAL_TEST === '1') {
    console.log(JSON.stringify({ level: 'INFO', message: 'Local test - skipping DynamoDB write and PutEvents' }));
  } else {
    await ddb.send(new PutCommand({
      TableName: process.env.DYNAMODB_TABLE || 'ApplicationData',
      Item: item
    }));

    // Publish an event to EventBridge
    await eb.send(new PutEventsCommand({
      Entries: [
        {
          Source: 'my.app',
          DetailType: 'app.event',
          Detail: JSON.stringify({ id: item.id, type: 'scheduled_processed', timestamp: Date.now() })
        }
      ]
    }));
  }

  return { statusCode: 200 };
};
