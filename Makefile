SOURCES = src/factory.coffee
ALL     = lib/factory.js
MOCHA	= node_modules/.bin/mocha

all: $(ALL)

lib/%.js: src/%.coffee
	coffee -o lib -c $+

build: all

test:
	@$(MOCHA) \
	  --compilers coffee:coffee-script \
	  --reporter spec

clean:
	rm -rf $(ALL)

.PHONY: all build test clean
