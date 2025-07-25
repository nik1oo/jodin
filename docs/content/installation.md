+++
date = '2025-07-02T03:25:54+03:00'
draft = false
title = 'Setup'
+++

## Requirements

- Make installed
- Odin version nightly+2025-07-24
- Python version >=3.12
- Jupyter
- Python Poetry

## Installing

To install JODIN execute:

```
git clone https://github.com/nik1oo/jodin.git
cd jodin
odin run src/build
```

To start the virtual environment execute:

```
jodin venv
```

## Running

To start JODIN with the Jupyter console front-end execute:

```
jodin jupyter-console
```

To start JODIN with the Jupyter notebook front-end execute:

```
jodin jupyter-notebook
```

If the JODIN kernel is not selected, you can select it from _Kernel_ > _Change Kernel_.
