#!perl6

use v6;
use lib 'lib';
use Test;

use PhP;

plan *;

subtest {
    # CODE:
    # let rec mul = func (x, y) { 
    #     if y == 1 
    #         then x
    #         else x + mul( x, y - 1 )
    # } in
    #     mul(13, 2)
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::LetRec.new(
            :definitions(
                'mul' => PhP::AST::Func.new(
                    :params( 'x', 'y' ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new( 
                                    :name( '==' ),
                                    :args(
                                        PhP::AST::Var.new( :name( 'y' ) ),
                                        PhP::AST::Literal.new( :value(  1  ) ),
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Var.new( :name( 'x' ) ) ),
                            :if_false(
                                PhP::AST::Apply.new(
                                    :name( '+' ),
                                    :args(
                                        PhP::AST::Var.new( :name( 'x' ) ),
                                        PhP::AST::Apply.new(
                                            :name( 'mul' ),
                                            :args(
                                                PhP::AST::Var.new( :name( 'x' ) ),
                                                PhP::AST::Apply.new(
                                                    :name( '-' ),
                                                    :args(
                                                        PhP::AST::Var.new( :name( 'y' ) ),
                                                        PhP::AST::Literal.new( :value(  1  ) ),
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name( 'mul' ),
                    :args(
                        PhP::AST::Literal.new( :value( 13 ) ),
                        PhP::AST::Literal.new( :value( 2 ) ),
                    )
                )
            )
        )
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 26, '... got the value we expected';
}, '... testing recursive multiplation';

subtest {
    # CODE:
    # let rec factorial = func (n) { 
    #     if n == 1 
    #         then 1
    #         else n * factorial( n - 1 )
    # } in
    #     factorial( 5 )
    # ;;

    my $result = PhP::Interpreter::run( 
        PhP::AST::LetRec.new(
            :definitions(
                'factorial' => PhP::AST::Func.new(
                    :params( 'n' ),
                    :body(
                        PhP::AST::Cond.new(
                            :condition(
                                PhP::AST::Apply.new( 
                                    :name( '==' ),
                                    :args(
                                        PhP::AST::Var.new( :name( 'n' ) ),
                                        PhP::AST::Literal.new( :value(  1  ) ),
                                    )
                                )
                            ),
                            :if_true( PhP::AST::Literal.new( :value(  1  ) ) ),
                            :if_false(
                                PhP::AST::Apply.new(
                                    :name( '*' ),
                                    :args(
                                        PhP::AST::Var.new( :name( 'n' ) ),
                                        PhP::AST::Apply.new(
                                            :name( 'factorial' ),
                                            :args(
                                                PhP::AST::Apply.new(
                                                    :name( '-' ),
                                                    :args(
                                                        PhP::AST::Var.new( :name( 'n' ) ),
                                                        PhP::AST::Literal.new( :value(  1  ) ),
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            ),
            :body(
                PhP::AST::Apply.new(
                    :name( 'factorial' ),
                    :args(
                        PhP::AST::Literal.new( :value( 5 ) ),
                    )
                )
            )
        )
    );

    isa_ok $result, PhP::AST::Literal;
    isa_ok $result, PhP::AST::Ast;

    is $result.value, 120, '... got the value we expected';
}, '... testing factorial';

subtest {
    # CODE:
    # let rec 
    #     is_even = func (n) -> if n == 0 then true  else is_odd( n - 1 ),
    #     is_odd  = func (n) -> if n == 0 then false else is_even( n - 1 ),
    #  in
    #     is_even( 2 )
    # ;;

    my @definitions = (
        'is_even' => PhP::AST::Func.new(
            :params( 'n' ),
            :body(
                PhP::AST::Cond.new(
                    :condition(
                        PhP::AST::Apply.new( 
                            :name( '==' ),
                            :args(
                                PhP::AST::Var.new( :name( 'n' ) ),
                                PhP::AST::Literal.new( :value(  0  ) ),
                            )
                        )
                    ),
                    :if_true( PhP::AST::Var.new( :name('#TRUE') ) ),
                    :if_false(
                        PhP::AST::Apply.new(
                            :name( 'is_odd' ),
                            :args(
                                PhP::AST::Apply.new(
                                    :name( '-' ),
                                    :args(
                                        PhP::AST::Var.new( :name( 'n' ) ),
                                        PhP::AST::Literal.new( :value(  1  ) ),
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        'is_odd' => PhP::AST::Func.new(
            :params( 'n' ),
            :body(
                PhP::AST::Cond.new(
                    :condition(
                        PhP::AST::Apply.new( 
                            :name( '==' ),
                            :args(
                                PhP::AST::Var.new( :name( 'n' ) ),
                                PhP::AST::Literal.new( :value(  0  ) ),
                            )
                        )
                    ),
                    :if_true( PhP::AST::Var.new( :name('#FALSE') ) ),
                    :if_false(
                        PhP::AST::Apply.new(
                            :name( 'is_even' ),
                            :args(
                                PhP::AST::Apply.new(
                                    :name( '-' ),
                                    :args(
                                        PhP::AST::Var.new( :name( 'n' ) ),
                                        PhP::AST::Literal.new( :value(  1  ) ),
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    );

    {
        my $result = PhP::Interpreter::run( 
            PhP::AST::LetRec.new(
                :definitions(@definitions),
                :body(
                    PhP::AST::Apply.new(
                        :name( 'is_even' ),
                        :args(
                            PhP::AST::Literal.new( :value( 2 ) ),
                        )
                    )
                )
            )
        );

        isa_ok $result, PhP::AST::Literal;
        isa_ok $result, PhP::AST::Ast;

        ok ?( $result === PhP::Runtime::root_env.get('#TRUE') ), '... got the value we expected';
    }

    {
        my $result = PhP::Interpreter::run( 
            PhP::AST::LetRec.new(
                :definitions(@definitions),
                :body(
                    PhP::AST::Apply.new(
                        :name( 'is_even' ),
                        :args(
                            PhP::AST::Literal.new( :value( 5 ) ),
                        )
                    )
                )
            )
        );

        isa_ok $result, PhP::AST::Literal;
        isa_ok $result, PhP::AST::Ast;

        ok ?( $result === PhP::Runtime::root_env.get('#FALSE') ), '... got the value we expected';
    }

    {
        my $result = PhP::Interpreter::run( 
            PhP::AST::LetRec.new(
                :definitions(@definitions),
                :body(
                    PhP::AST::Apply.new(
                        :name( 'is_odd' ),
                        :args(
                            PhP::AST::Literal.new( :value( 2 ) ),
                        )
                    )
                )
            )
        );

        isa_ok $result, PhP::AST::Literal;
        isa_ok $result, PhP::AST::Ast;

        ok ?( $result === PhP::Runtime::root_env.get('#FALSE') ), '... got the value we expected';
    }

    {
        my $result = PhP::Interpreter::run( 
            PhP::AST::LetRec.new(
                :definitions(@definitions),
                :body(
                    PhP::AST::Apply.new(
                        :name( 'is_odd' ),
                        :args(
                            PhP::AST::Literal.new( :value( 7 ) ),
                        )
                    )
                )
            )
        );

        isa_ok $result, PhP::AST::Literal;
        isa_ok $result, PhP::AST::Ast;

        ok ?( $result === PhP::Runtime::root_env.get('#TRUE') ), '... got the value we expected';
    }

}, '... testing multually recursive even/odd predicate';


done;
