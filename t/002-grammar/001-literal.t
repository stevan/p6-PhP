#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    my $unit = PhP::run(q[1]);

    isa_ok $unit.result, PhP::AST::Ast;
    isa_ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 1, '... got the expected value';
}, '... testing simple Int values';

subtest {
    my $unit = PhP::run(q["Foo"]);

    isa_ok $unit.result, PhP::AST::Ast;
    isa_ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, '"Foo"', '... got the expected value';
}, '... testing simple Str values';

done;

