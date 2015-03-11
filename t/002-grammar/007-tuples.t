#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {

    my $unit = PhP::run( 
       q[
            let x = [ 1 ] in 
                first(x)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 1, '... got the value we expected';
}, '... testing simple tuple';

subtest {

    my $unit = PhP::run( 
       q[
            let x = [ 1, 2, 3 ] in 
                second(x)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing simple tuple';

subtest {

    my $unit = PhP::run( 
       q[
            let x = [ 1, 2, 3 ] in 
                item_at(x, 2)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 3, '... got the value we expected';
}, '... testing simple tuple';

done;
