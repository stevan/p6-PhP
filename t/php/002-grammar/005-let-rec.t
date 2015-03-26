#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {

    my $unit = PhP::run( 
       q[
            let mul = func (x, y) { 
                if y == 1 
                    then x
                    else x + mul( x, y - 1 )
            } in
                mul(13, 2)
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 26, '... got the value we expected';
}, '... testing recursive multiply function';

subtest {

    my $unit = PhP::run( 
       q[
            let factorial = func (n) { 
                if n == 1 
                    then 1
                    else n * factorial( n - 1 )
            } in
                factorial( 5 )
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 120, '... got the value we expected';
}, '... testing recursive factorial function';

subtest {

    my $unit = PhP::run( 
       q[
            let 
                is_even = func (n) { if n == 0 then true  else is_odd( n - 1 )  },
                is_odd  = func (n) { if n == 0 then false else is_even( n - 1 ) },
             in
                is_even( 2 )
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    ok ?( $unit.result === PhP::Runtime::root_env.get('#TRUE') ), '... got the value we expected';
}, '... testing even/odd predicate';

subtest {

    my $unit = PhP::run( 
       q[
            let 
                is_even = func (n) { if n == 0 then true  else is_odd( n - 1 )  },
                is_odd  = func (n) { if n == 0 then false else is_even( n - 1 ) },
             in
                is_even( 5 )
            ;;
       ]
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    ok ?( $unit.result === PhP::Runtime::root_env.get('#FALSE') ), '... got the value we expected';
}, '... testing even/odd predicate (again)';

done;
