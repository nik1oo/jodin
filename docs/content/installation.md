+++
date = '2025-07-02T03:25:54+03:00'
draft = false
title = 'Setup'
+++

## Requirements

- GNU Make
- Odin version nightly+2025-07-24
- Python Poetry

---
## Installation

1. Download and install JODIN:

```
git clone https://github.com/nik1oo/jodin.git
cd jodin
odin run src/build
```

2. Add to PATH.

---
## Starting the JODIN interactive shell

To start the JODIN interpreter in REPL mode execute:

```
jodin shell
```

To exit the REPL execute `exit()`.

---
## Staring the Jupyter Notebook

First activate the virtual environment by executing the command printed by the following command:

```
jodin venv
```

Then start the jupyter notebook using the following command:

```
jodin jupyter-notebook
```

Then, if starting for the first time, select the JODIN kernel from _Kernel_ > _Change Kernel_.

---
## Starting the Jupyter Server

First activate the virtual environment by executing the command printed by the following command:

```
jodin venv
```

Then start the jupyter server using the following command:

```
jodin jupyter-server
```

Then copy the URL into your preferred Jupyter front-end.
