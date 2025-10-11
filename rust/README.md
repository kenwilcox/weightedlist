# Usage

Do something like the following to run the examples on your system

Assumes you already have [rust](https://rust-lang.org) installed on your system. I used rustup which includes cargo. No dependencies.

```zsh
$ cargo run ../example/dinner
```

or

```zsh
$ cargo run ../example/trips
```

You can also build the project

```zsh
$ cargo build --release
$ ./target/release/weighted-list ../example/dinner
$ ./target/release/weighted-list ../example/trips
```

## Notes
AI had args on line 25 of src/main.rs mutable. This was manually removed to remove compiler warnings
