#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # let x = [ 1 ] in 
    #     first(x)
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :definitions(
                        x => PhP::AST::Tuple.new(
                            :items(
                                PhP::AST::Literal.new( :value( 1 ) )
                            )
                        )
                    ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('first'),
                            :args( PhP::AST::Var.new( :name( 'x' ) ) )
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

    is $unit.result.value, 1, '... got the value we expected';
}, '... testing simple tuple';

subtest {
    # CODE:
    # let x = [ 1, 2, 3 ] in 
    #     second(x)
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :definitions(
                        x => PhP::AST::Tuple.new(
                            :items(
                                PhP::AST::Literal.new( :value( 1 ) ),
                                PhP::AST::Literal.new( :value( 2 ) ),
                                PhP::AST::Literal.new( :value( 3 ) )
                            )
                        )
                    ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('second'),
                            :args( PhP::AST::Var.new( :name( 'x' ) ) )
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

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing simple tuple';

subtest {
    # CODE:
    # let x = [ 1, 2, 3 ] in 
    #     item_at(x, 2)
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :definitions(
                        x => PhP::AST::Tuple.new(
                            :items(
                                PhP::AST::Literal.new( :value( 1 ) ),
                                PhP::AST::Literal.new( :value( 2 ) ),
                                PhP::AST::Literal.new( :value( 3 ) )
                            )
                        )
                    ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('item_at'),
                            :args( 
                                PhP::AST::Var.new( :name( 'x' ) ),
                                PhP::AST::Literal.new( :value( 2 ) ) 
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

    is $unit.result.value, 3, '... got the value we expected';
}, '... testing simple tuple';

done;
