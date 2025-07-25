

main:
	odin build src/build
	./build


test_notebooks:
	odin test src/interpreter -define:ODIN_TEST_THREADS=1


test_interpreter:
	clear
	poetry --directory=./src/python_kernel run pip install .
	poetry --directory=./src/python_kernel run pip install pytest
	make -C ./src/interpreter/ test -B
	make -C ./src/python_kernel/ test -B

