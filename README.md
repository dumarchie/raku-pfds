NAME
====

PFDS - Purely functional data structures

DESCRIPTION
===========

    unit module PFDS;

    role Series does Iterable {}

    my class Node does Series {}

    my class Stream does Series {}

Module `PFDS` provides one of the most fundamental purely functional data types: immutable, potentially lazy **linked lists**. Linked lists don't support the efficient positional access that may be expected from Raku lists, hence this library calls them `Series`.

A proper series is represented by a `Node` that links an immutable *value*, the `.head` of the series, to the series with the rest of the values. The last node of a series is linked to the empty series, the only `Series` evaluating to `False` in Boolean context.

A lazily evaluated, potentially infinite series is called a `Stream`. A stream may be called explicitly to obtain a `Node` or the empty series. Calling a method like `.Bool`, `.head` or `.skip` implicitly reifies the stream head.

EXPORTS
=======

Module `PFDS` exports the following subroutines by default.

sub series
----------

Defined as:

    sub series(**@values --> Series)

Returns a series of decontainerized `@values`.

infix ++
--------

    sub infix:<++>(Series \s, Series \t --> Stream:D)

Concatenates the two series into a stream containing the values of `s` followed by the values of `t`.

METHODS
=======

The following methods are implemented by all `Series` types in the `PFDS` namespace.

method CALL-ME
--------------

    method CALL-ME(--> Series)

Returns the node at the head of the series, or the empty series if the series is empty.

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

