+++
date = '2025-07-02T03:25:54+03:00'
draft = false
title = 'Installation'
+++

== Requirements

- Make installed.
- Odin version >=dev-2025-02, <=dev-2025-06 installed.
- Python version >=3.12 installed.
- Jupyter installed.
- Poetry installed.

== Installing

**1.** Compile the JODIN interpreter and install the JODIN package.

```
make -C ./src/interpreter/
```

**2.** Activate the virtual environment by executing the command printed by the following command.

```
poetry env activate
```

**3.** Install the dependencies.

```
poetry --directory=./src/ipy_kernel install --compile
```

**4.** Tnstall the JODIN kernel.

```
poetry --directory=./src/ipy_kernel run jupyter kernelspec install ./src/jodin --name=jodin --user
```

== Running

To start the console front-end execute the following command:

```
poetry -C=./src/ipy_kernel run jupyter console --kernel jodin
```

To start the notebook front-end execute the following command, then select the JODIN kernel from _Kernel_ > _Change Kernel_.

```
poetry -C=./src/ipy_kernel run jupyter notebook ../../examples/demo.ipynb
```
