include golang.mk
.DEFAULT_GOAL := test # override default goal set in library makefile

.PHONY: test build clean doc vendor $(PKGS)
SHELL := /bin/bash
PKG := github.com/Clever/shorty
PKGS := $(shell go list ./... | grep -v /vendor)
EXECUTABLE := $(shell basename $(PKG))
$(eval $(call golang-version-check,1.7))

all: test build

build:
	go build -o bin/$(EXECUTABLE) $(PKG)

clean:
	rm bin/*

test: $(PKGS)
$(PKGS): golang-test-all-deps
	$(call golang-test-all,$@)

vendor: golang-godep-vendor-deps
	$(call golang-godep-vendor,$(PKGS))
