import {
  DynamoDBClient
} from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "ApplicationData";

export const handler = async (event, context) => {
  let response;
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };

  const { httpMethod, path, body, pathParameters } = event;

  // Structured logging
  console.log(JSON.stringify({ level: 'INFO', message: 'Request received', method: httpMethod, path }));

  // Input validation
  if (httpMethod !== 'GET' && httpMethod !== 'POST' && httpMethod !== 'PUT' && httpMethod !== 'DELETE') {
    throw new Error('Invalid method');
  }

  try {
    const parsedBody = JSON.parse(body || '{}');
    const id = pathParameters?.id;
    switch (httpMethod) {
      case "POST":
        if (path !== '/items') throw new Error('Invalid path for POST');
          // await dynamo.send(
          //   new PutCommand({
          //     TableName: tableName,
          //     Item: {
          //       ItemId: requestJSON.id,
          //       ...requestJSON,
          //     },
          //   }))
          response = { statusCode: 201, body: JSON.stringify({ id: 'mock-id', ...parsedBody }) };
          break;
      case 'GET':
        if (path === '/items') {
          // response = await dynamo.send(
          //   new ScanCommand({
          //     TableName: tableName
          //   })
          // );
          response = { statusCode: 200, body: JSON.stringify([{ id: 'mock1' }, { id: 'mock2' }]) };
        }else if (path.startsWith('/items/')) {
          if (!id) throw new Error('Missing id');
          // response = await dynamo.send(
          //   new GetCommand({
          //     TableName: tableName,
          //     Key: {
          //       ItemId: id,
          //     },
          //   })
          // );
          // Mock get
          response = { statusCode: 200, body: JSON.stringify({ id, name: 'mock-item' }) };
        } else {
          throw new Error('Invalid path for GET');
        }
        break;
      case 'PUT':
        if (!path.startsWith('/items/')) throw new Error('Invalid path for PUT');
        if (!id) throw new Error('Missing id');
        // await dynamo.send(
        //   new PutCommand({
        //     TableName: tableName,
        //     Item: {
        //       ItemId: requestJSON.id,
        //     },
        //   })
        // );
        // Mock update
        response = { statusCode: 200, body: JSON.stringify({ id, ...parsedBody }) };
        break;   
      case 'DELETE':
        if (!path.startsWith('/items/')) throw new Error('Invalid path for DELETE');
        if (!id) throw new Error('Missing id');
        // await dynamo.send(
        //   new DeleteCommand({
        //     TableName: tableName,
        //     Key: {
        //       ItemId: event.pathParameters.id,
        //     },
        //   })
        // );
        // Mock delete
        response = { statusCode: 204, body: '' };
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (error) {
    response = { statusCode: 400, body: JSON.stringify({ error: error.message }) };
  }

  return {
    ...response,
    headers,
  };
};