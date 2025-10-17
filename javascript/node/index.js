#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');

function main() {
  const args = process.argv.slice(2);
  if (args.length < 1) {
    console.error('Usage: node ./index.js <directory-with-txt-files>');
    process.exit(1);
  }

  const dir = args[0];
  if (!fs.existsSync(dir)) {
    console.error(`Not a directory: ${dir}`);
    process.exit(1);
  }
  const stat = fs.statSync(dir);
  if (!stat.isDirectory()) {
    console.error(`Not a directory: ${dir}`);
    process.exit(1);
  }

  // group: Map<string, string[]>
  const group = new Map();

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.isFile() && entry.name.toLowerCase().endsWith('.txt')) {
      const fullPath = path.join(dir, entry.name);
      const name = path.basename(entry.name, path.extname(entry.name));
      const content = fs.readFileSync(fullPath, 'utf8');
      // Keep empty lines like File.ReadAllLines would
      const lines = content.split(/\r?\n/);
      group.set(name, lines);
    }
  }

  // Flatten into { Name, Line }
  const pairs = [];
  for (const [name, lines] of group.entries()) {
    for (const line of lines) {
      pairs.push({ Name: name, Line: line });
    }
  }

  // Group by Line
  const lineMap = new Map(); // key: line, value: { count: number, names: Set<string> }
  for (const p of pairs) {
    if (!lineMap.has(p.Line)) {
      lineMap.set(p.Line, { count: 0, names: new Set() });
    }
    const rec = lineMap.get(p.Line);
    rec.count += 1;
    rec.names.add(p.Name);
  }

  // Build results
  const results = [];
  for (const [key, val] of lineMap.entries()) {
    const namesSorted = Array.from(val.names).sort((a, b) => a.localeCompare(b));
    results.push({ Key: key, Count: val.count, Names: namesSorted });
  }

  // Order by Count desc
  results.sort((a, b) => b.Count - a.Count);

  // Print in format: "{Count} - {Key} ({Name1, Name2, ...})"
  for (const x of results) {
    console.log(`${x.Count} - ${x.Key} (${x.Names.join(', ')})`);
  }
}

main();
