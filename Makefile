all: test run

run:
	zig build run -freference-trace --summary all

test:
	zig build test --summary all -freference-trace
test-cov:
	rm -rf kcov-output
	./test_cov.sh
