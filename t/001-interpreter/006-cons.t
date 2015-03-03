#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    # CODE:
    # let x = 1 :: NIL in 
    #     head(x)
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :name('x'),
            :value(
                PhP::AST::Apply.new(
                    :name('::'),
                    :args(
                        PhP::AST::Literal.new( :value( 1 ) ),
                        PhP::AST::Var.new( :name('#NIL') ),
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('head'),
                    :args( PhP::AST::Var.new( :name( 'x' ) ) )
                )
            )
        )
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 1, '... got the value we expected';
}, '... testing simple list w/ head function';

subtest {
    # CODE:
    # let x = 1 :: NIL in 
    #     head(x)
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :name('x'),
            :value(
                PhP::AST::Apply.new(
                    :name('::'),
                    :args(
                        PhP::AST::Literal.new( :value( 1 ) ),
                        PhP::AST::Var.new( :name('#NIL') ),
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('tail'),
                    :args( PhP::AST::Var.new( :name( 'x' ) ) )
                )
            )
        )
    );

    isa_ok $result, PhP::AST::ConsCell;
    isa_ok $result, PhP::AST::Ast;

    ok $( $result === PhP::Runtime::root_env.get('#NIL') ), '... got the value we expected';
}, '... testing simple list w/ tail function';

subtest {
    # CODE:
    # let x = 1 :: NIL in 
    #     is_nil(tail(x))
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :name('x'),
            :value(
                PhP::AST::Apply.new(
                    :name('::'),
                    :args(
                        PhP::AST::Literal.new( :value( 1 ) ),
                        PhP::AST::Var.new( :name('#NIL') ),
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('is_nil'),
                    :args(
                        PhP::AST::Apply.new(
                            :name('tail'),
                            :args( PhP::AST::Var.new( :name( 'x' ) ) )
                        )
                    )
                )
            )
        )
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    ok $( $result === PhP::Runtime::root_env.get('#TRUE') ), '... got the value we expected';
}, '... testing simple list w/ is_nil(tail()) function';

subtest {
    # CODE:
    # let x = 1 :: 2 :: 3 :: NIL in 
    #     head(tail(x))
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :name('x'),
            :value(
                PhP::AST::Apply.new(
                    :name('::'),
                    :args(
                        PhP::AST::Literal.new( :value( 1 ) ),
                        PhP::AST::Apply.new(
                            :name('::'),
                            :args(
                                PhP::AST::Literal.new( :value( 2 ) ),
                                PhP::AST::Apply.new(
                                    :name('::'),
                                    :args(
                                        PhP::AST::Literal.new( :value( 3 ) ),
                                        PhP::AST::Var.new( :name('#NIL') ),
                                    )
                                )
                            )
                        )
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('head'),
                    :args( 
                       PhP::AST::Apply.new(
                            :name('tail'),
                            :args( PhP::AST::Var.new( :name( 'x' ) ) )
                        )
                    )
                )
            )
        )
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 2, '... got the value we expected';
}, '... testing longer list w/ head(tail()) function';


done;
