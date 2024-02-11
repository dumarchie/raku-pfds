use v6.d;
use Test;

use lib 'lib';
use PFDS::Series;

subtest 'series', {
    subtest 'empty series', {
        $_ := series;
        isa-ok $_, PFDS::Series, 'series() returns a PFDS::Series';
        cmp-ok .Bool, '=:=', False, '.Bool returns False';
        cmp-ok .head, '=:=', Nil, '.head returns Nil';
        cmp-ok .list, 'eqv', (), '.list returns no values';
        cmp-ok .skip, '=:=', $_, '.skip returns the invocant';
    }

    subtest 'series($item)', {
        my \value = Mu.new;
        my $item  = value;
        $_ := series($item);
        isa-ok $_, PFDS::Series, 'series($item) returns a PFDS::Series';
        cmp-ok .Bool, '=:=', True, '.Bool returns True';

        $item = Mu.new; # to check that the .head is bound to the bare value
        cmp-ok .head, '=:=', value,
          '.head returns the value stored in $item when series($item) was called';

        cmp-ok .skip, 'eqv', series, '.skip returns the empty series';
    }

    subtest 'series(1, 2)', {
        $_ := series(1, 2);
        isa-ok $_, PFDS::Series, 'series(1, 2) returns a PFDS::Series';
        cmp-ok .head, '=:=', 1, '.head returns the value 1';
        cmp-ok .list, 'eqv', (1, 2), '.list returns values 1, 2';
        cmp-ok .skip, 'eqv', series(2), '.skip returns series(2)';
    }

    # Check that a Slip slips
    cmp-ok series(Empty), 'eqv', series, 'series(Empty) returns the empty series';
}

subtest 'infix ++', {
    my \t = series(2, 3);
    $_ := series(1) ++ t;
    isa-ok $_, PFDS::Series, "series(1) ++ t returns a PFDS::Series";
    cmp-ok .Bool, '=:=', True, '.Bool returns True';
    cmp-ok .head, '=:=', 1, '.head returns the value 1';
    cmp-ok .list, 'eqv', (1, 2, 3), '.list returns values 1, 2, 3';
    cmp-ok .skip, 'eqv', series() ++ t, '.skip returns a suspended t';
}

done-testing;
