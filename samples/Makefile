# Although this looks horrible, you can simply add new
# tests to the following variable. This makefile then
# runs the Lua backend on %.ooc, then compiles and runs it.
TESTS := closure bind functions valuepassing closurehowl oocffi sum props inheritance deeper cache
TESTS_RULES := $(patsubst %,%.test,${TESTS})
REPO_RULES := $(patsubst %,%.repo,${TESTS})

all: ${TESTS_RULES}

%.test: clean %.repo
	rock -v $*
	./$*

%.repo: %.ooc
	rock --backend=luaffi --outpath=$@ $^

clean:
	rm -f ${TESTS}
	rock -x
	rm -rf *.repo

.SECONDARY: ${REPO_RULES}
.PHONY: all clean ${TEST_RULES}
