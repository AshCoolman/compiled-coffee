CS2TS=./node_modules/coffee-script-to-typescript/bin/coffee
TS=./node_modules/typescript/bin/tsc
CS=./node_modules/coffee-script/bin/coffee
CS_GENERATORS=./node_modules/coffeescript-generators/bin/coffee
MOCHA=./node_modules/mocha/bin/mocha

builder:
	$(CS_GENERATORS) \
		--watch -c \
		src/coffeetype/builder.generators.coffee \
		src/coffeetype.coffee \
		src/coffeetype/commands.coffee

build:
	make clean
	make typescript
	make compile

build-watch:
	make clean
	#make typescript-watch > /dev/null &
		make typescript-watch &
	# sleep needs to include all sleep from forked cmds
	sleep 4
	make compile-watch

typescript:
	make coffee-to-typescript
	make copy-definitions
	make merge-definitions
	make fix-modules

typescript-watch:
	make coffee-to-typescript-watch &
	sleep 2
	make merge-definitions-watch &
	sleep 1
	make fix-modules-watch

coffee-to-typescript:
	$(CS2TS) -cma -o build/cs2ts example/*.coffee
	rm build/cs2ts/*.js

coffee-to-typescript-watch:
	$(CS2TS) -wcma -o build/cs2ts example/*.coffee
	rm build/cs2ts/*.js

copy-definitions:
	cp example/*.d.ts build/cs2ts

copy-definitions-watch:
	$(CS) src/watch-and-copy.coffee -p example -o build/cs2ts example/*.d.ts

merge-definitions:
	make copy-definitions
	$(CS) src/dts-merger.coffee \
		--dir-prefix build/cs2ts \
		--output build/typed \
		build/cs2ts/*.ts

merge-definitions-watch:
	make copy-definitions-watch &
	sleep 0.5
	$(CS) src/dts-merger.coffee \
		--dir-prefix build/cs2ts \
		--watch \
		--output build/typed \
		build/cs2ts/*.ts

fix-modules:
	$(CS) src/commonjs-to-typescript.coffee \
		--dir-prefix build/typed \
		--output build/typescript \
		build/typed/*.ts

fix-modules-watch:
	$(CS) src/commonjs-to-typescript.coffee \
		--dir-prefix build/typed \
		--watch \
		--output build/typescript \
		build/typed/*.ts

compile:
	$(TS) \
		typings/ecma.d.ts \
		--noLib \
		--module commonjs \
		build/typescript/*.ts

compile-watch:
	$(TS) \
		typings/ecma.d.ts \
		--noLib \
		--watch \
		--module commonjs \
		build/typescript/*.ts

test:
	rm test/build/*/**
	$(MOCHA) \
		--harmony-generators \
		--compilers coffee:coffee-script \
		--reporter spec \
		test/*.coffee

test-watch:
	$(MOCHA) \
		--watch \
		--harmony-generators \
		--compilers coffee:coffee-script \
		--reporter spec \
		test/*.coffee

test-debug:
	$(MOCHA) \
		--debug-brk \
		--harmony-generators \
		--compilers coffee:coffee-script \
		--reporter spec \
		test/*.coffee

clean:
	rm build/*/*
	
debugger:
	./node_modules/node-inspector/bin/inspector.js

.PHONY: build test