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

    my @program = $unit.bytecode;
    diag "PROGRAM:";
    MCVM::Utils::pprint( @program, &diag );

    my $process = MCVM::run( @program, { DEBUG => %*ENV<DEBUG> } );
    isa_ok($process, MCVM::Machine::Process);
    is($process.data[*-1], 1, '... found the right value on the top of the stack');

}, '... testing simple Int values';

subtest {
    my $unit = PhP::compile(q[1 + 1]);
    diag "AST:";
    diag ~ $unit.root;

    my @program = $unit.bytecode;
    diag "PROGRAM:";
    MCVM::Utils::pprint( @program, &diag );

    my $process = MCVM::run( @program, { DEBUG => %*ENV<DEBUG> } );
    isa_ok($process, MCVM::Machine::Process);
    is($process.data[*-1], 2, '... found the right value on the top of the stack');

}, '... testing simple Int values';

done;
