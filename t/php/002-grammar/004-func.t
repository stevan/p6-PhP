#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {

    my $unit = PhP::run(
       q[
            let ten = func () { 10 } in
                ten()
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';
}, '... testing very simple func';

subtest {

    my $unit = PhP::run(
       q[
            let add = func (x, y) { x + y } in
                add( 10, 10 )
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple func';

subtest {

    my $unit = PhP::run(
       q[
            let add  = func (x, y) { x + y },
                add2 = func (x)    { add( x, 2 ) } in
                add2( 10 )
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 12, '... got the value we expected';
}, '... testing multiple func definitions';

subtest {

    my $unit = PhP::run(
       q[
            let add = func (x, y) { x + y },
                sub = func (x, y) { x - y },
                mul = func (x, y) { x * y },
            in
                add( 10, mul( 10, sub( 10, 5 ) ) )
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 60, '... got the value we expected';
}, '... testing more multiple func definitions';

subtest {

    my $unit = PhP::run(
       q[
            let x   = 10,
                add = func (y) { x + y } in
                add( 10 )
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple closure';

subtest {

    my $unit = PhP::run(
       q[
            let x = 10 in
                let add = func (y) { x + y } in
                   add( 10 )
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple closure (with nested env)';

subtest {

    my $unit = PhP::run(
       q[
            let add   = func (x, y) { x + y }
                binop = func (f, x, y) { f(x, y) }
            in
                binop( add, 10, 10 )
            ;;
       ]
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing first class functions';

done-testing;
