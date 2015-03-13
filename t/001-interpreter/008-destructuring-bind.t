#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # let [ h, t ] = [ 1, 2 ] in 
    #     h + t
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::DestructuringBind.new(
                            :pattern( 
                                PhP::AST::Var.new( :name('h') ),
                                PhP::AST::Var.new( :name('t') ), 
                            ),
                            :value(
                                PhP::AST::Tuple.new(
                                    :items(
                                        PhP::AST::Literal.new( :value( 1 ) ),
                                        PhP::AST::Literal.new( :value( 2 ) )
                                    )
                                )
                            )
                        )
                    ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('+'),
                            :args( 
                                PhP::AST::Var.new( :name( 'h' ) ),
                                PhP::AST::Var.new( :name( 't' ) ),
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
}, '... testing simple tuple with two captures';

subtest {
    # CODE:
    # let [ a, b, c, d ] = [ 1, 2, 3, 4 ] in 
    #     a + b + c + d
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::DestructuringBind.new(
                            :pattern( 
                                PhP::AST::Var.new( :name('a') ),
                                PhP::AST::Var.new( :name('b') ), 
                                PhP::AST::Var.new( :name('c') ), 
                                PhP::AST::Var.new( :name('d') ), 
                            ),
                            :value(
                                PhP::AST::Tuple.new(
                                    :items(
                                        PhP::AST::Literal.new( :value( 1 ) ),
                                        PhP::AST::Literal.new( :value( 2 ) ),
                                        PhP::AST::Literal.new( :value( 3 ) ),
                                        PhP::AST::Literal.new( :value( 4 ) ),
                                    )
                                )
                            )
                        )
                    ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('+'),
                            :args( 
                                PhP::AST::Var.new( :name( 'a' ) ),
                                PhP::AST::Apply.new(
                                    :name('+'),
                                    :args( 
                                        PhP::AST::Var.new( :name( 'b' ) ),
                                        PhP::AST::Apply.new(
                                            :name('+'),
                                            :args( 
                                                PhP::AST::Var.new( :name( 'c' ) ),
                                                PhP::AST::Var.new( :name( 'd' ) ),
                                            )
                                        )
                                    )
                                )
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
}, '... testing simple tuple with 4 captures';


subtest {
    # CODE:
    # let [ a, b, c* ] = [ 1, 2, 3, 4 ] in 
    #     a + b + first(c) + second(d)
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::DestructuringBind.new(
                            :is_slurpy(True),                            
                            :pattern( 
                                PhP::AST::Var.new( :name('a') ),
                                PhP::AST::Var.new( :name('b') ), 
                                PhP::AST::Var.new( :name('c') ),  
                            ),
                            :value(
                                PhP::AST::Tuple.new(
                                    :items(
                                        PhP::AST::Literal.new( :value( 1 ) ),
                                        PhP::AST::Literal.new( :value( 2 ) ),
                                        PhP::AST::Literal.new( :value( 3 ) ),
                                        PhP::AST::Literal.new( :value( 4 ) ),
                                    )
                                )
                            )
                        )
                    ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('+'),
                            :args( 
                                PhP::AST::Var.new( :name( 'a' ) ),
                                PhP::AST::Apply.new(
                                    :name('+'),
                                    :args( 
                                        PhP::AST::Var.new( :name( 'b' ) ),
                                        PhP::AST::Apply.new(
                                            :name('+'),
                                            :args( 
                                                PhP::AST::Apply.new(
                                                    :name('first'),
                                                    :args( PhP::AST::Var.new( :name( 'c' ) ) )
                                                ),
                                                PhP::AST::Apply.new(
                                                    :name('second'),
                                                    :args( PhP::AST::Var.new( :name( 'c' ) ) )
                                                ),
                                            )
                                        )
                                    )
                                )
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
}, '... testing simple tuple with 4 captures';


done;
