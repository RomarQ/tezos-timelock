SWITCH := smartpy_timelock
COMPILER := ocaml-base-compiler.4.12.0

.env:
	@echo "Load environment"
	@eval $(opam env)

setup: export SWITCH := $(SWITCH)
setup: export COMPILER := $(COMPILER)
setup:
	@echo "Setup environment"
	@./scripts/setup.sh

build: .env
	@echo "Build Javascript from Ocaml"
	@./scripts/build.sh

test: .env
	@echo "Test Javascript distributable"
	@./scripts/test.sh

clean: .env
	@echo "Clean environment"
	@opam switch remove --yes $(SWITCH)
