.PHONY: examples
EXAMPLES = \
  wikipedia-horsie \
  butterfly \
  eye \
  tree \
  snake \
  purple-sky \
  purple0 \
  purple2 \
  purple3 \
  difficult \
  worst-case

EXAMPLES_IN = $(addsuffix .jpg, $(EXAMPLES))
EXAMPLES_OUT = $(addsuffix -fixed.jpg, $(EXAMPLES))
EXAMPLES_DIFF = $(addsuffix -diff.jpg, $(EXAMPLES))

examples: examples.html
examples.html: $(EXAMPLES_OUT) $(EXAMPLES_DIFF) Makefile
	./make-examples.sh $(EXAMPLES)

%-fixed.jpg: %.jpg ../src/unpurple
	../src/unpurple $< $@

%-diff.jpg: %.jpg ../src/unpurple
	../src/unpurple -diff $< $@

.PHONY: install
install:
	mkdir -p $$WWW/purple-fringe
	cp examples.html $(EXAMPLES_IN) $(EXAMPLES_OUT) $(EXAMPLES_DIFF) \
		$$WWW/purple-fringe

.PHONY: clean
clean:
	rm -f *~
