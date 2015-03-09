#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # let x = 10 in x ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
                    :body( PhP::AST::Var.new( :name('x') ) ), 
                )
            ),
            :env( 
                PhP::Runtime::Env.new( 
                    :parent( PhP::Runtime::root_env ) 
                ) 
            )
        ) 
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';
}, '... testing simple let';

subtest {
    # CODE:
    # let x = 2 + 2 in x ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
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
            ),
            :env( 
                PhP::Runtime::Env.new( 
                    :parent( PhP::Runtime::root_env ) 
                ) 
            )
        )
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 4, '... got the value we expected';
}, '... testing let with an expression as a value';

subtest {
    # CODE:
    # let x = 5, y = 5 in 
    #     x + y
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
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
            ),
            :env( 
                PhP::Runtime::Env.new( 
                    :parent( PhP::Runtime::root_env ) 
                ) 
            )
        ) 
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';
}, '... testing nested let statements';

done;
