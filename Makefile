SHELL := /bin/bash
PKG := github.com/Clever/shorty
PKGS := $(shell go list ./... | grep -v /vendor)
EXECUTABLE := shorty
.PHONY: test build clean doc vendor $(PKGS)

GOVERSION := $(shell go version | grep 1.5)
ifeq "$(GOVERSION)" ""
  $(error must be running Go version 1.5)
endif
export GO15VENDOREXPERIMENT=1

all: build test

test: $(PKGS)

GOLINT := $(GOPATH)/bin/golint
$(GOLINT):
	@go get github.com/golang/lint/golint

GODEP := $(GOPATH)/bin/godep
$(GODEP):
	@go get -u github.com/tools/godep

$(PKGS): $(GOLINT)
	@echo "FORMATTING..."
	@gofmt -w=true $(GOPATH)/src/$@/*.go
	@echo "LINTING..."
	@$(GOLINT) $(GOPATH)/src/$@/*.go
	@echo ""
	@echo "TESTING..."
	@go test -v $@
	@echo ""

build: $(PKGS)
	go build -o bin/$(EXECUTABLE) $(PKG)

clean:
	rm -rf build

vendor: $(GODEP)
	$(GODEP) save $(PKGS)
	find vendor/ -path '*/vendor' -type d | xargs -IX rm -r X # remove any nested vendor directories
