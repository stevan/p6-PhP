#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    # CODE:
    # - in Foo.php
    # let x = 5 in ();;
    #
    # - in Main.php
    # @include Foo
    #
    # let x = 10 in Foo.x + x;;

    my $Foo = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Literal.new( value => 5 ),
                    )
                ],
                body => PhP::AST::Unit.new
            )
        )
    );

    my $unit = PhP::Interpreter::run(
        PhP::Runtime::CompilationUnit.new(
            root => PhP::AST::Let.new(
                bindings => [
                    PhP::AST::SimpleBind.new(
                        var   => PhP::AST::Var.new( name => 'x' ),
                        value => PhP::AST::Literal.new( value => 10 ),
                    )
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => '+' ),
                    args => [
                        PhP::AST::Var.new( name => 'x', namespace => 'Foo' ),
                        PhP::AST::Var.new( name => 'x' ),
                    ]
                )
            ),
            linked => [
                Foo => $Foo
            ],
        )
    );

    isa-ok $unit.result, PhP::AST::Literal;
    isa-ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 15, '... got the value we expected';
}, '... testing simple let';


done-testing;
