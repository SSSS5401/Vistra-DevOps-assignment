import assert from "assert";
import { handler } from "../index.js";

process.env.LOCAL_TEST = '1';

async function run() {
  const mockEvent = { detail: { id: '123', type: 'test' } };
  const res = await handler(mockEvent);
  // Handler returns 200 when succeeds
  assert.deepStrictEqual(res.statusCode, 200);
  console.log('Event processor test passed');
}

run().catch(err => {
  console.error('Test failed', err);
  process.exit(1);
});
