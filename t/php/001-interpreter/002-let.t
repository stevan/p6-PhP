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
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Literal.new( value => 10 ),
                    )
                ],
                body => PhP::AST::Var.new( name => 'x' ),
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';

    ok ?( $unit.env.children[0].get('x') === $unit.result ), '... and the value is what we expected from the env';
}, '... testing simple let';

subtest {
    # CODE:
    # let x = 2 + 2 in x ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Apply.new(
                            func => PhP::AST::Var.new( name => '+' ),
                            args => [
                                PhP::AST::Literal.new( value => 2 ),
                                PhP::AST::Literal.new( value => 2 ),
                            ]
                        )
                    )
                ],
                body => PhP::AST::Var.new( name => 'x' ),
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 4, '... got the value we expected';

    ok ?( $unit.env.children[0].get('x') === $unit.result ), '... and the value is what we expected from the env';
}, '... testing let with an expression as a value';

subtest {
    # CODE:
    # let x = 5, y = 5 in
    #     x + y
    # ;;

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Literal.new( value => 5 )
                    ),
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'y' ),
                        value => PhP::AST::Literal.new( value => 5 )
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => '+' ),
                    args => [
                        PhP::AST::Var.new( name => 'x' ),
                        PhP::AST::Var.new( name => 'y' ),
                    ]
                )
            )
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 10, '... got the value we expected';

    my $x = $unit.env.children[0].get('x');
    my $y = $unit.env.children[0].get('y');

    isa-ok $x, PhP::AST::Literal;
    isa-ok $y, PhP::AST::Literal;

    is $x.value, 5, '... got the value we expected from x in the env';
    is $y.value, 5, '... got the value we expected from y in the env';

}, '... testing nested let statements';

done-testing;
