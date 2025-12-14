#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { sync as globSync } from 'glob';

function hasTrailingWhitespace(s) { return /\s+$/.test(s); }

let errors = 0;

// Check terraform & js files for trailing whitespace and tabs
const patterns = ['**/*.tf', '**/*.js', '**/*.md'];
for (const pattern of patterns) {
  const files = globSync(pattern, { ignore: ['node_modules/**', '.git/**', 'functions/**/node_modules/**'] });
  for (const f of files) {
    const text = fs.readFileSync(f, 'utf8');
    const lines = text.split(/\r?\n/);
    lines.forEach((l, i) => {
      if (/\t/.test(l)) {
        console.error(`${f}:${i+1} contains a tab character`);
        errors++;
      }
      if (hasTrailingWhitespace(l)) {
        console.error(`${f}:${i+1} has trailing whitespace`);
        errors++;
      }
    });
    // MD files should start with a title
    if (f.endsWith('.md')) {
      const firstLine = lines[0] || '';
      if (!firstLine.trim().startsWith('#')) {
        console.error(`${f} should start with a top-level heading (# ...)`);
        errors++;
      }
    }
  }
}

if (errors > 0) {
  console.error(`Conventions check failed (${errors} issues)`);
  process.exit(1);
}

console.log('Conventions check passed.');
