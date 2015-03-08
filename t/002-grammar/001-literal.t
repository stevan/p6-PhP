#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    my $result = PhP::run(q[1]);

    isa_ok $result, PhP::AST::Ast;
    isa_ok $result, PhP::AST::Literal;

    is $result.value, 1, '... got the expected value';
}, '... testing simple Int values';

subtest {
    my $result = PhP::run(q["Foo"]);

    isa_ok $result, PhP::AST::Ast;
    isa_ok $result, PhP::AST::Literal;

    is $result.value, '"Foo"', '... got the expected value';
}, '... testing simple Str values';

done;

