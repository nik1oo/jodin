

ifeq ($(OS),Windows_NT)
    PYTHON := python
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        PYTHON := python3
    else
        PYTHON := python3
    endif
endif


main:
	clear
	make -C ./src/interpreter/
	$(PYTHON) -m pip install ./src/ipy_kernel
	jupyter kernelspec install ./src/ipy_kernel/src/jodin --name=jodin
	clear
	// jupyter server
	jupyter notebook examples/demo.ipynb


test_notebooks:
	odin test src/interpreter -define:ODIN_TEST_THREADS=1


test_interpreter:
	clear
	poetry --directory=./src/ipy_kernel run pip install .
	poetry --directory=./src/ipy_kernel run pip install pytest
	make -C ./src/interpreter/ test -B
	make -C ./src/ipy_kernel/ test -B

