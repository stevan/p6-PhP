#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

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

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
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
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 'YES', '... got the value we expected';
}, '... testing ==';

subtest {
    # CODE:
    # let x = 10 in
    #     if x != 10 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
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
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 'NO', '... got the value we expected';
}, '... testing !=';

subtest {
    # CODE:
    # let x = 10 in
    #     if x < 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
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
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 'YES', '... got the value we expected';
}, '... testing <';

subtest {
    # CODE:
    # let x = 10 in
    #     if x <= 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
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
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 'YES', '... got the value we expected';
}, '... testing <=';

subtest {
    # CODE:
    # let x = 10 in
    #     if x > 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
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
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 'NO', '... got the value we expected';
}, '... testing >';

subtest {
    # CODE:
    # let x = 10 in
    #     if x >= 100 
    #         then 'YES'
    #         else 'NO'
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::Let.new(
            :definitions( x => PhP::AST::Literal.new( :value(10) ) ),
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
            ), 
        ) 
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 'NO', '... got the value we expected';
}, '... testing >=';

done;
