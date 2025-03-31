.PHONY: clean

man/mute.1: man/mute.1.md
	pandoc --standalone --from markdown-smart --to man -o $@ $<

clean:
	-rm man/mute.1
