NAME
====

PFDS - Purely functional data structures

DESCRIPTION
===========

    unit module PFDS;

    role Series does Iterable {}

    class Series::Node does Series {}

    class Series::Header does Series {}

Module `PFDS` provides one of the most fundamental purely functional data types: immutable, potentially lazy **linked lists**. Linked lists don't support the efficient positional access that may be expected from Raku lists, hence this library calls them `Series`.

A proper, evaluated series is represented by a `Series::Node` that links an immutable *value*, the `.head` of the series, to the series with the rest of the values. The last node of a series is linked to the empty series, the only `Series` which evaluates to `False` in Boolean context.

A lazily evaluated, potentially infinite series is represented by a `Series::Header`. Such a *stream* may be called explicitly to obtain a `Series::Node` or the empty series. Calling a method like `.Bool`, `.head` or `.skip` implicitly reifies the head of the stream.

EXPORTS
=======

Module `PFDS` exports the following subroutines by default.

sub series
----------

Defined as:

    sub series(**@values --> Series)

Returns the decontainerized `@values` as a `Series`.

sub stream
----------

    sub stream(+values --> Series::Header)

Returns the decontainerized `values` as a `Series::Header`.

infix ::
--------

    multi sub infix:<::>(Mu \value, Series \t --> Series::Node:D)

Constructs a `Series::Node` that links the decontainerized `value` to series `t`.

infix ++
--------

    multi sub infix:<++>(Series \s, Series \t --> Series::Header:D)

Concatenates two series into a stream containing the values of `s` followed by the values of `t`.

METHODS
=======

The following methods are implemented by all `Series` types in the `PFDS` namespace.

method CALL-ME
--------------

    method CALL-ME(--> Series)

Returns the node at the head of the series, or the empty series if there is no such node.

method head
-----------

    multi method head()
    multi method head(Int() \n --> Series)
    multi method head(int \n --> Series)

Returns the first value of the series (by default `Nil`) if called without argument. Otherwise returns the first `n` values of the invocant as a stream, or the empty series if `n < 1`.

method insert
-------------

Defined as:

    method insert(**@values --> Series)

Returns a `Series` that consists of the decontainerized `@values` followed by the values of the invocant.

method iterator
---------------

    method iterator(--> Iterator:D)

Returns an [`Iterator`](https://docs.raku.org/type/Iterator) over the values of the series. Note that iterators are inherently mutable, so they're *not thread-safe*.

method list
-----------

    method list()

Returns a [list](https://docs.raku.org/type/PositionalBindFailover#method_list) based on the `.iterator`. Note that such lazy lists are *not thread-safe*.

method reverse
--------------

    method reverse(--> Series)

Returns a series with the same items in reverse order. This operation takes *O*(n) time, where n is the number of values in the series.

method reversed
---------------

    method reversed(--> Series)

Like `.reverse`, but suspends the operation until properties of the reversed series are accessed.

method skip
-----------

    multi method skip(--> Series)
    multi method skip(Int() \n --> Series)

Returns the series that remains after discarding the first value or first `n` values of the series. Negative values of `n` count as 0.

