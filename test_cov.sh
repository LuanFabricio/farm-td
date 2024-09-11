#!/bin/bash

for path in zig-cache/o/*/test
do
	kcov kcov-output $path
done
