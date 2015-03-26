#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

subtest {
    my $Foo = PhP::run('let x = 5 in () ;;');

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            root   => PhP::parse('let x = 10 in Foo.x + x ;;'),
            linked => [ Foo => $Foo ],
        ) 
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 15, '... got the value we expected';
}, '... testing simple let';

subtest {
    my $Math = PhP::run(q[
        let add = func (x, y) { x + y },
            mul = func (x, y) { x * y },
            sub = func (x, y) { x - y },
            div = func (x, y) { x / y },
        in
            ()
        ;;
    ]);

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            root   => PhP::parse(q[ Math.add(2, 2) ]),
            linked => [ Math => $Math ],
        ) 
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 4, '... got the value we expected';
}, '... testing namespaced function calls';

subtest {
    my $Math = PhP::run(q[
        let add = func (x, y) { x + y },
            mul = func (x, y) { x * y },
            sub = func (x, y) { x - y },
            div = func (x, y) { x / y },
        in
            ()
        ;;
    ]);

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            root   => PhP::parse(q[ 
                let binop = func (f, x, y) { f(x, y) } in
                    binop(Math.add, 2, 2) 
                ;;
            ]),
            linked => [ Math => $Math ],
        ) 
    );

    isa_ok $unit.result, PhP::AST::Literal;
    isa_ok $unit.result, PhP::AST::Ast;

    is $unit.result.value, 4, '... got the value we expected';
}, '... testing namespaced functions being passed in as function params';


done;
