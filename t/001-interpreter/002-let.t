#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    # CODE:
    # let x = 10 in x ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
            :body( PhP::AST::Var.new( :name('x') ) ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 10, '... got the value we expected';
}, '... testing simple let';

subtest {
    # CODE:
    # let x = 2 + 2 in x ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( 
                x => PhP::AST::Apply.new(
                    :name('+'),
                    :args(
                        PhP::AST::Literal.new( :value(2) ), 
                        PhP::AST::Literal.new( :value(2) ),
                    )
                )
            ),
            :body( PhP::AST::Var.new( :name('x') ) ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 4, '... got the value we expected';
}, '... testing let with an expression as a value';

subtest {
    # CODE:
    # let x = 5, y = 5 in 
    #     x + y
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( 
                x => PhP::AST::Literal.new( :value(5) ),
                y => PhP::AST::Literal.new( :value(5) ) 
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('+'),
                    :args(
                        PhP::AST::Var.new( :name('x') ), 
                        PhP::AST::Var.new( :name('y') ),
                    )
                )
            )
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 10, '... got the value we expected';
}, '... testing nested let statements';

done;
