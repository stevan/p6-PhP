#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {

    my $result = PhP::run( 
       q[
            let x = 10 in
                if x == 10 
                    then "YES"
                    else "NO"
            ;;
       ] 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, '"YES"', '... got the value we expected';
}, '... testing ==';

subtest {

    my $result = PhP::run( 
       q[
            let x = 10 in
                if x != 10 
                    then "YES"
                    else "NO"
            ;;
       ] 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, '"NO"', '... got the value we expected';
}, '... testing !=';

subtest {

    my $result = PhP::run( 
         q[
            let x = 10 in
                if x < 100 
                    then "YES"
                    else "NO"
            ;;
         ]
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, '"YES"', '... got the value we expected';
}, '... testing <';

subtest {

    my $result = PhP::run( 
         q[
            let x = 10 in
                if x <= 100 
                    then "YES"
                    else "NO"
            ;;
         ]
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, '"YES"', '... got the value we expected';
}, '... testing <=';

subtest {

    my $result = PhP::run( 
         q[
            let x = 10 in
                if x > 100 
                    then "YES"
                    else "NO"
            ;;
         ]
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, '"NO"', '... got the value we expected';
}, '... testing >';

subtest {

    my $result = PhP::run( 
         q[
            let x = 10 in
                if x >= 100 
                    then "YES"
                    else "NO"
            ;;
         ]
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, '"NO"', '... got the value we expected';
}, '... testing >=';


subtest {

    my $result = PhP::run( 
         q[
            let x = 10,
                y = if x == 10 then 2 else 4,
                z = if y == 2  then 5 else 10
            in
                x + y + z
            ;;
         ]
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 17, '... got the value we expected';
}, '... testing cond inside let assignment';

subtest {

    my $result = PhP::run( 
         q[
            let x = 11,
                y = if x == 10 then 2 else 4,
                z = if y == 2  then 5 else 10
            in
                x + y + z
            ;;
         ]
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 25, '... got the value we expected';
}, '... testing cond inside let assignment (part deux)';


done;
