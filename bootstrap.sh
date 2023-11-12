#!/usr/bin/env sh

## Install Cargo
curl https://sh.rustup.rs -sSf | sh -s -- -y

## Load executable in current shell
source $HOME/.cargo/env

## Install just to run the rest of the install
cargo install just