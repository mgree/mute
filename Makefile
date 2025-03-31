.PHONY: test lint clean

test: run_tests.sh $(shell find tests -type f)
	./run_tests.sh

lint: run_lints.sh $(shell find lints -type f)
	./run_lints.sh

man/mute.1: man/mute.1.md
	pandoc --standalone --from markdown-smart --to man -o $@ $<

clean:
	-rm man/mute.1
