all: release

release: uspec.js

%.js: %.coffee
	coffee --compile $<

run_spec.js: fake_module.js uspec.js uspec_spec.js
	cat $^ > $@

node_spec: uspec_spec.js uspec.js 
	node $<

phantom_spec: run_spec.js
	phantomjs $<

spec: node_spec phantom_spec

clean:
	@rm -f *.js

.PHONY: release node_spec phantom_spec spec
