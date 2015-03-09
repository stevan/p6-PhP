#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # let add = func (x, y) { x + y } in
    #     add( 10, 10 )
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
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

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple function';


subtest {
    # CODE:
    # let add  = func (x, y) { x + y },
    #     add2 = func (x)    { add( x, 2 ) } in
    #     add2( 10 )
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
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

    is $unit.result.value, 12, '... got the value we expected';
}, '... testing nested let function definitions';


subtest {
    # CODE:
    # let add = func (x, y) { x + y },
    #     sub = func (x, y) { x - y },
    #     mul = func (x, y) { x * y } in
    #     add( 10, mul( 10, sub( 10 - 5 ) ) )
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
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

    is $unit.result.value, 60, '... got the value we expected';
}, '... testing nested let function definitions';


subtest {
    # CODE:
    # let x   = 10,
    #     add = func (y) { x + y } in
    #     add( 10 )
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :definitions( 
                        x   => PhP::AST::Literal.new( :value( 10 ) ),
                        add => PhP::AST::Func.new(
                            :params( 'y' ),
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
                                PhP::AST::Literal.new( :value( 10 ) )
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

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple closure';

subtest {
    # CODE:
    # let x = 10 in
    #     let add = func (y) { x + y } in
    #        add( 10 )
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :definitions( 
                        x => PhP::AST::Literal.new( :value( 10 ) ),
                    ),
                    :body(
                        PhP::AST::Let.new(
                            :definitions( 
                                add => PhP::AST::Func.new(
                                    :params( 'y' ),
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
                                        PhP::AST::Literal.new( :value( 10 ) )
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

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple closure defined in two envs';

done;
