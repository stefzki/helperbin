#!/bin/sh
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
cd homebrew/bin
./brew install wget
./brew install mtr
./brew install wakeonlan
