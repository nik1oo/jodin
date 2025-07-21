

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
	@echo [Make] Compiling interpreter...
	make -C ./src/interpreter/
	@echo [Make] Compiling kernel...
	poetry --directory=./src/ipy_kernel install --compile
	@echo [Make] Installing kernel...
	poetry --directory=./src/ipy_kernel run jupyter kernelspec install ./src/jodin --name=jodin --user
	@echo [Make] Running notebook...
	# jupyter server
	# poetry -C=./src/ipy_kernel run jupyter notebook ../../../notebooks/numerical_optimization.ipynb
	poetry -C=./src/ipy_kernel run jupyter notebook ../../../notebooks/numerical_optimization.ipynb


test_notebooks:
	odin test src/interpreter -define:ODIN_TEST_THREADS=1


test_interpreter:
	clear
	poetry --directory=./src/ipy_kernel run pip install .
	poetry --directory=./src/ipy_kernel run pip install pytest
	make -C ./src/interpreter/ test -B
	make -C ./src/ipy_kernel/ test -B

