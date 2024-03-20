use v6.d;
use PFDS::Sequence;

role PFDS::Queue does PFDS::Sequence {
    proto method enqueue(|) {*}
    multi method enqueue(::?CLASS:U: Mu \item --> ::?CLASS:D) {
        self.new.enqueue(item);
    }
    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D) {...}
}

=begin pod

=head1 NAME

PFDS::Queue - Purely functional queue abstraction

=head1 DESCRIPTION

    role PFDS::Queue does PFDS::Sequence {}

Role C<PFDS::Queue> extends L<immutable sequences|Sequence> with an I<enqueue>
operation that returns a new queue with the provided item to the rear of the
previously enqueued items. Simply destructure the queue to I<dequeue> the item
at the front of the queue.

For example, the following code adds three items to the rear of the queue and
then removes and prints items in B<first in, first out> (B<FIFO>) order until
the queue is empty:

    $queue .= enqueue($_) for ^3;
    while $queue {
        ($_, $queue) := $queue;
        .say;
    }

Note that statements like C<$queue .= enqueue($_)> update the C<$queue>
variable rather than the C<PFDS::Queue> object stored in that variable.

=head1 METHODS

=head2 method enqueue

    multi method enqueue(::?CLASS:U: Mu \item --> ::?CLASS:D)
    multi method enqueue(::?CLASS:D: Mu \item --> ::?CLASS:D)

Re-dispatches to an empty queue instance if the invocant is undefined. All
classes doing the C<PFDS::Queue> role must provide a candidate that returns a
new queue with the decontainerized C<item> added to the rear of the invocant's
items.

=end pod