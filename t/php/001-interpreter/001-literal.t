#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # 2

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Literal.new( value => 2 )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing simple literals';

done-testing;
