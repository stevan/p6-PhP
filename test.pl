#!perl6

use PhP::Parser;
use PhP::Interpreter;

my $root_node = PhP::Parser::LetRec.new(
    :definitions(
        'mul' => PhP::Parser::Func.new(
            :params( 'x', 'y' ),
            :body(
                PhP::Parser::Cond.new(
                    :condition(
                        PhP::Parser::Apply.new( 
                            :name( '==' ),
                            :args(
                                PhP::Parser::Var.new( :name( 'y' ) ),
                                PhP::Parser::Literal.new( :value(  1  ) ),
                            )
                        )
                    ),
                    :if_true( PhP::Parser::Var.new( :name( 'x' ) ) ),
                    :if_false(
                        PhP::Parser::Apply.new(
                            :name( '+' ),
                            :args(
                                PhP::Parser::Var.new( :name( 'x' ) ),
                                PhP::Parser::Apply.new(
                                    :name( 'mul' ),
                                    :args(
                                        PhP::Parser::Var.new( :name( 'x' ) ),
                                        PhP::Parser::Apply.new(
                                            :name( '-' ),
                                            :args(
                                                PhP::Parser::Var.new( :name( 'y' ) ),
                                                PhP::Parser::Literal.new( :value(  1  ) ),
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
        PhP::Parser::Apply.new(
            :name( 'mul' ),
            :args(
                PhP::Parser::Literal.new( :value( 10 ) ),
                PhP::Parser::Literal.new( :value( 8 ) ),
            )
        )
    )
);

say run( $root_node ).perl;

## ---------------------------------------------

#Cond.new(
#    condition => Apply.new(
#        :name( '==' ),
#        :args(
#            Literal.new( value => 2 ),
#            Literal.new( value => 3 ),
#        )
#    ),
#    if_true  => Literal.new( value => 'TRUE!!!'  ),
#    if_false => Literal.new( value => 'FALSE!!!' ),
#),

