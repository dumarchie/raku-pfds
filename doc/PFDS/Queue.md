NAME
====

PFDS::Queue - Purely functional queue abstraction

DESCRIPTION
===========

    role PFDS::Queue does PFDS::Sequence {}

Role `PFDS::Queue` extends [immutable sequences](Sequence) with an *enqueue* operation that returns a new queue with the provided item to the rear of the previously enqueued items. Simply destructure the queue to *dequeue* the item at the front of the queue.

For example, the following code adds three items to the rear of the queue and then removes and prints items in **first in, first out** (**FIFO**) order until the queue is empty:

    $queue .= enqueue($_) for ^3;
    while $queue {
        ($_, $queue) := $queue;
        .say;
    }

Note that statements like `$queue .= enqueue($_)` update the `$queue` variable rather than the `PFDS::Queue` object stored in that variable.

METHODS
=======

method enqueue
--------------

    multi method enqueue(::?CLASS:U: Mu \item --> ::?CLASS:D)
    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D)

Re-dispatches to an empty queue instance if the invocant is undefined. All classes doing the `PFDS::Queue` role must provide a candidate that returns a new queue with the decontainerized `item` added to the rear of the invocant's items.

