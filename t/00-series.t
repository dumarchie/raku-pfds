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

    subtest 'series($item, 2)', {
        my \value = Mu.new;
        my $item  = value;
        $_ := series($item, 2);
        isa-ok $_, PFDS::Series, 'series($item, 2) returns a PFDS::Series';

        $item = Mu.new; # to check that the .head is bound to the bare value
        cmp-ok .head, '=:=', value,
          '.head returns the value stored in $item when series($item) was called';

        subtest '.skip', {
            isa-ok $_, PFDS::Series, 'the result is a PFDS::Series';
            cmp-ok .head, '=:=', 2, '.head returns value 2';
            cmp-ok .skip, '=:=', PFDS::Series, '.skip returns the empty series';
        } given .skip;
    }

    # Check that a Slip slips
    cmp-ok series(Empty), 'eqv', series, 'series(Empty) returns the empty series';
}

subtest 'infix ++', {
    subtest 'series(1) ++ series()', {
        $_ := series(1) ++ series();
        isa-ok $_, PFDS::Series, 'series(1) ++ series() returns a PFDS::Series';
        cmp-ok .Bool, '=:=', True, '.Bool returns True';
        cmp-ok .head, '=:=', 1, '.head returns value 1';
        subtest '.skip', {
            isa-ok $_, PFDS::Series, 'the result is a PFDS::Series';
            cmp-ok .Bool, '=:=', False, '.Bool returns False';
            cmp-ok .head, '=:=', Nil, '.head returns Nil';
            cmp-ok .skip, '=:=', series(), '.skip returns series()';
        } given .skip;
    }

    subtest 'series(1) ++ series(2, 3)', {
        $_ := series(1) ++ series(2, 3);
        isa-ok $_, PFDS::Series, 'series(1) ++ series(2, 3) returns a PFDS::Series';
        subtest '.skip', {
            isa-ok $_, PFDS::Series, 'the result is a PFDS::Series';
            cmp-ok .(), 'eqv', series(2, 3),
              '.() returns the equivalent of series(2, 3)';
        } given .skip;
    }
}

done-testing;
