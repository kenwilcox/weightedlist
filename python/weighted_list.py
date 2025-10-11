#!/usr/bin/env python3
"""
Count line frequencies across all .txt files in a given directory and list filenames.

This script replicates the behavior of weightedList/Program.cs:
- Accepts a directory path as a required argument
- Enumerates all *.txt files in that directory (non-recursive)
- Reads all lines from those files (without trailing newlines)
- Counts occurrences of each distinct line across all files (including duplicates within the same file)
- For each line, prints: "{count} - {line} (name1, name2, ...)" where names are the distinct
  base filenames (without extension) sorted ascending
- Sorted by descending count (ties broken by line asc for determinism)

Usage:
  python3 weighted_list.py /path/to/directory

Exit codes:
  0  success
  1  invalid arguments or missing directory
  2  unexpected error while reading files
"""
from __future__ import annotations

import argparse
import os
import sys
from glob import glob
from collections import Counter, defaultdict
from typing import Dict, Set


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Count line frequencies across .txt files in a directory and list filenames")
    parser.add_argument("directory", help="Path to the directory containing .txt files")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    dir_path = os.path.abspath(os.path.expanduser(args.directory))

    if not os.path.isdir(dir_path):
        print(f"Error: Not a directory: {dir_path}", file=sys.stderr)
        return 1

    # Non-recursive, match only files ending with .txt (case-sensitive like C# default on most FS)
    pattern = os.path.join(dir_path, "*.txt")
    files = [p for p in glob(pattern) if os.path.isfile(p)]

    line_counter: Counter[str] = Counter()
    line_to_names: Dict[str, Set[str]] = defaultdict(set)

    try:
        for file_path in files:
            base_name = os.path.splitext(os.path.basename(file_path))[0]
            # Read lines similar to C# File.ReadAllLines: no trailing newlines included.
            # Use UTF-8; tolerate encoding issues by replacing unknown chars.
            with open(file_path, "r", encoding="utf-8", errors="replace") as f:
                for line in f.read().splitlines():
                    line_counter[line] += 1
                    line_to_names[line].add(base_name)
    except Exception as ex:
        print(f"Error while processing files: {ex}", file=sys.stderr)
        return 2

    # Sort by count desc, then by line asc for deterministic output on ties.
    for line, count in sorted(line_counter.items(), key=lambda kv: (-kv[1], kv[0])):
        names_sorted = sorted(line_to_names.get(line, ()))
        # Match C# output: "{Count} - {Key} (name1, name2, ...)"
        names_part = f" ({', '.join(names_sorted)})" if names_sorted else " ()"
        print(f"{count} - {line}{names_part}")

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
