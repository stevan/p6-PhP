#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {

    my $orig = PhP::Interpreter::run( 
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
                        value => PhP::AST::Literal.new( value => 5 ),
                    ),
                ],
                body => PhP::AST::Apply.new(
                    func => PhP::AST::Var.new( name => 'add', namespace => 'BadMath' ),
                    args => [
                        PhP::AST::Literal.new( value => 10 )
                    ]
                )
            ),
            linked => [
                'BadMath' => $orig
            ]
        ) 
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 20, '... got the value we expected';
}, '... testing simple closure works when imported into another CompilatonUnit';

done;