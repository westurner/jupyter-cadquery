.PHONY: clean wheel install tests check_version dist check_dist upload_test upload dev_tools bump bump_ext release

PYCACHE := $(shell find . -name '__pycache__')
EGGS := $(wildcard *.egg-info)
CURRENT_VERSION := $(shell awk '/current_version/ {print $$3}' setup.cfg)

clean:
	@echo "=> Cleaning"
	@rm -fr build dist $(EGGS) $(PYCACHE)

prepare: clean
	git add .
	git status
	git commit -m "cleanup before release"

# Version commands

bump:
ifdef part
ifdef version
	bumpversion --new-version $(version) $(part) && grep current setup.cfg
else
	bumpversion $(part) && grep current setup.cfg
endif
else
	@echo "Provide part=major|minor|patch|release|build and optionally version=x.y.z..."
	exit 1
endif

bump_ext:
ifdef part
	$(eval cur_version=$(shell cd js/ && npm version $(part) --preid=rc))
else
ifdef version
	$(eval cur_version := $(shell cd js/ && npm version $(version)))
else
	@echo "Provide part=major|minor|patch|premajor|preminor|prepatch|prerelease or version=x.y.z..."
	exit 1
endif
endif
	@echo "=> New version: $(cur_version:v%=%)"
	@sed -i.bak 's|jupyter_cadquery@.*|jupyter_cadquery@$(cur_version)|' labextensions.txt
	cat labextensions.txt
	git add labextensions.txt js/package.json js/package-lock.json
	git commit -m "extension release $(cur_version)"

# Dist commands

dist:
	@python setup.py sdist bdist_wheel
	@echo "jupyter-labextension install --no-build $(shell cat labextensions.txt | xargs)" > postBuild
	@echo "jupyter lab build" >> postBuild

release:
	git add .
	git status
	git commit -m "Latest release: $(CURRENT_VERSION)"
	git tag -a v$(CURRENT_VERSION) -m "Latest release: $(CURRENT_VERSION)"

install:
	@echo "=> Installing jupyter_cadquery"
	@pip install --upgrade .

check_dist:
	@twine check dist/*

upload:
	@twine upload dist/*

upload_ext:
	cd js && npm publish

# dev tools

dev_tools:
	pip install twine bumpversion yapf pylint pyYaml

# Docker commands

DOCKER_CADQUERY_RELEASE=0.9.2-rc3
DOCKER_IMAGE=bernhard-42/jupyter-cadquery:${DOCKER_CADQUERY_RELEASE}
DOCKER_WORKDIR=examples
DOCKER_PORT=8888
DOCKER_NAME=jupyter-cadquery
DOCKER_CMD=
docker_build:
	docker build --rm -t ${DOCKER_IMAGE} -f docker/Dockerfile .

docker_run:
	docker run -it --rm --name ${DOCKER_NAME} -v ${DOCKER_WORKDIR}:/home/cq/workdir -p ${DOCKER_PORT}:8888 ${DOCKER_IMAGE} ${DOCKER_CMD}

docker_stop:
	docker stop ${DOCKER_NAME}

docker_rm:
	docker rm ${DOCKER_NAME}

docker_exec:
	docker exec -it ${DOCKER_NAME} ${DOCKER_CMD}
