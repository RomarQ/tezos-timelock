
SWITCH := smartpy_timelock
COMPILER := ocaml-base-compiler.4.12.0

.env:
	eval $(opam env)

setup: export SWITCH := $(SWITCH)
setup: export COMPILER := $(COMPILER)
setup:
	@./scripts/setup.sh

build: .env
	dune build timelock_js.bc.js --release

clean: .env
	opam switch remove --yes $(SWITCH)
