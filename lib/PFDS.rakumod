use v6.d;
unit module PFDS;

# To be defined later:
my &cons; # protected Series::Node constructor
my &susp; # protected Stream constructor

role Series does Iterable {
    # If forced, return the type object representing the empty series
    method CALL-ME(--> Series) { Series }

    proto method head(|) {*}
    multi method head() { Nil }
    multi method head(Int() \n --> Series) {
        self.head(my int $ = n);
    }
    multi method head(int \n --> Series) {
        n < 1 ?? Series !! susp {
            (my \node = self.())
              ?? cons(node.head, node.skip.head(n - 1))
              !! Series;
        };
    }

    # Iterable methods
    method iterator(--> Iterator:D) {
        my class :: does Iterator {
            has $.series;
            method pull-one() {
                if my \node = $!series() {
                    $!series := node.skip;
                    node.head;
                }
                else { IterationEnd }
            }
        }.new(series => self);
    }

    method list() { self.Seq.list }

    multi method skip(--> Series) { Series }
    multi method skip(Int() \n --> Series) {
        my $series := self;
        my int $n = n;
        while $n-- > 0 {
            my \node = $series() or return Series;
            $series := node.skip;
        }
        $series;
    }
}

class Series::Node does Series {
    has $.value;
    has Series $.next;
    method !SET-SELF(Mu \value, \next) {
        $!value := value;
        $!next  := next;
        self;
    }

    # Protected constructor
    &cons = sub (Mu \value, \next) {
        ::?CLASS.CREATE!SET-SELF(value, next);
    }

    # If forced, return the node self
    method CALL-ME(--> Series) { self }

    # Destructuring
    multi method head() { $!value }

    multi method skip(--> Series) { $!next  }
}

class Stream does Series {
    has $!state;
    method !SET-SELF(\todo) {
        $!state := todo;
        self;
    }

    # Protected constructor
    &susp = proto sub new(|) {*}
    multi sub new(&init) {
        ::?CLASS.CREATE!SET-SELF: my $state = my \todo = {
            my \seen = cas $state, todo, my \new = init;
            seen =:= todo ?? new !! seen;
        }
    }
    multi sub new(&init, Lock:D \lock) {
        ::?CLASS.CREATE!SET-SELF: my $state = my \todo = {
            lock.protect: { $state = init if $state === todo }
        }
    }

    # To force evaluation
    method CALL-ME(--> Series) {
        $!state.VAR =:= $!state ?? $!state !! ($!state := $!state());
    }

    # Destructuring
    multi method Bool(--> Bool:D) { self.().Bool }

    multi method head() { self.().head }

    multi method skip(--> Series) { self.().skip }
}

# Exported and helper functions
proto series(| --> Series) is export {*}
multi series() { Series }
multi series(Mu \item) {
    cons(item<>, Series);
}
multi series(Slip \values) {
    link(values);
}
multi series(**@values is raw) {
    link(@values);
}
sub link(@values) {
    my $series := Series;
    $series := cons($_<>, $series) for @values.reverse;
    $series;
}

sub stream(+values --> Stream) is export {
    my \iterator = values.iterator;
    my &flow = {
        my \value = iterator.pull-one;
        value =:= IterationEnd ?? Series !! cons(value<>, susp &flow, Lock.new)
    };
    susp &flow, Lock.new;
}

multi sub head(\n, Series \values --> Series) is export {
    values.head(n);
}

multi sub skip(\n, Series \values --> Series) is export {
    values.skip(n);
}

sub infix:<++>(Series \s, Series \t --> Stream:D) is export {
    susp { (my \node := s.()) ?? cons(node.head, node.skip ++ t) !! t.() };
}

=begin pod

=head1 NAME

PFDS - Purely functional data structures

=head1 DESCRIPTION

    unit module PFDS;

    role Series does Iterable {}

    class Series::Node does Series {}

    class Stream does Series {}

Module C<PFDS> provides one of the most fundamental purely functional data
types: immutable, potentially lazy B<linked lists>. Linked lists don't support
the efficient positional access that may be expected from Raku lists, hence
this library calls them C<Series>.

A proper series is represented by a C<Series::Node> that links an immutable
I<value>, the C<.head> of the series, to the series with the rest of the
values. The last node of a series is linked to the empty series, the only
C<Series> which evaluates to C<False> in Boolean context.

A lazily evaluated, potentially infinite series is called a C<Stream>. A stream
may be called explicitly to obtain a C<Series::Node> or the empty series.
Calling a method like C<.Bool>, C<.head> or C<.skip> implicitly reifies the
head of the stream.

=head1 EXPORTS

Module C<PFDS> exports the following subroutines by default.

=head2 sub series

Defined as:

    sub series(**@values --> Series)

Returns the decontainerized values as a C<Series>.

=head2 sub stream

    sub stream(+values --> Stream)

Returns the decontainerized values as a C<Stream>.

=head2 infix ++

    sub infix:<++>(Series \s, Series \t --> Stream:D)

Concatenates the two series into a stream containing the values of C<s>
followed by the values of C<t>.

=head2 sub head

    multi sub head(\n, Series \values --> Series)

Returns a lazy copy of the first C<n> values.

=head2 sub skip

    multi sub skip(\n, Series \values --> Series)

Returns the series without the first C<n> values.

=head1 METHODS

The following methods are implemented by all C<Series> types in the C<PFDS>
namespace.

=head2 method CALL-ME

    method CALL-ME(--> Series)

Returns the node at the head of the series, or the empty series if there is no
such node.

=head2 method head

    multi method head()
    multi method head(Int() \n --> Series)
    multi method head(int \n --> Series)

Returns the first value of the series (by default C<Nil>) if called without
argument. Otherwise returns the first C<n> values of the invocant as a stream,
or the empty series if C«n < 1».

=head2 method iterator

    method iterator(--> Iterator:D)

Returns an L<C<Iterator>|https://docs.raku.org/type/Iterator> over the values
of the series. Note that iterators are inherently mutable, so they're I<not
thread-safe>.

=head2 method list

    method list()

Returns a L<list|https://docs.raku.org/type/PositionalBindFailover#method_list>
based on the C<.iterator>. Note that such lazy lists are I<not thread-safe>.

=head2 method skip

    multi method skip(--> Series)
    multi method skip(Int() \n --> Series)

Returns the series that remains after discarding the first value or first C<n>
values of the series. Negative values of C<n> count as 0.

=end pod
