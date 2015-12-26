#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # let ten = func () { 10 } in
    #     ten()
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'ten' ),
                        value => PhP::AST::Func.new(
                            body => PhP::AST::Literal.new( value => 10 )
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'ten' )
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';
}, '... testing simple function';

subtest {
    # CODE:
    # let add = func (x, y) { x + y } in
    #     add( 10, 10 )
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'add' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x', 'y' ],
                            body   => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '+' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'add' ),
                    args => [
                        PhP::AST::Literal.new( value => 10 ),
                        PhP::AST::Literal.new( value => 10 ),
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

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
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'add' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x', 'y' ],
                            body   => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '+' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'add2' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x' ],
                            body => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => 'add' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Literal.new( value => 2 ),
                                ]
                            )
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'add2' ),
                    args => [
                        PhP::AST::Literal.new( value => 10 ),
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 12, '... got the value we expected';
}, '... testing nested let function bindings';


subtest {
    # CODE:
    # let add = func (x, y) { x + y },
    #     sub = func (x, y) { x - y },
    #     mul = func (x, y) { x * y } in
    #     add( 10, mul( 10, sub( 10 - 5 ) ) )
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'add' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x', 'y' ],
                            body   => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '+' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'sub' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x', 'y' ],
                            body   => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '-' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'mul' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x', 'y' ],
                            body   => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '*' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'add' ),
                    args => [
                        PhP::AST::Literal.new( value => 10 ),
                        PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => 'mul' ),
                            args => [
                                PhP::AST::Literal.new( value => 10 ),
                                PhP::AST::Apply.new(
                                    func => PhP::AST::Var.new( name => 'sub' ),
                                    args => [
                                        PhP::AST::Literal.new( value => 10 ),
                                        PhP::AST::Literal.new( value => 5  ),
                                    ]
                                )
                            ]
                        )
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 60, '... got the value we expected';
}, '... testing nested let function bindings';


subtest {
    # CODE:
    # let x   = 10,
    #     add = func (y) { x + y } in
    #     add( 10 )
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Literal.new( value => 10 ),
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'add' ),
                        value => PhP::AST::Func.new(
                            params => [ 'y' ],
                            body => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '+' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'add' ),
                    args => [
                        PhP::AST::Literal.new( value => 10 )
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

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
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Literal.new( value => 10 ),
                    )
                ],
                body => PhP::AST::Let.new(
                    bindings => [
                        PhP::AST::SimpleBind.new(
                            var   => PhP::AST::Var.new( name => 'add' ),
                            value => PhP::AST::Func.new(
                                params => [ 'y' ],
                                body   => PhP::AST::Apply.new(
                                    func => PhP::AST::Var.new( name => '+' ),
                                    args => [
                                        PhP::AST::Var.new( name => 'x' ),
                                        PhP::AST::Var.new( name => 'y' ),
                                    ]
                                )
                            )
                        ),
                    ],
                    body => PhP::AST::Apply.new(
                        func => PhP::AST::Var.new( name => 'add' ),
                        args => [
                            PhP::AST::Literal.new( value => 10 )
                        ]
                    )
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple closure defined in two envs';

subtest {
    # CODE:
    # let add   = func (x, y) { x + y }
    #     binop = func (f, x, y) { f(x, y) }
    # in
    #     binop( add, 10, 10 )
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'add' ),
                        value => PhP::AST::Func.new(
                            params => [ 'x', 'y' ],
                            body => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => '+' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'binop' ),
                        value => PhP::AST::Func.new(
                            params => [ 'f', 'x', 'y' ],
                            body => PhP::AST::Apply.new(
                                func => PhP::AST::Var.new( name => 'f' ),
                                args => [
                                    PhP::AST::Var.new( name => 'x' ),
                                    PhP::AST::Var.new( name => 'y' ),
                                ]
                            )
                        )
                    ),
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'binop' ),
                    args => [
                        PhP::AST::Var.new( name => 'add' ),
                        PhP::AST::Literal.new( value => 10 ),
                        PhP::AST::Literal.new( value => 10 ),
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing first class functions';


done-testing;
