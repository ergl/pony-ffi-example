PONYC ?= ponyc
ponyrt_include ?=
ponyc_trycatch ?=

# PONYC := ~/dev/ponyc/build/debug/ponyc
# ponyrt_include := ~/dev/ponyc/src/libponyrt
# ponyc_trycatch := ~/dev/ponyc/build/build_release/except_try_catch.o

ifeq ($(ponyrt_include),)
    $(error Unknown path to libponyrt "". Must set using 'ponyrt_include=FOO')
endif

ifeq ($(ponyc_trycatch),)
    $(error Unknown path to except_try_catch.o "". Must set using 'ponyc_trycatch=FOO')
endif

all: build_jch_c
	$(PONYC) -o build jch

# Build jch as a shared library
# this only works on OSX, look how to do it for Windows/Linux
build_jch_c:
	mkdir -p build
	clang -fPIC -Wall -Wextra -O3 -I $(ponyrt_include) -g -MM jch_c/jch.c > jch_c/jch.d
	clang -fPIC -Wall -Wextra -O3 -g -c -o jch_c/jch.o jch_c/jch.c
	clang -shared -undefined dynamic_lookup -lm -o jch_c/libjch.dylib jch_c/jch.o $(ponyc_trycatch)

clean:
	rm -rf build
	rm -rf jch_c/*.{d,o}
	rm -rf jch_c/libjch.dylib
