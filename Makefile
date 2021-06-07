VENV = .venv
VENV_BIN = $(VENV)/bin
# Extract MAJOR.MINOR python version
PYTHON_VERSION := $(shell cat $(PWD)/.python-version | awk -F \. {'print $$1"."$$2'})

$(VENV): requirements.txt setup.py
	python$(PYTHON_VERSION) -m venv $(VENV)
	$(VENV_BIN)/pip install --upgrade pip setuptools && \
	$(VENV_BIN)/pip install -r requirements.txt && \
	$(VENV_BIN)/pip install -e .
	touch $(VENV)

virtualenv-create:
	rm -rf $(VENV)
	$(MAKE) $(VENV)
