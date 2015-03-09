#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    # CODE:
    # 2

    my $result = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new( 
            :root( PhP::AST::Literal.new( :value( 2 ) ) )
        )
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 2, '... got the value we expected';
}, '... testing simple literals';

done;
