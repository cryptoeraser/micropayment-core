PY_VERSION := 3
WHEEL_DIR := $(HOME)/tmp/wheelhouse
PIP := env/bin/pip
PY := env/bin/python
PEP8 := env/bin/pep8
AUTOPEP8 := env/bin/autopep8
COVERAGE := env/bin/coverage
USE_WHEELS := 0
ifeq ($(USE_WHEELS), 0)
  WHEEL_INSTALL_ARGS := # void
else
  WHEEL_INSTALL_ARGS := --use-wheel --no-index --find-links=$(WHEEL_DIR)
endif
export VIRTUALENV_PATH=env/bin/
export COUNTERPARTY_URL=http://127.0.0.1:14000/api/


help:
	@echo "COMMANDS:"
	@echo "  clean          Remove all generated files."
	@echo "  setup          Setup development environment."
	@echo "  shell          Open ipython from the development environment."
	@echo "  test           Run tests."
	@echo "  lint           Run analysis tools."
	@echo "  wheel          Build package wheel & save in $(WHEEL_DIR)."
	@echo "  wheels         Build dependency wheels & save in $(WHEEL_DIR)."
	@echo "  publish        Build and upload package to pypi.python.org"
	@echo "  graphs         Generate graphs"
	@echo ""
	@echo "VARIABLES:"
	@echo "  PY_VERSION     Version of python to use. Default: $(PY_VERSION)"
	@echo "  WHEEL_DIR      Where you save wheels. Default: $(WHEEL_DIR)."
	@echo "  USE_WHEELS     Install packages from wheel dir, off by default."


clean:
	rm -rf env
	rm -rf build
	rm -rf dist
	rm -rf __pycache__
	rm -rf htmlcov
	rm -rf *.egg
	rm -rf *.egg-info
	find | grep -i ".*\.pyc$$" | xargs -r -L1 rm


virtualenv: clean
	virtualenv -p /usr/bin/python$(PY_VERSION) env
	$(PIP) install wheel


fetch_wheel: virtualenv
	$(PIP) wheel --find-links=$(WHEEL_DIR) --wheel-dir=$(WHEEL_DIR) $(PACKAGE)


wheels: virtualenv
	$(PIP) wheel --find-links=$(WHEEL_DIR) --wheel-dir=$(WHEEL_DIR) -r requirements.txt
	$(PIP) wheel --find-links=$(WHEEL_DIR) --wheel-dir=$(WHEEL_DIR) -r requirements_tests.txt
	$(PIP) wheel --find-links=$(WHEEL_DIR) --wheel-dir=$(WHEEL_DIR) -r requirements_develop.txt


wheel: setup
	$(PY) setup.py bdist_wheel
	mv dist/*.whl $(WHEEL_DIR)


setup: virtualenv
	$(PIP) install $(WHEEL_INSTALL_ARGS) -r requirements.txt
	$(PIP) install $(WHEEL_INSTALL_ARGS) -r requirements_tests.txt
	$(PIP) install $(WHEEL_INSTALL_ARGS) -r requirements_develop.txt
	$(PY) setup.py develop


sandbox: setup
	$(PY) tools/sandbox.py


shell: install
	env/bin/ipython


test: setup
	$(AUTOPEP8) --in-place --aggressive --aggressive --recursive micropayment_core
	$(AUTOPEP8) --in-place --aggressive --aggressive --recursive tests
	$(PEP8) micropayment_core
	$(PEP8) tests
	$(COVERAGE) run --source=micropayment_core setup.py test
	$(COVERAGE) html
	$(COVERAGE) report --fail-under=99


publish: test
	$(PY) setup.py register bdist_wheel upload


view_readme: setup
	env/bin/restview README.rst


# Break in case of bug!
# import pudb; pu.db
