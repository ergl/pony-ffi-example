all: build_jch_c
	ponyc -o build jch

# Build jch as a shared library
# this only works on OSX, look how to do it for Windows/Linux
build_jch_c:
	mkdir -p build
	clang -fPIC -Wall -Wextra -O3 -g -MM jch_c/jch.c > jch_c/jch.d
	clang -fPIC -Wall -Wextra -O3 -g -c -o jch_c/jch.o jch_c/jch.c
	clang -shared -lm -o jch_c/libjch.dylib jch_c/jch.o

clean:
	rm -rf build
	rm -rf jch_c/*.{d,o}
	rm -rf jch_c/libjch.dylib
