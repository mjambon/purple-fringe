purple_fringe: purple_fringe.ml
	ocamlfind ocamlopt -o purple_fringe purple_fringe.ml \
		-package camlimages -linkpkg

.PHONY: examples
examples: purple0-fixed.jpg purple1-fixed.jpg purple2-fixed.jpg \
          purple3-fixed.jpg wikipedia-horsie-fixed.jpg

%-fixed.jpg: %.jpg purple_fringe
	./purple_fringe $< $@

.PHONY: clean
clean:
	rm -f *.cmi *.cmx *.o purple_fringe
