
JODIN_DIR := "$(shell odin root)shared\jodin"

main:
	poetry install --compile
	poetry run jupyter kernelspec install ./src/jodin --name=jodin

activate:
	@echo source "$(shell poetry env activate)"

_resolve:
	poetry debug resolve

_prepare:
	poetry lock
	poetry check
	poetry sync
	poetry export --without-hashes --format requirements.txt --output requirements.txt

install_via_poetry:
	poetry install --compile
	poetry run jupyter kernelspec install ./src/jodin --name=jodin

install_via_pip:
	python -m pip install -r requirements.txt

test:
	pytest -W ignore::DeprecationWarning