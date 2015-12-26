#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    my $unit = PhP::run(q[1]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 1, '... got the expected value';
}, '... testing simple Int values';

subtest {
    my $unit = PhP::run(q["Foo"]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, '"Foo"', '... got the expected value';
}, '... testing simple Str values';

subtest {
    my $unit = PhP::run(q[1 + 1]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 2, '... got the expected value';
}, '... testing simple addition';

subtest {
    my $unit = PhP::run(q[1 + 2 + 3]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 6, '... got the expected value';
}, '... testing more addition';

subtest {
    my $unit = PhP::run(q[1 + 2 - 3]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 0, '... got the expected value';
}, '... testing other operators';

subtest {
    my $unit = PhP::run(q[4 + (2 - 3)]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 3, '... got the expected value';
}, '... testing parens to enforce precendence';

subtest {
    my $unit = PhP::run(q[(4 + 2) - 5]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 1, '... got the expected value';
}, '... testing parens to enforce precendence (even on the lhs of the expression)';

subtest {
    my $unit = PhP::run(q[(4 + 2) - (5 * 3)]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, -9, '... got the expected value';
}, '... testing parens to enforce precendence (even on the lhs and the rhs of the expression)';

done-testing;

