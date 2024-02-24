NAME
====

PFDS - Purely functional data structures

DESCRIPTION
===========

    unit module PFDS;

    role Series does Iterable {}

    class Series::Node does Series {}

    class Stream does Series {}

Module `PFDS` provides one of the most fundamental purely functional data types: immutable, potentially lazy **linked lists**. Linked lists don't support the efficient positional access that may be expected from Raku lists, hence this library calls them `Series`.

A proper series is represented by a `Series::Node` that links an immutable *value*, the `.head` of the series, to the series with the rest of the values. The last node of a series is linked to the empty series, the only `Series` which evaluates to `False` in Boolean context.

A lazily evaluated, potentially infinite series is called a `Stream`. A stream may be called explicitly to obtain a `Series::Node` or the empty series. Calling a method like `.Bool`, `.head` or `.skip` implicitly reifies the head of the stream.

EXPORTS
=======

Module `PFDS` exports the following subroutines by default.

sub series
----------

Defined as:

    sub series(**@values --> Series)

Returns the decontainerized values as a `Series`.

sub stream
----------

    sub stream(+values --> Stream)

Returns the decontainerized values as a `Stream`.

infix ++
--------

    sub infix:<++>(Series \s, Series \t --> Stream:D)

Concatenates the two series into a stream containing the values of `s` followed by the values of `t`.

sub copy
--------

    multi sub copy(\n, Series \values --> Series)

Returns a lazy copy of the first `n` values.

sub skip
--------

    multi sub skip(\n, Series \values --> Series)

Returns the series without the first `n` values.

METHODS
=======

The following methods are implemented by all `Series` types in the `PFDS` namespace.

method CALL-ME
--------------

    method CALL-ME(--> Series)

Returns the node at the head of the series, or the empty series if there is no such node.

method copy
-----------

    multi method copy(Int() \n --> Series)
    multi method copy(int \n --> Series)

Returns the first `n` values of the invocant as a stream, or the empty series if `n < 1`.

method head
-----------

    multi method head()

Returns the first value of the series, or `Nil` if the series is empty.

method iterator
---------------

    method iterator(--> Iterator:D)

Returns an [`Iterator`](https://docs.raku.org/type/Iterator) over the values of the series. Note that iterators are inherently mutable, so they're *not thread-safe*.

method list
-----------

    method list()

Returns a [list](https://docs.raku.org/type/PositionalBindFailover#method_list) based on the `.iterator`. Note that such lazy lists are *not thread-safe*.

method skip
-----------

    multi method skip(--> Series)
    multi method skip(Int() \n --> Series)

Returns the series that remains after discarding the first value or first `n` values of the series. Negative values of `n` count as 0.

