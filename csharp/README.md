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