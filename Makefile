

main:
	clear
	odin run src/build


test_notebooks:
	clear
	odin run src/build
	odin test src/interpreter -define:ODIN_TEST_THREADS=1
	# odin test src/interpreter -define:ODIN_TEST_THREADS=1 &> output.txt


test_interpreter:
	clear
	odin run src/build
	poetry --directory=./src/python_kernel run pip install .
	poetry --directory=./src/python_kernel run pip install pytest
	make -C ./src/interpreter/ test -B
	make -C ./src/python_kernel/ test -B

