all: test run

run:
	zig build run -freference-trace --summary all

test:
	zig build test --summary all -freference-trace

test-clean:
	rm -rf zig-cache

test-cov: test-clean test
	rm -rf kcov-output
	./test_cov.sh
