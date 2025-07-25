<p align="center">
	<picture>
		<source media="(prefers-color-scheme: light)" srcset="/docs/logo.png">
		<img alt="jodin logo" src="/docs/logo-night.png" width="128px" height="128px">
	</picture>
	<h1 align="center"><b>JODIN</b></h1>
</p>

An environment for interactive and live programming in Odin. A REPL interpreter and a Jupyter kernel.
- REPL interpreter for Odin
- Jupyter kernel for Odin

> [!WARNING]
> Only works on Windows. There are some bugs. It's a prototype.

<!---
<h2 align="center">Showcase</h2>

<img alt="showcase gif" src="/docs/showcase.gif" width="100%">
--->

<!--
<h2 align="center">Features</h2>

- Cells share variables.
- Cells have their own context.
-->

- [Website](https://nik1oo.github.io/jodin/)
- [Installation](https://nik1oo.github.io/jodin/installation/)
- [API Reference](https://nik1oo.github.io/jodin/api_reference/)

<!--

<h2 align="center">Installation</h2>

Requirements:
- Make installed.
- Odin version `>=dev-2025-02, <=dev-2025-06` installed.
- Python version `>=3.12` installed.
- PIP or Poetry installed.

**1.** Clone the repo:

```
git clone https://github.com/nik1oo/jodin.git
```

**2.** Compile the JOdin interpreter and install the `shared:jodin` package:

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

-->