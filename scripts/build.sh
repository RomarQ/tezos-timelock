#!/bin/sh

# Compile javascript code from ocaml code
opam exec -- dune build ml_timelock/timelock_js.bc.js --release

# Build the javascript module
npm run build --prefix js_timelock
