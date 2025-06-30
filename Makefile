

main:
	clear
	make -C ./src/interpreter/
	"C:\Program Files\Python313\python.exe" -m pip install ./src/ipy_kernel
	jupyter kernelspec install ./src/ipy_kernel/src/jodin --name=jodin
	clear
	jupyter notebook examples/glfw.ipynb


test:
	clear
	"C:\Program Files\Python313\python.exe" -m pip install ./src/ipy_kernel
	make -C ./src/interpreter/ test
	make -C ./src/ipy_kernel/ test

