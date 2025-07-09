.PHONY: clean dev-deps setup-dev dist test-pypi pypi docker-image docker-hub docker-hub-latest

hub_org = nipil
package := $(shell python3 -c 'import tomllib; fp=open("pyproject.toml","rb"); print(tomllib.load(fp)["project"]["name"]); fp.close()')
version := $(shell python3 -c 'import tomllib; fp=open("pyproject.toml","rb"); print(tomllib.load(fp)["project"]["version"]); fp.close()')

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

test-pypi:
	twine upload -r testpypi dist/*

pypi: dist
	twine upload dist/*

docker-image:
	docker build -t $(hub_org)/$(package):$(version) --build-arg GCN_MANAGER_VERSION=$(version) .

docker-hub:
	docker push $(hub_org)/$(package):$(version)

docker-hub-latest:
	docker tag $(hub_org)/$(package):$(version) $(hub_org)/$(package):latest
	docker push $(hub_org)/$(package):latest
