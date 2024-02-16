use v6.d;

# To be defined later:
my &cons; # protected Node constructor
my &susp; # protected Stream constructor

role PFDS::Series does Iterable {
    # If forced, return the type object representing the empty series
    method CALL-ME() { PFDS::Series }

    # Destructuring
    multi method head() {}

    multi method skip() { PFDS::Series }
    multi method skip(Int() \n) {
        my $series := self;
        my int $n = n;
        while $n-- > 0 {
            my \node = $series() or last;
            $series := node.skip;
        }
        $series;
    }

    # Iterable methods
    method iterator() {
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
}

my class Node does PFDS::Series {
    has $.value;
    has PFDS::Series $.next;
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
    method CALL-ME() { self }

    # Properties of a node
    multi method head() { $!value }
    multi method skip() { $!next  }
}

my class Stream does PFDS::Series {
    has $!state;
    method !SET-SELF($!state) { self }

    # Protected constructor
    my \todo = Mu.new;
    &susp = sub (&series) {
        my $state = todo;
        ::?CLASS.CREATE!SET-SELF({
            my \seen = cas $state, todo, my \new = series;
            seen =:= todo ?? new !! seen;
        });
    }

    # To force evaluation
    method CALL-ME() {
        $!state.VAR =:= $!state ?? $!state !! ($!state := $!state());
    }

    # Properties of a stream
    multi method Bool() { self.().Bool }
    multi method head() { self.().head }
    multi method skip() { self.().skip }
}

# Exports
proto series(|) is export {*}
multi series() { PFDS::Series }
multi series(Mu \item) {
    cons(item<>, PFDS::Series);
}
multi series(Slip \values) {
    link(values);
}
multi series(**@values is raw) {
    link(@values);
}
sub link(@values) {
    my $series := PFDS::Series;
    $series := cons($_<>, $series) for @values.reverse;
    $series;
}

sub infix:<++>(PFDS::Series \s, PFDS::Series \t) is export {
    susp { (my \node := s.()) ?? cons(node.head, node.skip ++ t) !! t.() };
}

=begin pod

=head1 NAME

PFDS::Series - Purely functional, potentially lazy linked lists

=head1 DESCRIPTION

    role PFDS::Series does Iterable {}

C<PFDS::Series> provides B<series>, strongly immutable B<linked lists> that
may be lazily evaluated. A proper series is a recursive data structure that
links an immutable I<value>, the C<.head> of the series, to a series with the
rest of the values. The last value of a series is linked to the empty series,
the only series that evaluates to C<False> in Boolean context.

Lazily evaluated series are called B<streams>. The head of a stream is reified
by calling C<.Bool>, C<.head> or C<.skip>. Calling C<.skip> on a stream may
return another stream or a regular series.

=head1 EXPORTS

=head2 sub series

Defined as:

    sub series(**@values is raw)

Constructs a series of decontainerized C<@values>.

=head2 infix ++

    sub infix:<++>(PFDS::Series \s, PFDS::Series \t)

Concatenates the two series into a stream containing the values of C<s>
followed by the values of C<t>.

=head1 METHODS

=head2 method head

    multi method head()

Returns the first value of the series, or C<Nil> if the series is empty.

=head2 method iterator

    method iterator()

Returns an L<C<Iterator>|https://docs.raku.org/type/Iterator> over the values
of the series.

=head2 method list

    method list()

Returns the values of the series as a lazy list based on the
L<C<.iterator>|#method_iterator>.

=head2 method skip

    multi method skip()
    multi method skip(Int() \n)

Returns the series that remains after discarding the first value or first C<n>
values of the series. Negative values of C<n> count as 0.

=end pod
