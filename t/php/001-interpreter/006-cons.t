#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # let x = 1 :: [] in
    #     head(x)
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 1 ),
                                PhP::AST::Tuple.new,
                            ]
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'head' ),
                    args => [ PhP::AST::Var.new( name => 'x' ) ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 1, '... got the value we expected';
}, '... testing simple list w/ head function';

subtest {
    # CODE:
    # let x = 1 :: [] in
    #     tail(x)
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 1 ),
                                PhP::AST::Tuple.new,
                            ]
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'tail' ),
                    args => [ PhP::AST::Var.new( name => 'x' ) ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Tuple;
    isa-ok $unit.result, PhP::AST::Ast;

    ok $unit.result.is_empty, '... got the value we expected';
}, '... testing simple list w/ tail function';

subtest {
    # CODE:
    # let x = 1 :: [] in
    #     is_nil(tail(x))
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 1 ),
                                PhP::AST::Tuple.new,
                            ]
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'is_nil' ),
                    args => [
                        PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => 'tail' ),
                            args => [ PhP::AST::Var.new( name => 'x' ) ]
                        )
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    ok $( $unit.result === PhP::Runtime::root_env.get('#TRUE') ), '... got the value we expected';
}, '... testing simple list w/ is_nil(tail()) function';

subtest {
    # CODE:
    # let x = 1 :: 2 :: 3 :: [] in
    #     head(tail(x))
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 1 ),
                                PhP::AST::Apply.new(
                                    func => PhP::AST::Var.new( name => '::' ),
                                    args => [
                                        PhP::AST::Literal.new( value => 2 ),
                                        PhP::AST::Apply.new(
                                            func => PhP::AST::Var.new( name => '::' ),
                                            args => [
                                                PhP::AST::Literal.new( value => 3 ),
                                                PhP::AST::Tuple.new,
                                            ]
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'head' ),
                    args => [
                       PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => 'tail' ),
                            args => [ PhP::AST::Var.new( name => 'x' ) ]
                        )
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing longer list w/ head(tail()) function';

subtest {
    # CODE:
    # let z = 3 :: []
    #     y = 2 :: z
    #     x = 1 :: y
    # in
    #     head(tail(x))
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'z' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 3 ),
                                PhP::AST::Tuple.new,
                            ]
                        )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'y' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 2 ),
                                PhP::AST::Var.new( name => 'z' ),
                            ]
                        )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '::' ),
                            args => [
                                PhP::AST::Literal.new( value => 1 ),
                                PhP::AST::Var.new( name => 'y' ),
                            ]
                        )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'head' ),
                    args => [
                       PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => 'tail' ),
                            args => [ PhP::AST::Var.new( name => 'x' ) ]
                        )
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 2, '... got the value we expected';
}, '... testing nested list w/ head(tail()) function';


done-testing;
