#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {

    my $unit = PhP::run( 
       q[
            let [ h, t ] = [ 1, 2 ] in 
                h + t
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 3, '... got the value we expected';
}, '... testing simple tuple with two captures';

subtest {

    my $unit = PhP::run( 
       q[
            let [ a, b, c, d ] = [ 1, 2, 3, 4 ] in
                a + b + c + d
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';
}, '... testing simple tuple with 4 captures';


subtest {

    my $unit = PhP::run( 
       q[
            let [ a, b, c* ] = [ 1, 2, 3, 4 ] in 
                a + b + first(c) + second(c)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';
}, '... testing simple tuple with 4 captures';


done;
