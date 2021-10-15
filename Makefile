
SWITCH := smartpy_timelock
COMPILER := ocaml-base-compiler.4.12.0

.env:
	@echo "Load environment"
	@eval $(opam env)

setup: export SWITCH := $(SWITCH)
setup: export COMPILER := $(COMPILER)
setup:
	@./scripts/setup.sh

build: .env
	@echo "Build Javascript from Ocaml"
	@dune build lib_timelock/timelock_js.bc.js --release

clean: .env
	@echo "Clean environment"
	@opam switch remove --yes $(SWITCH)
