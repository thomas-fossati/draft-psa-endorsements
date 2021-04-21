DRAFT := draft-xyz-rats-psa-endorsements

SHELL := /bin/bash

KDRFC := kdrfc
KDRFC_ARGS := --v3
KDRFC_ARGS += --html
KDRFC_ARGS += --idnits
# prep?

MD := $(DRAFT).md

ART := $(wildcard art/*.txt)

MD_DEPS += $(ART)

HTML := $(MD:.md=.html)
CLEANFILES += $(HTML)

XML := $(MD:.md=.xml)
CLEANFILES += $(XML)

TXT := $(MD:.md=.txt)
CLEANFILES += $(TXT)

all: $(TXT) $(XML) $(HTML)
.PHONY: all

$(TXT) $(XML) $(HTML): $(MD) $(MD_DEPS) ; $(KDRFC) $(KDRFC_ARGS) $<

clean: ; $(RM) $(CLEANFILES)
.PHONY: clean

# docker
docker_image := kdrfc
docker_wdir := /root
docker_run_it := docker run -it -w $(docker_wdir) -v $(shell pwd):$(docker_wdir) $(docker_image)

build-docker: ; docker build -t $(docker_image) .
.PHONY: build-docker

run-docker: ; $(docker_run_it)
.PHONY: run-docker

# Execute any Makefile target into the docker sandbox
# E.g., to run the "all" target in the sandbox, do:
#   make docker-all
# To run the "clean" target in the sandbox, do:
#   make docker-clean
docker-%:
	$(docker_run_it) bash -c "make $(subst docker-,,$@)"

# CI specific target to populate gh-pages
_PUBLISH_DIR ?= public/main
_pre-publish: $(HTML)
	mkdir -p $(_PUBLISH_DIR) && cp $< $(_PUBLISH_DIR)
