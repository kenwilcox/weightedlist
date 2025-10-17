# Usage

Do something like the following to run the examples on your system

Assumes you already have [zig](https://ziglang.org) installed on your system. No dependencies.

```zsh
# Build
$ zig build

# Run (pass the directory containing your .txt files)
$ zig build run -- ../example/dinner
$ zig build run -- ../example/trips

# Or run the installed binary
$ zig build install
$ ./zig-out/bin/weightedlist ../example/dinner
```

- It scans only .txt files in the provided directory.
- The <fileX> names are the base filenames without the .txt extension.
- Empty lines are ignored; lines are trimmed of spaces and carriage returns.