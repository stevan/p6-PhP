use v6;

use PhP::AST;

class PhP::Parser::Actions {

    method TOP ($/) { 
        $/.make( $/.<statement>.made );
    }

    method statement ($/) {
        $/.make( 
            $/.<let-statement>.made 
                //
            $/.<expression>.made 
        );
    }

    ## let statement

    method let-statement ($/) {
        $/.make(
            PhP::AST::Let.new(
                :definitions( $/.<let-value>>>.made ),
                :body( $/.<let-body>.made )
            )
        );
    }

    method let-value ($/) {    
        my $ident = ~ $/.<identifier>;
        my $value = $/.<let-statement-value>.made;

        $/.make( $ident => $value );
    }

    method let-statement-value ($/) {
        $/.make( 
            $/.<func-statement>.made
                //
            $/.<expression>.made
        );
    }

    # func statements

    method func-statement ($/) {
        $/.make(
            PhP::AST::Func.new(
                :params( $/.<func-param>>>.made ),
                :body( $/.<func-body>.made )
            )
        );
    }    

    method func-param ($/) {
        $/.make( ~ $/.<identifier> )
    }

    method func-body ($/) {
        $/.make( $/.<expression>.made )
    }

    # ...

    method expression ($/) {
        $/.make( 
            $/.<tuple-expression>.made
                //
            $/.<apply-expression>.made
                //
            $/.<cond-expression>.made
                //
            $/.<binary-expression>.made
                //
            $/.<identifier>.made
                //
            $/.<literal>.made 
                //
            $/.<expression>.made
                //
            PhP::AST::Unit.new
        );
    }

    method apply-expression ($/) {
        $/.make(
            PhP::AST::Apply.new(
                :name( ~ $/.<identifier> ),
                :args(
                    $/.<apply-argument>>>.made
                )
            )
        );
    }

    method apply-argument ($/) {
        $/.make( $/.<expression>.made );
    }

    method cond-expression ($/) {
        $/.make(
            PhP::AST::Cond.new(
                :condition( $/.<condition>.made ),
                :if_true(   $/.<if_true>.made   ),
                :if_false(  $/.<if_false>.made  ),
            )
        );
    }

    method binary-expression ($/) {
        $/.make( 
            PhP::AST::Apply.new( 
                :name( ~ $/.<binary-op> ),
                :args( 
                    ($/.<literal> // $/.<identifier>).made,
                    $/.<expression>.made 
                )
            ) 
        );
    }

    method tuple-expression ($/) {
        $/.make( PhP::AST::Tuple.new( :items( $/.<tuple-expression-item>>>.made ) ) );
    }

    method tuple-expression-item ($/) {
        $/.make( $/.<expression>.made );
    }

    method literal ($/) {
        if ( my $bool = $/.<literal-boolean> ) {
            if ( ~$bool eq 'true' ) {
                $/.make( PhP::AST::Var.new( :name("#TRUE") ) );
            }
            elsif ( ~$bool eq 'false' ) {
                $/.make( PhP::AST::Var.new( :name("#FALSE") ) );
            }
        }
        elsif ( my $string = $/.<literal-string> ) {
            $/.make( PhP::AST::StringLiteral.new( :value( ~$string ) ) );
        }
        elsif ( my $number = $/.<literal-number> ) {
            $/.make( PhP::AST::NumberLiteral.new( :value( 0+ $number ) ) );
        }
        else {
            die "I have no idea what kind of literal this is: $/"; 
        }
    }

    method identifier ($/) {
        $/.make( PhP::AST::Var.new( :name( ~ $/ ) ) );
    }
}