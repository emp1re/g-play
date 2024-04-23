#!/bin/bash
gen:
	@echo "Generating graphql files"
	go get github.com/99designs/gqlgen@v0.17.45
	go run github.com/99designs/gqlgen generate
air :
	@echo "Running air"
	air -c .air.toml

build:
	@echo "Building the project"
	chmod +x build.sh

.PHONY: gen build	air
