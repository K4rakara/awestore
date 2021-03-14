.PHONY: default build install

LUA ?= lua5.4

default: build

build:
	@echo "---- Build ----";
	@$(LUA) ./build.lua;

install:
	@echo "---- Install ----";

