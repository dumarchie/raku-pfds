NAME
====

PFDS::BatchedQueue - Simple, purely functional queue implementation

DESCRIPTION
===========

    class PFDS::BatchedQueue does PFDS::Queue {}

A `PFDS::BatchedQueue` is a simple, [purely functional queue](Queue) implementation. Every atomic operation takes *O*(1) worst-case time, except `.skip` which takes *O*(1) amortized time but *O*(n) worst-case time.

METHODS
=======

method new
----------

    multi method new(--> ::?CLASS:D)

Returns an empty queue.

method Bool
-----------

    multi method Bool(::?CLASS:D: --> Bool:D)

Returns `False` only if the queue is empty.

method enqueue
--------------

    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D)

Returns a new queue with the decontainerized `item` added to the rear of the invocant's items.

method head
-----------

    multi method head(::?CLASS:D:)

Returns the item at the front of the queue.

method skip
-----------

    multi method skip(::?CLASS:D: --> ::?CLASS:D)

Returns a queue with the remaining items after discarding the item at the front.

