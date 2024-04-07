# PYTHON 3.9 is used here

> 3.11 doesnt work (yet), no idea why

If you do not have old version of Python installed, you can install it using:

### [pyenv](https://github.com/pyenv/pyenv)

```bash
$ pyenv install 3.9.19
$ pyenv local 3.9.19
```

### Then venv is created, activated and requirements installed

```bash
$ python -m venv backup
$ source backup/bin/activate
$ pip install -r requirements.txt
```
