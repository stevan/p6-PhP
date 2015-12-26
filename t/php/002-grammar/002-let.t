#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    my $unit = PhP::run(q[let x = 10 in () ;;]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Unit;

}, '... testing unit return';

subtest {
    my $unit = PhP::run(q[let x = 10 in 10 ;;]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 10, '... got the expected value';
}, '... testing simple values';

subtest {
    my $unit = PhP::run(q[let x = 2 + 2 in x ;;]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 4, '... got the expected value';
}, '... testing simple expression';

subtest {
    my $unit = PhP::run(q[let x = 2 + 2 in x + 2 ;;]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 6, '... got the expected value';
}, '... testing simple expression in body too';

subtest {
    my $unit = PhP::run(q[
        let x = 2,
            y = 5,
            z = 3
        in
            x + y + z
        ;;
    ]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 10, '... got the expected value';
}, '... multiple variables in expressions';

subtest {
    my $unit = PhP::run(q[
        let x = 2,
            y = x + 5,
            z = 1 + x
        in
            y + z
        ;;
    ]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 10, '... got the expected value';
}, '... multiple variables with complex expressions';

subtest {
    my $unit = PhP::run(q[
        let x = 2 in
        let y = 5 in
        let z = 3 in
            x + y + z
        ;;
    ]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 10, '... got the expected value';
}, '... multiple variables in nested let expressions';

subtest {
    my $unit = PhP::run(q[
        let x = 2     in
        let y = x + 5 in
        let z = 1 + x in
            y + z
        ;;
    ]);

    isa-ok $unit.result, PhP::AST::Ast;
    isa-ok $unit.result, PhP::AST::Literal;

    is $unit.result.value, 10, '... got the expected value';
}, '... multiple variables with complex nested let expressions';


done-testing;

