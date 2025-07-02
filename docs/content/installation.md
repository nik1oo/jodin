+++
date = '2025-07-02T03:25:54+03:00'
draft = false
title = 'Installation'
+++

Requirements:
- Make installed.
- Odin version >=dev-2025-02, <=dev-2025-06 installed.
- Python version >=3.12 installed.
- PIP or Poetry installed.

**1.** Clone the repo:

```
git clone https://github.com/nik1oo/jodin.git
```

**2.** Compile the JOdin interpreter and install the shared:jodin package:

```
make -C ./src/interpreter/
```

**3.** Install JOdin kernel via PIP or Poetry.

Using PIP:

```
python -m pip install ./src/ipy_kernel
jupyter kernelspec install ./src/ipy_kernel/src/jodin --name=jodin
```

Using Poetry:

```
cd ./src/ipy_kernel/
poetry install --compile
poetry run jupyter kernelspec install ./src/jodin --name=jodin
cd ../..
```

<h2 align="center">Running</h2>

To start with the console front-end:
```
jupyter console --kernel jodin
```

To start with the console front-end using Poetry python:
```
poetry -C=./src/ipy_kernel run jupyter console --kernel jodin
```

To start with the notebook front-end:

```
jupyter notebook
```

To start with the notebook front-end using Poetry python:
```
poetry -C=./src/ipy_kernel run jupyter notebook
```

Once in notebook, to select the JOdin kernel go to `Kernel > Change Kernel...` and select `JODIN`.

To open the demo notebook:

```
jupyter notebook examples/demo.ipynb
```


