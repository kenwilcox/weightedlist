#!/usr/bin/env -S deno run --allow-read

async function main() {
  const args = Deno.args;
  if (args.length < 1) {
    console.error('Usage: deno run --allow-read index.js <directory-with-txt-files>');
    Deno.exit(1);
  }

  const dir = args[0];
  let stat;
  try {
    stat = await Deno.stat(dir);
  } catch (_e) {
    console.error(`Not a directory: ${dir}`);
    Deno.exit(1);
  }
  if (!stat.isDirectory) {
    console.error(`Not a directory: ${dir}`);
    Deno.exit(1);
  }

  // group: Map<string, string[]>
  const group = new Map();

  for await (const entry of Deno.readDir(dir)) {
    if (entry.isFile && entry.name.toLowerCase().endsWith('.txt')) {
      const fullPath = joinSimple(dir, entry.name);
      const name = stripExtension(entry.name);
      const content = await Deno.readTextFile(fullPath);
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
    const entry = lineMap.get(p.Line);
    entry.count += 1;
    entry.names.add(p.Name);
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

function stripExtension(filename) {
  const idx = filename.lastIndexOf('.');
  return idx > 0 ? filename.slice(0, idx) : filename;
}

function joinSimple(dir, name) {
  if (dir.endsWith('/') || dir.endsWith('\\')) return `${dir}${name}`;
  return `${dir}/${name}`;
}

await main();
