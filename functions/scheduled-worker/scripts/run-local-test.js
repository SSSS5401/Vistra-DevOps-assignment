import assert from "assert";
import { handler } from "../index.js";

process.env.LOCAL_TEST = '1';

async function run() {
  const res = await handler();
  assert.strictEqual(res.statusCode, 200);
  console.log('Scheduled worker test passed');
}

run().catch(err => {
  console.error('Test failed', err);
  process.exit(1);
});
