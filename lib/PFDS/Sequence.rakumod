use v6.d;

role PFDS::Sequence does Iterable {
    proto method new(|) {*}
    multi method new(--> ::?CLASS:D) {...}

    multi method Bool(::?CLASS:D: --> Bool:D) {...}

    method Capture(::?CLASS:D: --> Capture:D) {
        X::Cannot::Capture.new(what => self).throw unless self;
        \(self.head, self.skip);
    }

    multi method head(::?CLASS:D:) {...}

    multi method iterator(::?CLASS:D: --> Iterator:D) {
        my class :: does Iterator {
            has $.sequence;
            method pull-one() {
                if my \queue = $!sequence {
                    $!sequence := queue.skip;
                    queue.head;
                }
                else { IterationEnd }
            }
        }.new(sequence => self);
    }

    multi method list(::?CLASS:D: --> List:D) {
        self.Seq.list;
    }

    method next(::?CLASS:D: --> ::?ROLE:D) {
        self.skip;
    }

    multi method skip(::?CLASS:D:) is raw {...}
    multi method skip(::?CLASS:D: Int() \n) is raw {
        my int $n = n;
        my $self := self;
        while --$n > 0 {
            $self := $self.next or $n = 0;
        }
        $self := $self.skip if $n == 0;
        $self;
    }
}

=begin pod

=head1 METHODS

=head1 NAME

PFDS::Sequence - Purely functional sequences

=head1 DESCRIPTION

    role PFDS::Sequence does Iterable {}

Role C<PFDS::Sequence> defines common methods to access, destructure and
iterate over purely functional sequences.

=head1 METHODS

=head2 method new

    multi method new(--> ::?CLASS:D)

Method stub. All classes doing the C<PFDS::Sequence> role must provide an empty
sequence constructor.

=head2 method Bool

    multi method Bool(::?CLASS:D: --> Bool:D)

Method stub. Classes doing the C<PFDS::Sequence> role should return C<False>
only if the sequence is empty.

=head2 method Capture

    method Capture(::?CLASS:D: --> Capture:D)

Throws C<X::Cannot::Capture> if called on an empty sequence. Otherwise returns
a C<Capture> with two positional elements, the C<.head> of the invocant and the
sequence returned by C<.skip>.

This I<destructuring> method allows clients to combine these two operations in
a single statement. For example, the following statement removes the first item
from the sequence and stores it in the topic variable:

    ($_, $sequence) := $sequence;

Note that the statement updates the C<$sequence> variable rather than the
C<PFDS::Sequence> object stored in that variable.

=head2 method head

    multi method head(::?CLASS:D:)

Method stub. Classes doing the C<PFDS::Sequence> role should return the item at
the front of the queue, or C<Nil> if the sequence is empty.

=head2 method iterator

    multi method iterator(::?CLASS:D: --> Iterator:D)

Returns an C<Iterator> over the items in the sequence. Note that iterators are
inherently mutable, so they're I<not thread-safe>.

=head2 method list

    multi method list(::?CLASS:D: --> List:D)

Returns a lazy C<List> based on the C<.iterator>. Note that lists are I<not
thread-safe> until fully reified.

=head2 method next

    method next(::?CLASS:D: --> ::?ROLE:D)

Eagerly evaluates the result of C<.skip>. Classes doing the C<PFDS::Sequence>
role may provide an implementation that bypasses suspension altogether.

=head2 method skip

    multi method skip(::?CLASS:D:) is raw
    multi method skip(::?CLASS:D: Int() \n) is raw

The first candidate is a method stub. Classes doing the C<PFDS::Sequence> role
should return the sequence without the first item, or return the empty sequence
self. The second candidate returns the sequence without the first C<n> items.

Note that this method may return a I<suspended> sequence. Reification of the
head may be delayed by I<binding>, rather than assigning the result.

=end pod