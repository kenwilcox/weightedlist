# Usage

Do something like the following to run the examples on your system

Assumes you already have [dotnet](https://dot.net/) installed on your system. No dependencies.

```zsh
$ dotnet run --project ./WeightedList/WeightedList.csproj ../example/dinner
```

or

```zsh
$ dotnet run --project ./WeightedList/WeightedList.csproj ../example/trips
```

You can also build the project. Since the solution is a single project you can safely ignore the warnings about output being in the same directory

```zsh
$ dotnet build --configuration Release --output bin
$ ./bin/WeightedList ../example/dinner
$ ./bin/WeightedList ../example/trips
```

## Zig version

A Zig implementation compatible with Zig 0.15.2 is included. Build and run it with:

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

The Zig tool prints lines in the format:

```
<count> - <line> (<file1>, <file2>, ...)
```

- It scans only .txt files in the provided directory.
- The <fileX> names are the base filenames without the .txt extension.
- Empty lines are ignored; lines are trimmed of spaces and carriage returns.