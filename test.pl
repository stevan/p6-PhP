#!perl6

use PhP;

# let mul = fun (x, y) 
#               if ( y == 1 ) 
#                   then x 
#                   else x + mul( x, y - 1 ) 
# in
#    mul 13, 2
# ;;

my $root_node = PhP::AST::LetRec.new(
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
);

say PhP::Interpreter::run( $root_node ).perl;

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

