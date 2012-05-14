purple_fringe: purple_fringe.ml
	ocamlfind ocamlopt -o purple_fringe purple_fringe.ml \
		-package camlimages -linkpkg

.PHONY: examples
EXAMPLES = \
  wikipedia-horsie \
  butterfly \
  eye \
  purple-sky \
  tree \
  purple0 \
  purple1 \
  purple2 \
  purple3

EXAMPLES_IN = $(addsuffix .jpg, $(EXAMPLES))
EXAMPLES_OUT = $(addsuffix -fixed.jpg, $(EXAMPLES))

examples: examples.html
examples.html: $(EXAMPLES_OUT) Makefile
	./make-examples.sh $(EXAMPLES)

%-fixed.jpg: %.jpg purple_fringe
	./purple_fringe $< $@

.PHONY: clean
clean:
	rm -f *.cmi *.cmx *.o purple_fringe
