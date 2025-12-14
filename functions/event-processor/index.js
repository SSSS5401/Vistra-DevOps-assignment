import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event) => {
  console.log(JSON.stringify({ level: 'INFO', message: 'Event received', event }));

  try {
    const detail = event.detail || {};

    if (process.env.LOCAL_TEST === '1') {
      console.log(JSON.stringify({ level: 'INFO', message: 'Local test mode - skipping DynamoDB write', detail }));
    } else {
      // Example processing: write event to DynamoDB
      await ddb.send(new PutCommand({
        TableName: process.env.DYNAMODB_TABLE || 'ApplicationData',
        Item: {
          id: detail.id || `evt-${Date.now()}`,
          type: detail.type || 'unknown',
          payload: detail
        }
      }));
    }

    console.log(JSON.stringify({ level: 'INFO', message: 'Event processed successfully' }));
    return { statusCode: 200 };
  } catch (err) {
    console.error(JSON.stringify({ level: 'ERROR', message: err.message }));
    throw err; // Let EventBridge register the failure so DLQ can capture it
  }
};
