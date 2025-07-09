.PHONY: clean dev-deps setup-dev dist upload-test

clean:
	rm -Rf dist/ dist-extract/ requirements.txt

dev-deps:
	# pip install --upgrade build pip pip-tools setuptools twine wheel
	ln -s -f $(PWD)/.pypirc $(HOME)/

requirements.txt: pyproject.toml
	pip-compile --strip-extras pyproject.toml > requirements.txt

setup-dev: dev-deps requirements.txt
	pip install -r requirements.txt
	pip install --editable .

dist: pyproject.toml
	rm -Rf dist/
	python3 -m build
	unzip dist/*.whl -d dist-extract

test-upload:
	twine upload -r testpypi dist/*

upload: dist
	twine upload dist/*
