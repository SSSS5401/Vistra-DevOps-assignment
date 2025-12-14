#!/usr/bin/env node
import { execSync } from 'child_process';
import { existsSync } from 'fs';
import path from 'path';

try {
  console.log('Building functions/items-api...');
  execSync('npm --prefix functions/items-api run build', { stdio: 'inherit' });

  const zipPath = path.join('functions', 'items-api', '..', 'items-api.zip');
  if (!existsSync(zipPath)) {
    console.error('Package not created:', zipPath);
    process.exit(2);
  }

  console.log('Verifying package contents...');
  // quick check for index.js inside the zip
  const AdmZip = (await import('adm-zip')).default;
  const zip = new AdmZip(zipPath);
  const entries = zip.getEntries().map(e => e.entryName);
  if (!entries.includes('index.js')) {
    console.error('index.js not found in package');
    process.exit(3);
  }

  console.log('Node build and packaging validation succeeded.');
} catch (err) {
  console.error(err.message || err);
  process.exit(1);
}
