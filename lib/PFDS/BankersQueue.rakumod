use v6.d;

use PFDS;
use PFDS::Queue;

class PFDS::BankersQueue does PFDS::Queue {
    has $!front;
    has int $!front-elems;
    has $!rear;
    has int $!rear-elems;
    method !SET-SELF(\F, \lenF, \R, \lenR) {
        $!front := F;
        $!front-elems = lenF;
        $!rear  := R;
        $!rear-elems  = lenR;
        self;
    }

    # This private constructor maintains the class invariant:
    # the front contains at least as many items as the rear
    sub queue(\F, \lenF, \R, \lenR) {
        lenR <= lenF
          ?? ::?CLASS.CREATE!SET-SELF(F, lenF, R, lenR)
          !! ::?CLASS.CREATE!SET-SELF(F ++ R.reversed, lenF + lenR, stream, 0);
    }

    # Public constructor
    multi method new(--> ::?CLASS:D) {
        ::?CLASS.CREATE!SET-SELF(stream, 0, stream, 0)
    }

    multi method Bool(::?CLASS:D: --> Bool:D) { $!front.Bool }

    multi method elems(::?CLASS:D: --> Int:D) { $!front-elems + $!rear-elems }

    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D) {
        queue $!front, $!front-elems, $!rear.insert(item), $!rear-elems + 1;
    }

    multi method head(::?CLASS:D:) { $!front.head }

    multi method skip(::?CLASS:D: --> ::?CLASS:D) {
        queue $!front.skip, $!front-elems - 1, $!rear, $!rear-elems;
    }
}

=begin pod

=head1 NAME

PFDS::BankersQueue - Simple, purely functional queue implementation

=head1 DESCRIPTION

    class PFDS::BankersQueue does PFDS::Queue {}

A C<PFDS::BankersQueue> is a simple, L<purely functional queue|Queue>
implementation. Every atomic operation takes I<O>(1) worst-case time, except
C<.skip> which takes I<O>(1) amortized time but I<O>(n) worst-case time.

=head1 METHODS

=head2 method new

    multi method new(--> ::?CLASS:D)

Returns an empty queue.

=head2 method Bool

    multi method Bool(::?CLASS:D: --> Bool:D)

Returns C<False> only if the queue is empty.

=head2 method elems

    multi method elems(::?CLASS:D: --> Int:D)

Returns the number of items on the queue.

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
