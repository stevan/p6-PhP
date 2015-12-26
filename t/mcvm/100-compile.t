#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;
use MCVM;
use MCVM::Utils;

plan *;

subtest {
    my $unit = PhP::compile(q[1]);

    diag "AST:";
    diag ~ $unit.root;
    diag "PROGRAM:";
    MCVM::Utils::pprint( $unit.result.instructions, &diag );

    my $process = $unit.run;
    isa-ok($process, MCVM::Machine::Process);
    is($process.data[*-1], 1, '... found the right value on the top of the stack');

}, '... testing simple Int values';

subtest {
    my $unit = PhP::compile(q[1 + 1]);

    diag "AST:";
    diag ~ $unit.root;
    diag "PROGRAM:";
    MCVM::Utils::pprint( $unit.result.instructions, &diag );

    my $process = $unit.run;
    isa-ok($process, MCVM::Machine::Process);
    is($process.data[*-1], 2, '... found the right value on the top of the stack');

}, '... testing simple addition';

subtest {
    my $unit = PhP::compile(q[(1 + 2) - (3 * 3)]);

    diag "AST:";
    diag ~ $unit.root;
    diag "PROGRAM:";
    MCVM::Utils::pprint( $unit.result.instructions, &diag );

    my $process = $unit.run;
    isa-ok($process, MCVM::Machine::Process);
    is($process.data[*-1], 6, '... found the right value on the top of the stack');

}, '... testing simple addition';

done-testing;
