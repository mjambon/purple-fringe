.PHONY: default
default:
	cd src; $(MAKE)

.PHONY: examples
examples: default
	cd examples; $(MAKE)

.PHONY: clean
clean:
	rm -f *~
	cd src; $(MAKE) clean
	cd examples; $(MAKE) clean
