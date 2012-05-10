purple_fringe: purple_fringe.ml
	ocamlfind ocamlopt -o purple_fringe purple_fringe.ml \
		-package camlimages -linkpkg
