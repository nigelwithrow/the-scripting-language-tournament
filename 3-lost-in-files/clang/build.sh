#!/usr/bin/env bash
gcc main.c \
	-I"$(nix eval --raw 'nixpkgs#zlib.dev.outPath')/include" \
	-L"$(nix eval --raw 'nixpkgs#zlib.outPath')/lib" \
	-lz
