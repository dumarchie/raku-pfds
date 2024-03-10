use v6.d;

use PFDS;
use PFDS::Queue;

class PFDS::BatchedQueue does PFDS::Queue {
    has PFDS::Series $!front;
    has PFDS::Series $!rear;
    method !SET-SELF(\front, \rear) {
        $!front := front;
        $!rear  := rear;
        self;
    }

    # This private constructor maintains the class invariant:
    # the front is empty only if the rear is empty
    sub queue(\front, \rear) {
        front
          ?? ::?CLASS.CREATE!SET-SELF(front, rear)
          !! ::?CLASS.CREATE!SET-SELF(rear.reverse, series);
    }

    # Public constructor
    multi method new(--> ::?CLASS:D) {
        ::?CLASS.CREATE!SET-SELF(series, series)
    }

    multi method Bool(::?CLASS:D: --> Bool:D) { $!front.Bool }

    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D) {
        queue $!front, $!rear.insert(item);
    }

    multi method head(::?CLASS:D:) { $!front.head }

    multi method skip(::?CLASS:D: --> ::?CLASS:D) {
        queue $!front.skip, $!rear;
    }
}

=begin pod

=head1 NAME

PFDS::BatchedQueue - Simple, purely functional queue implementation

=head1 DESCRIPTION

    class PFDS::BatchedQueue does PFDS::Queue {}

A C<PFDS::BatchedQueue> is a simple, L<purely functional queue|Queue>
implementation. Every atomic operation takes I<O>(1) worst-case time, except
C<.skip> which takes I<O>(1) amortized time but I<O>(n) worst-case time.

=head1 METHODS

=head2 method new

    multi method new(--> ::?CLASS:D)

Returns an empty queue.

=head2 method Bool

    multi method Bool(::?CLASS:D: --> Bool:D)

Returns C<False> only if the queue is empty.

=head2 method enqueue

    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D)

Returns a new queue with the decontainerized C<item> added to the rear of the
invocant's items.

=head2 method head

    multi method head(::?CLASS:D:)

Returns the item at the front of the queue.

=head2 method skip

    multi method skip(::?CLASS:D: --> ::?CLASS:D)

Returns a queue with the remaining items after discarding the item at the
front.

=end pod


