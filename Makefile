.PHONY: run clean dev-deps setup-dev dist test-pypi pypi docker-image docker-hub docker-hub-latest docker

hub_org = nipil
package := $(shell python3 -c 'import tomllib; fp=open("pyproject.toml","rb"); print(tomllib.load(fp)["project"]["name"]); fp.close()')
version := $(shell python3 -c 'import tomllib; fp=open("pyproject.toml","rb"); print(tomllib.load(fp)["project"]["version"]); fp.close()')

run:
	python3 -m gcn_manager --trace --log-level info --mqtt-reconnect

usage:
	python3 -m gcn_manager --help

print-env:
	python3 -m gcn_manager --print-env-then-exit

clean:
	rm -Rf dist/ dist-extract/ requirements.txt

dev-deps:
	pip install --upgrade build pip pip-tools setuptools twine wheel
	ln -s -f $(PWD)/.pypirc $(HOME)/

requirements.txt: pyproject.toml
	pip-compile --strip-extras pyproject.toml > requirements.txt

setup-dev: dev-deps requirements.txt
	pip install -r requirements.txt
	pip install --editable .

dist: pyproject.toml
	rm -Rf dist/
	python3 -m build
	unzip -o -d dist-extract dist/*.whl

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

docker: docker-image docker-hub docker-hub-latest
