use v6.d;

# To be defined later:
my &cons; # protected series node constructor

role PFDS::Series {
    # Properties of the type object representing the empty series
    multi method head() {}
    multi method skip() { PFDS::Series }

    # Create series from argument list
    proto series(|) is export {*}
    multi series() { PFDS::Series }
    multi series(Mu \item) {
        cons(item<>, PFDS::Series);
    }
    multi series(Slip \items) {
        from-list(items);
    }
    multi series(**@items is raw) {
        from-list(@items);
    }
    sub from-list(@items) {
        my $series := PFDS::Series;
        $series := cons($_<>, $series) for @items.reverse;
        $series;
    }
}

my class PFDS::Series::Node does PFDS::Series {
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

    # Properties of a series node
    multi method head() { $!value }
    multi method skip() { $!next  }
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

=head1 EXPORTS

=head2 sub series

Defined as:

    sub series(**@values is raw)

Returns a C<PFDS::Series> that links the decontainerized C<@values>.

=head1 METHODS

=head2 method head

    multi method head()

Returns the first value of the series, or C<Nil> if the series is empty.

=head2 method skip

    multi method skip()

Returns the series that remains after discarding the first value of the series.

=end pod
