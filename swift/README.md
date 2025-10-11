# Usage

Do something like the following to run the examples on your system

Assumes you already have [swift](https://www.swift.org/) installed on your system.

```zsh
$ swift run weighted-list ../example/dinner
```

or

```zsh
$ swift run weighted-list ../example/trips
```

You can also build the project

```zsh
$ swift build -c release
$ $(swift build -c release --show-bin-path)/weighted-list ../example/dinner
$ $(swift build -c release --show-bin-path)/weighted-list ../example/trips

$ `swift build -c release --show-bin-path`/weighted-list ../example/dinner 
$ `swift build -c release --show-bin-path`/weighted-list ../example/trips 
```

You can also try an optimized build [https://www.swift.org/documentation/server/guides/building.html](https://www.swift.org/documentation/server/guides/building.html)

```shell
$ swift build -c release -Xswiftc -cross-module-optimization
```

If you are on a Mac you can open the swift folder in Xcode
