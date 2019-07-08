
# (extra-gc)

The `extra-gc` library adds custom garbage collection functionality to Chez Scheme.
Specifically, it provides a centralized mechanism for releasing resources not covered by
Chez's default behavior.

## Interface

The library exports the following functions:

* add-collector!

* custom-collect

* make-custom-collector

### add-collector!

`(add-collector! collector-function)`

`add-collector!` accepts a function argument and adds it to the
internal list of custom collectors. The argument should be a function that
accepts no arguments. `make-custom-collect` returns a function valid for use
by `add-collector!`.

### custom-collect

`(custom-collect)`

`custom-collect` is a function that accepts no arguments.
It runs Chez Scheme's [`collect`](http://cisco.github.io/ChezScheme/csug9.5/smgmt.html#./smgmt:s9) function and then calls all the registered
collectors. This is exported for convenience and application users are
not required to use it. The library sets `custom-collect`
as the [`collect-request-handler`](http://cisco.github.io/ChezScheme/csug9.5/smgmt.html#./smgmt:s17) as a side-effect of loading the library.

### make-custom-collector

`(make-custom-collector free guardian)`

`(make-custom-collector free guardian count)`

`make-custom-collector` accepts either two or three arguments.
The first argument should be a function that accepts a single argument
and releases whatever resources are associated with that object.
The second argument should be function which is a
 [guardian](http://cisco.github.io/ChezScheme/csug9.5/smgmt.html#./smgmt:s29).
The third argumemt, if provided, should be a positive exact integer. It
determines how many objects returned by the guardian procedure are processed
for any single collect. If not provided, `count` defaults to `100`

`make-custom-collector` returns a nullary function that passes objects returned
from the given `guardian` procedure to the given `free` procedure
at most `count` number of times.


## Miscellaneous

This library is currently only written for Chez Scheme. This will work on
either threaded or non-threaded version of Chez Scheme. If Chez Scheme is threaded,
the `add-collector!` and `custom-collect` functions execute inside a mutex.

If the `free` or `guardian` procedures invoke a continuation, you're on your own.

Guardians in Chez Scheme will accept the same object multiple times and
return that object the same number of times. If necessary, the free procedure
should handle this case.
