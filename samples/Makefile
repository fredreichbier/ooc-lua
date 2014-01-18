all: test-closure test-bind test-functions

# ---

sum: sum.ooc
	rock -vv sum

test-sum: clean sum
	./sum

# ---

closure: closure.ooc
	rock -vv closure

test-closure: clean closure
	./closure

# ---

bind: bind.ooc bind.repo
	rock -vv bind.ooc

test-bind: clean bind
	./bind

# ---

functions: functions.ooc functions.repo
	rock -vv functions.ooc

test-functions: clean functions
	./functions

# ---

valuepassing: valuepassing.ooc valuepassing.repo
	rock -vv valuepassing.ooc

test-valuepassing: clean valuepassing
	./valuepassing

# ---

closurehowl: closurehowl.ooc closurehowl.repo
	rock -vv closurehowl.ooc

test-closurehowl: clean closurehowl
	./closurehowl


# ---

%.repo: %.ooc
	rock --backend=luaffi --outpath=$@ $^

clean:
	rock -x
	rm -rf *.repo

.PHONY: all clean test-sum test-closure test-bind test-functions test-valuepassing
