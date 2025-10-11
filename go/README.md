# Usage

Do something like the following to run the examples on your system

Assumes you already have [go](https://go.dev) installed on your system.

```zsh
$ go run main.go ../example/dinner
```

or

```zsh
$ go run main.go ../example/trips
```

You can also build the project

```zsh
$ go build
$ ./weightedlist ../example/dinner
$ ./weightedlist ../example/trips
```

You can also change the binary name for less typing

```zsh
$ go build -o wl
$ ./wl ../example/dinner
$ ./wl ../example/trips
```
