use v6.d;
use Test;

unit module Test::Queue;
sub queue-ok($name, int $extra?) is export {
    plan 3 + $extra;
    require ::($name);
    my \Queue = ::($name);

    my $empty;
    subtest "$name.new", {
        $empty := Queue.new;
        isa-ok $empty, Queue, "$name.new returns a $name object";
        cmp-ok $empty.Bool, '=:=', False,  '.Bool returns False';
        cmp-ok $empty.head, '=:=', Nil,    '.head returns Nil';
        cmp-ok $empty.skip, 'eqv', $empty, '.skip returns an empty queue';
        throws-like { $empty.Capture }, X::Cannot::Capture, what => $empty,
          '.Capture throws';
    }

    my $queue = Queue;
    my $item  = my \value = Mu.new;
    subtest $name ~ '.enqueue($item)', {
        $queue .= enqueue($item);
        isa-ok $queue, Queue, "the result is a $name object";

        $item = 42;
        cmp-ok $queue.Bool, '=:=', True, '.Bool returns True';
        cmp-ok $queue.head, '=:=', value,
          '.head returns the decontainerized $item';

        cmp-ok $queue.skip, 'eqv', $empty, '.skip returns an empty queue';
    }

    subtest '$queue.enqueue($item)', {
        $queue .= enqueue($item);
        isa-ok $queue, Queue, "the result is a $name object";
        is $queue.elems, 2, '.elems returns the number of queued items';

        cmp-ok $queue.head, '=:=', value,
          '.head returns the value of the item that was enqueued first';

        cmp-ok $queue.skip, 'eqv', Queue.enqueue(42),
          '.skip returns a queue with the remaining item';

        subtest '.Capture', {
            isa-ok $queue.Capture, Capture, 'the result is a Capture';

            my (\item, \rest) := $queue;
            cmp-ok item, '=:=', $queue.head, 'the first value is .head';
            cmp-ok rest, 'eqv', $queue.skip, 'the other value equals .skip';
        };
    }
}
