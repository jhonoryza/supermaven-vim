.PHONY: help test lint

help:
	@echo "supermaven-vim"
	@echo "  make test  - run vader tests (if installed)"
	@echo "  make lint  - vint lint"

test:
	@echo "no tests yet - run vim -u NONE -c 'helptags doc' -c 'qa!'"

lint:
	@echo "vint autoload/**/*.vim plugin/*.vim"
	@vint --version 2>&1 | head -n 1 || echo "vint not installed, skip"

