import assert from "assert";
import { handler } from "../index.js";

async function invoke(event) {
  const res = await handler(event, {});
  return res;
}

async function run() {
  // Test GET /items
  const listEvent = { httpMethod: 'GET', path: '/items' };
  const listRes = await invoke(listEvent);
  assert.strictEqual(listRes.statusCode, 200, 'GET /items should return 200');

  // Test POST /items
  const postEvent = { httpMethod: 'POST', path: '/items', body: JSON.stringify({ name: 'test' }) };
  const postRes = await invoke(postEvent);
  assert.strictEqual(postRes.statusCode, 201, 'POST /items should return 201');

  // Test GET /items/{id}
  const getEvent = { httpMethod: 'GET', path: '/items/123', pathParameters: { id: '123' } };
  const getRes = await invoke(getEvent);
  assert.strictEqual(getRes.statusCode, 200, 'GET /items/{id} should return 200');

  // Test PUT /items/{id}
  const putEvent = { httpMethod: 'PUT', path: '/items/123', pathParameters: { id: '123' }, body: JSON.stringify({ name: 'updated' }) };
  const putRes = await invoke(putEvent);
  assert.strictEqual(putRes.statusCode, 200, 'PUT /items/{id} should return 200');

  // Test DELETE /items/{id}
  const delEvent = { httpMethod: 'DELETE', path: '/items/123', pathParameters: { id: '123' } };
  const delRes = await invoke(delEvent);
  assert.strictEqual(delRes.statusCode, 204, 'DELETE /items/{id} should return 204');

  console.log('All local handler tests passed');
}

run().catch(err => {
  console.error('Tests failed:', err);
  process.exit(1);
});
