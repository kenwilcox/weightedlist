# Usage

Do something like the following to run the examples on your system

Assumes you already have [python3](https://www.python.org) installed on your system. No venv or similar needed. No dependencies.

```zsh
$ python3 weighted_list.py ../example/dinner
```

or

```zsh
$ python3 weighted_list.py ../example/trips
```

If you are on Windows the py launcher might be what you needed

```zsh
$ py -0 # to figure out what python versions you have installed
 -V:3.13 *        Python 3.13 (64-bit)
 -V:3.9           Python 3.9 (64-bit)

$ py -3.13 .\weighted_list.py ../example/dinner
$ py -3.13 .\weighted_list.py ../example/trips
```

Although not needed, you can also use [uv](https://docs.astral.sh/uv/)

```shell
$ uv run .\weighted_list.py ../example/dinner
$ uv run .\weighted_list.py ../example/trips
```
