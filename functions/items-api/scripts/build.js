import fs from 'fs';
import path from 'path';
import AdmZip from 'adm-zip';

const srcDir = path.resolve(process.cwd());
const outPath = path.resolve(path.join(srcDir, '..', 'items-api.zip'));

function build() {
  const zip = new AdmZip();
  const addDirRecursive = (dir) => {
    const items = fs.readdirSync(dir, { withFileTypes: true });
    for (const it of items) {
      const p = path.join(dir, it.name);
      const rel = path.relative(srcDir, p).replace(/\\/g, '/');
      if (rel === 'items-api.zip' || rel.startsWith('node_modules')) continue;
      if (it.isDirectory()) addDirRecursive(p);
      else zip.addLocalFile(p, path.dirname(rel) === '.' ? '' : path.dirname(rel));
    }
  };
  addDirRecursive(srcDir);
  zip.writeZip(outPath);
}

try {
  build();
  console.log('Built', outPath);
} catch (err) {
  console.error(err);
  process.exit(1);
}


