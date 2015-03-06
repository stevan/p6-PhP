#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    # CODE:
    # let add = func (x, y) { x + y } in
    #     add( 10, 10 )
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( 
                add => PhP::AST::Func.new(
                    :params( 'x', 'y' ),
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
            :body(
                PhP::AST::Apply.new(
                    :name('add'),
                    :args(
                        PhP::AST::Literal.new( :value( 10 ) ), 
                        PhP::AST::Literal.new( :value( 10 ) ), 
                    )
                )
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 20, '... got the value we expected';
}, '... testing simple function';


subtest {
    # CODE:
    # let add  = func (x, y) { x + y },
    #     add2 = func (x)    { add( x, 2 ) } in
    #     add2( 10 )
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( 
                add => PhP::AST::Func.new(
                    :params( 'x', 'y' ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('+'),
                            :args(
                                PhP::AST::Var.new( :name('x') ), 
                                PhP::AST::Var.new( :name('y') ), 
                            )
                        )
                    )
                ),
                add2 => PhP::AST::Func.new(
                    :params( 'x' ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('add'),
                            :args(
                                PhP::AST::Var.new( :name('x') ), 
                                PhP::AST::Literal.new( :value( 2 ) ), 
                            )
                        )
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('add2'),
                    :args(
                        PhP::AST::Literal.new( :value( 10 ) ), 
                    )
                )
            )
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 12, '... got the value we expected';
}, '... testing nested let function definitions';


subtest {
    # CODE:
    # let add = func (x, y) { x + y },
    #     sub = func (x, y) { x - y },
    #     mul = func (x, y) { x * y } in
    #     add( 10, mul( 10, sub( 10 - 5 ) ) )
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions(
                add => PhP::AST::Func.new(
                    :params( 'x', 'y' ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('+'),
                            :args(
                                PhP::AST::Var.new( :name('x') ), 
                                PhP::AST::Var.new( :name('y') ), 
                            )
                        )
                    )
                ),
                sub => PhP::AST::Func.new(
                    :params( 'x', 'y' ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('-'),
                            :args(
                                PhP::AST::Var.new( :name('x') ), 
                                PhP::AST::Var.new( :name('y') ), 
                            )
                        )
                    )
                ),
                mul => PhP::AST::Func.new(
                    :params( 'x', 'y' ),
                    :body(
                        PhP::AST::Apply.new(
                            :name('*'),
                            :args(
                                PhP::AST::Var.new( :name('x') ), 
                                PhP::AST::Var.new( :name('y') ), 
                            )
                        )
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name('add'),
                    :args(
                        PhP::AST::Literal.new( :value(10) ),
                        PhP::AST::Apply.new(
                            :name('mul'),
                            :args(
                                PhP::AST::Literal.new( :value(10) ),
                                PhP::AST::Apply.new(
                                    :name('sub'),
                                    :args(
                                        PhP::AST::Literal.new( :value(10) ),
                                        PhP::AST::Literal.new( :value(5) ),
                                    )
                                )
                            )
                        ) 
                    )
                )
            ) 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 60, '... got the value we expected';
}, '... testing nested let function definitions';

done;
