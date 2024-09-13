# Tests
TODO: Update this
## Runing tests
`zig build test --summary all -freference-trace`

## Running coverage tests
1. Run the tests
`zig build test --summary all -freference-trace`

2. Run the code coverage to a specific test executable, for example:
```
$ tree
zig-cache/o
├── 20f8f8362ac39302905d03992fa818bc
│   └── dependencies.zig
├── 61890fe26df0c76f1d2655f176b645dd
│   ├── test
│   └── test.o
├── 8f11762ff22a44b751f8dcd7c8f7394e
│   ├── cimport.h
│   └── cimport.h.d
├── ba297723894acb1f307c8d800fe7a9a7
│   ├── test
│   └── test.o
├── be1928ba61f08906ae56c4a23b188375
│   ├── build
│   └── build.o
└── c3d7d1e57139a1bf66d82d05bb37bf21
    └── cimport.zig

7 directories, 10 files
```

`kcov kcov-output zig-cache/o/ba297723894acb1f307c8d800fe7a9a7/test`
`kcov kcov-output zig-cache/o/61890fe26df0c76f1d2655f176b645dd/test`

3. Check the test coverage on `kcov-output/index.html`
