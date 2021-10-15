#!/bin/sh

# Create opam switch
opam switch create $SWITCH $COMPILER
# Install ml_timelock dependencies
opam switch import --yes env/switch.export

# Install js_timelock dependencies
npm i --prefix js_timelock
