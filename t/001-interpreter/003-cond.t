#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

PhP::Runtime::bootstrap;

# NOTE:
# This will test all the comparison operators we 
# currently support through the PhP::Runtime
# - SL

subtest {
    # CODE:
    # let x = 10 in
    #     if x == 10 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::SimpleBinding.new(
                            :var( PhP::AST::Var.new( :name('x') ) ),
                            :value( PhP::AST::Literal.new( :value(10) ) )
                        )
                    ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new(
                                    :name('=='),
                                    :args(
                                        PhP::AST::Var.new( :name('x') ),
                                        PhP::AST::Literal.new( :value(10) )
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value('YES') ) ),
                            :if_false( PhP::AST::Literal.new( :value('NO') ) ),
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

    is $unit.result.value, 'YES', '... got the value we expected';
}, '... testing ==';

subtest {
    # CODE:
    # let x = 10 in
    #     if x != 10 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::SimpleBinding.new(
                            :var( PhP::AST::Var.new( :name('x') ) ),
                            :value( PhP::AST::Literal.new( :value(10) ) )
                        )
                    ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new(
                                    :name('!='),
                                    :args(
                                        PhP::AST::Var.new( :name('x') ),
                                        PhP::AST::Literal.new( :value(10) )
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value('YES') ) ),
                            :if_false( PhP::AST::Literal.new( :value('NO') ) ),
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

    is $unit.result.value, 'NO', '... got the value we expected';
}, '... testing !=';

subtest {
    # CODE:
    # let x = 10 in
    #     if x < 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::SimpleBinding.new(
                            :var( PhP::AST::Var.new( :name('x') ) ),
                            :value( PhP::AST::Literal.new( :value(10) ) )
                        )
                    ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new(
                                    :name('<'),
                                    :args(
                                        PhP::AST::Var.new( :name('x') ),
                                        PhP::AST::Literal.new( :value(100) )
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value('YES') ) ),
                            :if_false( PhP::AST::Literal.new( :value('NO') ) ),
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

    is $unit.result.value, 'YES', '... got the value we expected';
}, '... testing <';

subtest {
    # CODE:
    # let x = 10 in
    #     if x <= 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::SimpleBinding.new(
                            :var( PhP::AST::Var.new( :name('x') ) ),
                            :value( PhP::AST::Literal.new( :value(10) ) )
                        )
                    ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new(
                                    :name('<='),
                                    :args(
                                        PhP::AST::Var.new( :name('x') ),
                                        PhP::AST::Literal.new( :value(100) )
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value('YES') ) ),
                            :if_false( PhP::AST::Literal.new( :value('NO') ) ),
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

    is $unit.result.value, 'YES', '... got the value we expected';
}, '... testing <=';

subtest {
    # CODE:
    # let x = 10 in
    #     if x > 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::SimpleBinding.new(
                            :var( PhP::AST::Var.new( :name('x') ) ),
                            :value( PhP::AST::Literal.new( :value(10) ) )
                        )
                    ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new(
                                    :name('>'),
                                    :args(
                                        PhP::AST::Var.new( :name('x') ),
                                        PhP::AST::Literal.new( :value(100) )
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value('YES') ) ),
                            :if_false( PhP::AST::Literal.new( :value('NO') ) ),
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

    is $unit.result.value, 'NO', '... got the value we expected';
}, '... testing >';

subtest {
    # CODE:
    # let x = 10 in
    #     if x >= 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $unit = PhP::Interpreter::run( 
        PhP::Runtime::CompilationUnit.new( 
            :root(
                PhP::AST::Let.new(
                    :bindings(
                        PhP::AST::SimpleBinding.new(
                            :var( PhP::AST::Var.new( :name('x') ) ),
                            :value( PhP::AST::Literal.new( :value(10) ) )
                        )
                    ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new(
                                    :name('>='),
                                    :args(
                                        PhP::AST::Var.new( :name('x') ),
                                        PhP::AST::Literal.new( :value(100) )
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value('YES') ) ),
                            :if_false( PhP::AST::Literal.new( :value('NO') ) ),
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

    is $unit.result.value, 'NO', '... got the value we expected';
}, '... testing >=';

done;
