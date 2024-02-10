use v6.d;

# To be defined later:
my &cons; # protected Node constructor
my &susp; # protected Stream constructor

role PFDS::Series {
    # If forced, return the type object representing the empty series
    method CALL-ME() { PFDS::Series }

    # Properties of the empty series
    multi method head() {}
    multi method skip() { PFDS::Series }
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
    &susp = sub (&series) {
        my $state = &series;
        ::?CLASS.CREATE!SET-SELF({
            my \seen = cas $state, &series, my \new = series;
            seen === &series ?? new !! seen;
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
    susp { (my \n := s.()) ?? cons(n.head, n.skip ++ t) !! t.() };
}

=begin pod

=head1 NAME

PFDS::Series - Purely functional linked lists

=head1 DESCRIPTION

    role PFDS::Series {}

The B<series> provided by C<PFDS::Series> are purely functional B<linked lists>.
A proper series is a recursive data structure that links an immutable I<value>,
the C<.head> of the series, to another series with the remaining values. The
last value of the series is linked to the empty series, which is the only series
that evaluates to C<False> in Boolean context.

A series may be lazily evaluated, in which case it's called a B<stream>. Calling
C<.Bool>, C<.head> or C<.skip> on a stream reifies its head. Calling C<.skip> on
a stream may return another stream or a regular series.

=head1 EXPORTS

=head2 sub series

Defined as:

    sub series(**@values is raw)

Constructs a series of decontainerized C<@values>.

=head2 infix ++

    sub infix:<++>(PFDS::Series \s, PFDS::Series \t)

Concatenates the two series into a stream containing the values of C<s> followed
by the values of C<t>.

=head1 METHODS

=head2 method head

    multi method head()

Returns the first value of the series, or C<Nil> if the series is empty.

=head2 method skip

    multi method skip()

Returns the series that remains after discarding the first value of the series.

=end pod
