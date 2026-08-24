SCRIPTS := scripts

.PHONY: help bootstrap build lint format format-check test test-watch e2e check clean

help:
	@echo "Targets:"
	@echo "  bootstrap    Fetch bats, shellcheck and shfmt into .vendor/"
	@echo "  build        Bundle a standalone executable into build/shotor-cli"
	@echo "  lint         Run shellcheck over the shell sources"
	@echo "  format       Format shell sources with shfmt"
	@echo "  format-check Check formatting without writing changes"
	@echo "  test         Run the bats unit tests (src/)"
	@echo "  test-watch   Re-run unit tests on source changes"
	@echo "  e2e          Run the end-to-end tests (e2e/)"
	@echo "  check        Run lint, test and e2e"
	@echo "  clean        Remove .vendor/ and build/"

bootstrap:
	@$(SCRIPTS)/bootstrap.sh all

build:
	@rm -rf build
	@$(SCRIPTS)/build.sh

lint:
	@$(SCRIPTS)/lint.sh

format:
	@$(SCRIPTS)/format.sh

format-check:
	@$(SCRIPTS)/format.sh --check

test:
	@$(SCRIPTS)/test.sh

test-watch:
	@$(SCRIPTS)/watch.sh test

e2e:
	@$(SCRIPTS)/e2e.sh

check: lint test e2e

clean:
	@rm -rf .vendor build
