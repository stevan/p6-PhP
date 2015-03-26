#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {

    my $unit = PhP::run( 
       q[
            let x = 1 :: [] in 
               head(x)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 1, '... got the value we expected';
}, '... testing simple list w/ head function';

subtest {

    my $unit = PhP::run( 
       q[
            let x = 1 :: [] in 
                tail(x)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Tuple;
    isa_ok $unit.result, PhP::AST::Ast;

    ok $unit.result.is_empty, '... got the value we expected';
}, '... testing simple list w/ tail function';

subtest {

    my $unit = PhP::run( 
       q[
            let x = 1 :: [] in 
                is_nil(tail(x))
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    ok $( $unit.result === PhP::Runtime::root_env.get('#TRUE') ), '... got the value we expected';
}, '... testing simple list w/ is_nil(tail()) function';

subtest {

    my $unit = PhP::run( 
       q[
            let x = 1 :: 2 :: 3 :: [] in 
                head(tail(x))
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing longer list w/ head(tail()) function';

subtest {

    my $unit = PhP::run( 
       q[
            let z = 3 :: []
                y = 2 :: z
                x = 1 :: y
            in
                head(tail(x))
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing nested list w/ head(tail()) function';

subtest {

    my $unit = PhP::run( 
       q[
            let x   = 1 :: 2 :: 3 :: [] 
                len = func (x) {
                    if is_nil(tail(x)) 
                        then 1
                        else 1 + len(tail(x))
                }
            in 
                len(x)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 3, '... got the value we expected';
}, '... testing recursive len function on list';


done;
