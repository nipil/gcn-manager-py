.PHONY: dev-deps setup-dev

dev-deps:
	pip install --upgrade build pip pip-tools setuptools twine wheel

requirements.txt: dev-deps pyproject.toml
	pip-compile --strip-extras pyproject.toml > requirements.txt

setup-dev: requirements.txt
	pip install -r requirements.txt
	pip install --editable .
