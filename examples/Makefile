.PHONY: examples
EXAMPLES = \
  wikipedia-horsie \
  butterfly \
  eye \
  tree \
  snake \
  purple-sky \
  purple0 \
  purple1 \
  purple2 \
  purple3

EXAMPLES_IN = $(addsuffix .jpg, $(EXAMPLES))
EXAMPLES_OUT = $(addsuffix -fixed.jpg, $(EXAMPLES))

examples: examples.html
examples.html: $(EXAMPLES_OUT) Makefile
	./make-examples.sh $(EXAMPLES)

%-fixed.jpg: %.jpg ../src/unpurple
	../src/unpurple $< $@

.PHONY: clean
clean:
	rm -f *~
